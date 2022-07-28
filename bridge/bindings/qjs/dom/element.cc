/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "element.h"
#include "bindings/qjs/bom/blob.h"
#include "bindings/qjs/html_parser.h"
#include "dart_methods.h"
#include "document.h"
#include "elements/template_element.h"
#include "text_node.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken::binding::qjs {

std::once_flag kElementInitOnceFlag;

void bindElement(ExecutionContext* context) {
  auto* constructor = Element::instance(context);
  //  auto* domRectConstructor = BoundingClientRect
  context->defineGlobalProperty("Element", constructor->jsObject);
  context->defineGlobalProperty("HTMLElement", JS_DupValue(context->ctx(), constructor->jsObject));
}

bool isJavaScriptExtensionElementInstance(ExecutionContext* context, JSValue instance) {
  if (JS_IsInstanceOf(context->ctx(), instance, Element::instance(context)->jsObject)) {
    auto* elementInstance = static_cast<ElementInstance*>(JS_GetOpaque(instance, Element::classId()));
    std::string tagName = elementInstance->getRegisteredTagName();

    // Special case for kraken official plugins.
    if (tagName == "video" || tagName == "iframe")
      return true;

    for (char i : tagName) {
      if (i == '-')
        return true;
    }
  }

  return false;
}

JSClassID Element::kElementClassId{0};

Element::Element(ExecutionContext* context) : Node(context, "Element") {
  std::call_once(kElementInitOnceFlag, []() { JS_NewClassID(&kElementClassId); });
  JS_SetPrototype(m_ctx, m_prototypeObject, Node::instance(m_context)->prototype());
}

JSClassID Element::classId() {
  return kElementClassId;
}

JSClassID ElementAttributes::classId{0};
JSValue ElementAttributes::getAttribute(const std::string& name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return JS_NULL;
  }

  return JS_DupValue(m_ctx, m_attributes[name]);
}

JSValue ElementAttributes::setAttribute(const std::string& name, JSValue value) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return JS_ThrowTypeError(m_ctx, "Failed to execute 'setAttribute' on 'Element': '%s' is not a valid attribute name.", name.c_str());
  }

  if (name == "class") {
    std::string classNameString = jsValueToStdString(m_ctx, value);
    m_className->set(classNameString);
  }

  // If attribute exists, should free the previous value.
  if (m_attributes.count(name) > 0) {
    JS_FreeValue(m_ctx, m_attributes[name]);
  }

  m_attributes[name] = JS_DupValue(m_ctx, value);

  return JS_NULL;
}

bool ElementAttributes::hasAttribute(std::string& name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return false;
  }

  return m_attributes.count(name) > 0;
}

void ElementAttributes::removeAttribute(std::string& name) {
  JSValue value = m_attributes[name];
  JS_FreeValue(m_ctx, value);
  m_attributes.erase(name);
}

void ElementAttributes::copyWith(ElementAttributes* attributes) {
  for (auto& attr : attributes->m_attributes) {
    m_attributes[attr.first] = JS_DupValue(m_ctx, attr.second);
  }
}

std::shared_ptr<SpaceSplitString> ElementAttributes::className() {
  return m_className;
}

std::string ElementAttributes::toString() {
  std::string s;

  for (auto& attr : m_attributes) {
    s += attr.first + "=";
    const char* pstr = JS_ToCString(m_ctx, attr.second);
    s += "\"" + std::string(pstr) + "\"";
    JS_FreeCString(m_ctx, pstr);
  }

  return s;
}

void ElementAttributes::dispose() const {
  for (auto& attr : m_attributes) {
    JS_FreeValueRT(m_runtime, attr.second);
  }
}
void ElementAttributes::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  for (auto& attr : m_attributes) {
    JS_MarkValue(rt, attr.second, mark_func);
  }
}

JSValue Element::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  if (argc == 0)
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  JSValue tagName = argv[0];

  if (!JS_IsString(tagName)) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }

  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  std::string name = jsValueToStdString(ctx, tagName);

  auto* Document = Document::instance(context);
  if (Document->isCustomElement(name)) {
    return JS_CallConstructor(ctx, Document->getElementConstructor(context, name), argc, argv);
  }

  auto* element = new ElementInstance(this, name, true);
  return element->jsObject;
}

JSValue Element::insertAdjacentElement(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'insertAdjacentElement' on 'Element': 2 argument required.");
  }
  JSValue positionValue = argv[0];
  JSValue target = argv[1];

  if (!JS_IsObject(target)) {
    return JS_ThrowTypeError(ctx, "TypeError: Failed to execute 'insertAdjacentElement' on 'Element': parameter 2 is not of type 'Element'");
  }

  auto* thisElement = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  auto* newChild = static_cast<NodeInstance*>(JS_GetOpaque(target, Node::classId(target)));

  std::string position = jsValueToStdString(ctx, positionValue);

  if (position == "beforebegin") {
    if (auto* parent = static_cast<NodeInstance*>(JS_GetOpaque(thisElement->parentNode, Node::classId(thisElement->parentNode)))) {
      parent->internalInsertBefore(newChild, thisElement);
    }
  } else if (position == "afterbegin") {
    thisElement->internalInsertBefore(newChild, thisElement->firstChild());
  } else if (position == "beforeend") {
    thisElement->internalAppendChild(newChild);
  } else if (position == "afterend") {
    if (auto* parent = static_cast<NodeInstance*>(JS_GetOpaque(thisElement->parentNode, Node::classId(thisElement->parentNode)))) {
      JSValue nextSiblingValue = JS_GetPropertyUint32(ctx, parent->childNodes, arrayFindIdx(ctx, parent->childNodes, thisElement->jsObject) + 1);
      auto* nextSibling = static_cast<NodeInstance*>(JS_GetOpaque(nextSiblingValue, Node::classId(nextSiblingValue)));
      parent->internalInsertBefore(newChild, nextSibling);
      JS_FreeValue(ctx, nextSiblingValue);
    }
  }
  std::unique_ptr<NativeString> args_01 = stringToNativeString(std::to_string(thisElement->eventTargetId()));
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, positionValue);
  thisElement->m_context->uiCommandBuffer()->addCommand(thisElement->m_eventTargetId, UICommand::insertAdjacentNode, *args_01, *args_02, nullptr);
}

JSValue Element::getBoundingClientRect(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  getDartMethod()->flushUICommand();
  return element->invokeBindingMethod("getBoundingClientRect", 0, nullptr);
}

JSValue Element::hasAttribute(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'hasAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  auto* attributes = element->m_attributes;

  const char* cname = JS_ToCString(ctx, nameValue);
  std::string name = std::string(cname);

  JSValue result = JS_NewBool(ctx, attributes->hasAttribute(name));
  JS_FreeCString(ctx, cname);

  return result;
}

JSValue Element::setAttribute(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': 2 arguments required, but only %d present", argc);
  }

  JSValue nameValue = argv[0];
  JSValue attributeValue = JS_ToString(ctx, argv[1]);

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string name = jsValueToStdString(ctx, nameValue);
  std::transform(name.begin(), name.end(), name.begin(), ::tolower);

  auto* attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    JSValue oldAttribute = attributes->getAttribute(name);
    JSValue exception = attributes->setAttribute(name, attributeValue);
    if (JS_IsException(exception))
      return exception;
    element->_didModifyAttribute(name, oldAttribute, attributeValue);
    JS_FreeValue(ctx, oldAttribute);
  } else {
    JSValue exception = attributes->setAttribute(name, attributeValue);
    if (JS_IsException(exception))
      return exception;
    element->_didModifyAttribute(name, JS_NULL, attributeValue);
  }

  std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, attributeValue);

  element->m_context->uiCommandBuffer()->addCommand(element->m_eventTargetId, UICommand::setAttribute, *args_01, *args_02, nullptr);

  JS_FreeValue(ctx, attributeValue);

  return JS_NULL;
}

JSValue Element::getAttribute(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'getAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string name = jsValueToStdString(ctx, nameValue);

  auto* attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    return attributes->getAttribute(name);
  }

  return JS_NULL;
}

JSValue Element::removeAttribute(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeAttribute' on 'Element': name attribute is not valid.");
  }

  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string name = jsValueToStdString(ctx, nameValue);
  auto* attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    JSValue targetValue = attributes->getAttribute(name);
    element->m_attributes->removeAttribute(name);
    element->_didModifyAttribute(name, targetValue, JS_NULL);
    JS_FreeValue(ctx, targetValue);

    std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
    element->m_context->uiCommandBuffer()->addCommand(element->m_eventTargetId, UICommand::removeAttribute, *args_01, nullptr);
  }

  return JS_NULL;
}

JSValue Element::toBlob(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  double devicePixelRatio = 1.0;

  if (argc > 0) {
    JSValue devicePixelRatioValue = argv[0];

    if (!JS_IsNumber(devicePixelRatioValue)) {
      return JS_ThrowTypeError(ctx, "Failed to export blob: parameter 1 (devicePixelRatio) is not an number.");
    }

    JS_ToFloat64(ctx, &devicePixelRatio, devicePixelRatioValue);
  }

  if (getDartMethod()->toBlob == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to export blob: dart method (toBlob) is not registered.");
  }

  auto* element = reinterpret_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  getDartMethod()->flushUICommand();

  auto blobCallback = [](void* callbackContext, int32_t contextId, const char* error, uint8_t* bytes, int32_t length) {
    if (!isContextValid(contextId))
      return;

    auto promiseContext = static_cast<PromiseContext*>(callbackContext);
    JSContext* ctx = promiseContext->context->ctx();
    if (error == nullptr) {
      std::vector<uint8_t> vec(bytes, bytes + length);
      JSValue arrayBuffer = JS_NewArrayBuffer(ctx, bytes, length, nullptr, nullptr, false);
      Blob* constructor = Blob::instance(promiseContext->context);
      JSValue argumentsArray = JS_NewArray(ctx);
      JSValue pushMethod = JS_GetPropertyStr(ctx, argumentsArray, "push");
      JS_Call(ctx, pushMethod, argumentsArray, 1, &arrayBuffer);
      JSValue blobValue = JS_CallConstructor(ctx, constructor->jsObject, 1, &argumentsArray);

      if (JS_IsException(blobValue)) {
        promiseContext->context->handleException(&blobValue);
      } else {
        JSValue ret = JS_Call(ctx, promiseContext->resolveFunc, promiseContext->promise, 1, &blobValue);
        promiseContext->context->handleException(&ret);
        promiseContext->context->drainPendingPromiseJobs();
        JS_FreeValue(ctx, ret);
      }

      JS_FreeValue(ctx, pushMethod);
      JS_FreeValue(ctx, blobValue);
      JS_FreeValue(ctx, argumentsArray);
      JS_FreeValue(ctx, arrayBuffer);
    } else {
      JS_ThrowInternalError(ctx, "%s", error);
      JSValue errorObject = JS_GetException(ctx);
      JSValue ret = JS_Call(ctx, promiseContext->rejectFunc, promiseContext->promise, 1, &errorObject);
      promiseContext->context->handleException(&ret);
      promiseContext->context->drainPendingPromiseJobs();
      JS_FreeValue(ctx, errorObject);
      JS_FreeValue(ctx, ret);
    }

    promiseContext->context->drainPendingPromiseJobs();

    JS_FreeValue(ctx, promiseContext->resolveFunc);
    JS_FreeValue(ctx, promiseContext->rejectFunc);
    list_del(&promiseContext->link);
    delete promiseContext;
  };

  JSValue resolving_funcs[2];
  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);

  auto toBlobPromiseContext = new PromiseContext{
      nullptr, element->m_context, resolving_funcs[0], resolving_funcs[1], promise,
  };

  getDartMethod()->toBlob(static_cast<void*>(toBlobPromiseContext), element->m_context->getContextId(), blobCallback, element->m_eventTargetId, devicePixelRatio);
  list_add_tail(&toBlobPromiseContext->link, &element->m_context->promise_job_list);

  return promise;
}

JSValue Element::click(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
#if FLUTTER_BACKEND
  getDartMethod()->flushUICommand();
  auto element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->invokeBindingMethod("click", 0, nullptr);
#elif UNIT_TEST
  auto element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  TEST_dispatchEvent(element->m_contextId, element, "click");
  return JS_UNDEFINED;
#else
  return JS_UNDEFINED;
#endif
}

JSValue Element::scroll(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  double arg0 = 0;
  double arg1 = 0;
  JS_ToFloat64(ctx, &arg0, argv[0]);
  JS_ToFloat64(ctx, &arg1, argv[1]);
  NativeValue arguments[] = {Native_NewFloat64(arg0), Native_NewFloat64(arg1)};
  return element->invokeBindingMethod("scroll", 2, arguments);
}

JSValue Element::scrollBy(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  double arg0 = 0;
  double arg1 = 0;
  JS_ToFloat64(ctx, &arg0, argv[0]);
  JS_ToFloat64(ctx, &arg1, argv[1]);
  NativeValue arguments[] = {Native_NewFloat64(arg0), Native_NewFloat64(arg1)};
  return element->invokeBindingMethod("scrollBy", 2, arguments);
}

IMPL_PROPERTY_GETTER(Element, nodeName)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string tagName = element->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

IMPL_PROPERTY_GETTER(Element, tagName)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string tagName = element->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

IMPL_PROPERTY_GETTER(Element, className)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("className");
}
IMPL_PROPERTY_SETTER(Element, className)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  JSValue value = argv[0];

  // @TODO: Remove this line.
  element->m_attributes->setAttribute("class", value);

  const char* string = JS_ToCString(ctx, value);
  NativeValue nativeValue = Native_NewCString(string);
  element->setBindingProperty("className", nativeValue);
  JS_FreeCString(ctx, string);
  return JS_DupValue(ctx, value);
}

IMPL_PROPERTY_GETTER(Element, offsetLeft)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("offsetLeft");
}

IMPL_PROPERTY_GETTER(Element, offsetTop)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("offsetTop");
}

IMPL_PROPERTY_GETTER(Element, offsetWidth)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("offsetWidth");
}

IMPL_PROPERTY_GETTER(Element, offsetHeight)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("offsetHeight");
}

IMPL_PROPERTY_GETTER(Element, clientWidth)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("clientWidth");
}

IMPL_PROPERTY_GETTER(Element, clientHeight)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("clientHeight");
}

IMPL_PROPERTY_GETTER(Element, clientTop)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("clientTop");
}

IMPL_PROPERTY_GETTER(Element, clientLeft)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("clientLeft");
}

IMPL_PROPERTY_GETTER(Element, scrollTop)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("scrollTop");
}
IMPL_PROPERTY_SETTER(Element, scrollTop)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  double floatValue = 0;
  JSValue value = argv[0];
  JS_ToFloat64(ctx, &floatValue, value);
  NativeValue nativeValue = Native_NewFloat64(floatValue);
  element->setBindingProperty("scrollTop", nativeValue);
  return JS_DupValue(ctx, value);
}

IMPL_PROPERTY_GETTER(Element, scrollLeft)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("scrollLeft");
}
IMPL_PROPERTY_SETTER(Element, scrollLeft)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  double floatValue = 0;
  JSValue value = argv[0];
  JS_ToFloat64(ctx, &floatValue, value);
  NativeValue nativeValue = Native_NewFloat64(floatValue);
  element->setBindingProperty("scrollLeft", nativeValue);
  return JS_DupValue(ctx, value);
}

IMPL_PROPERTY_GETTER(Element, scrollHeight)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("scrollHeight");
}

IMPL_PROPERTY_GETTER(Element, scrollWidth)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getBindingProperty("scrollWidth");
}

// Definition for firstElementChild
IMPL_PROPERTY_GETTER(Element, firstElementChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  int32_t len = arrayGetLength(ctx, element->childNodes);

  for (int i = 0; i < len; i++) {
    JSValue v = JS_GetPropertyUint32(ctx, element->childNodes, i);
    auto* instance = static_cast<NodeInstance*>(JS_GetOpaque(v, Node::classId(v)));
    if (instance->nodeType == NodeType::ELEMENT_NODE) {
      return instance->jsObject;
    }
    JS_FreeValue(ctx, v);
  }

  return JS_NULL;
}

// Definition for lastElementChild
IMPL_PROPERTY_GETTER(Element, lastElementChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  int32_t len = arrayGetLength(ctx, element->childNodes);

  for (int i = len - 1; i >= 0; i--) {
    JSValue v = JS_GetPropertyUint32(ctx, element->childNodes, i);
    auto* instance = static_cast<NodeInstance*>(JS_GetOpaque(v, Node::classId(v)));
    if (instance->nodeType == NodeType::ELEMENT_NODE) {
      return instance->jsObject;
    }
    JS_FreeValue(ctx, v);
  }

  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Element, children)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  JSValue array = JS_NewArray(ctx);
  JSValue pushMethod = JS_GetPropertyStr(ctx, array, "push");

  int32_t len = arrayGetLength(ctx, element->childNodes);

  for (int i = 0; i < len; i++) {
    JSValue v = JS_GetPropertyUint32(ctx, element->childNodes, i);
    auto* instance = static_cast<NodeInstance*>(JS_GetOpaque(v, Node::classId(v)));
    if (instance->nodeType == NodeType::ELEMENT_NODE) {
      JSValue arguments[] = {v};
      JS_Call(ctx, pushMethod, array, 1, arguments);
    }
    JS_FreeValue(ctx, v);
  }

  JS_FreeValue(ctx, pushMethod);

  return array;
}

IMPL_PROPERTY_GETTER(Element, attributes)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return JS_DupValue(ctx, element->m_attributes->toQuickJS());
}

IMPL_PROPERTY_GETTER(Element, innerHTML)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return JS_NewString(ctx, element->innerHTML().c_str());
}
IMPL_PROPERTY_SETTER(Element, innerHTML)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  const char* chtml = JS_ToCString(ctx, argv[0]);

  if (element->hasNodeFlag(NodeInstance::NodeFlag::IsTemplateElement)) {
    auto* templateElement = static_cast<TemplateElementInstance*>(element);
    HTMLParser::parseHTMLFragment(chtml, strlen(chtml), templateElement->content());
  } else {
    HTMLParser::parseHTMLFragment(chtml, strlen(chtml), element);
  }

  JS_FreeCString(ctx, chtml);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Element, outerHTML)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return JS_NewString(ctx, element->outerHTML().c_str());
}
IMPL_PROPERTY_SETTER(Element, outerHTML)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

JSClassID ElementInstance::classID() {
  return Element::classId();
}

ElementInstance::~ElementInstance() {}

JSValue ElementInstance::internalGetTextContent() {
  JSValue array = JS_NewArray(m_ctx);
  JSValue pushMethod = JS_GetPropertyStr(m_ctx, array, "push");

  int32_t len = arrayGetLength(m_ctx, childNodes);

  for (int i = 0; i < len; i++) {
    JSValue n = JS_GetPropertyUint32(m_ctx, childNodes, i);
    auto* node = static_cast<NodeInstance*>(JS_GetOpaque(n, Node::classId(n)));
    JSValue nodeText = node->internalGetTextContent();
    JS_Call(m_ctx, pushMethod, array, 1, &nodeText);
    JS_FreeValue(m_ctx, nodeText);
    JS_FreeValue(m_ctx, n);
  }

  JSValue joinMethod = JS_GetPropertyStr(m_ctx, array, "join");
  JSValue emptyString = JS_NewString(m_ctx, "");
  JSValue joinArgs[] = {emptyString};
  JSValue returnValue = JS_Call(m_ctx, joinMethod, array, 1, joinArgs);

  JS_FreeValue(m_ctx, array);
  JS_FreeValue(m_ctx, pushMethod);
  JS_FreeValue(m_ctx, joinMethod);
  JS_FreeValue(m_ctx, emptyString);
  return returnValue;
}

void ElementInstance::internalSetTextContent(JSValue content) {
  internalClearChild();

  JSValue textNodeValue = JS_CallConstructor(m_ctx, TextNode::instance(m_context)->jsObject, 1, &content);
  auto* textNodeInstance = static_cast<TextNodeInstance*>(JS_GetOpaque(textNodeValue, TextNode::classId()));
  internalAppendChild(textNodeInstance);
  JS_FreeValue(m_ctx, textNodeValue);
}

std::shared_ptr<SpaceSplitString> ElementInstance::classNames() {
  return m_attributes->className();
}

std::string SpaceSplitString::m_delimiter{" "};

void SpaceSplitString::set(std::string& string) {
  size_t pos = 0;
  std::string token;
  std::string s = string;
  while ((pos = s.find(m_delimiter)) != std::string::npos) {
    token = s.substr(0, pos);
    m_szData.push_back(token);
    s.erase(0, pos + m_delimiter.length());
  }
  m_szData.push_back(s);
}

bool SpaceSplitString::contains(std::string& string) {
  for (std::string& s : m_szData) {
    if (s == string) {
      return true;
    }
  }
  return false;
}

bool SpaceSplitString::containsAll(std::string s) {
  std::vector<std::string> szData;
  size_t pos = 0;
  std::string token;

  while ((pos = s.find(m_delimiter)) != std::string::npos) {
    token = s.substr(0, pos);
    szData.push_back(token);
    s.erase(0, pos + m_delimiter.length());
  }
  szData.push_back(s);

  bool flag = true;
  for (std::string& str : szData) {
    bool isContains = false;
    for (std::string& data : m_szData) {
      if (data == str) {
        isContains = true;
        break;
      }
    }
    flag &= isContains;
  }

  return flag;
}

std::string ElementInstance::tagName() {
  std::string tagName = std::string(m_tagName);
  std::transform(tagName.begin(), tagName.end(), tagName.begin(), ::toupper);
  return tagName;
}

std::string ElementInstance::getRegisteredTagName() {
  return m_tagName;
}

std::string ElementInstance::outerHTML() {
  std::string s = "<" + getRegisteredTagName();

  // Read attributes
  std::string attributes = m_attributes->toString();
  // Read style
  std::string style = m_style->toString();

  if (!attributes.empty()) {
    s += " " + attributes;
  }
  if (!style.empty()) {
    s += " style=\"" + style;
  }

  s += ">";

  std::string childHTML = innerHTML();
  s += childHTML;
  s += "</" + getRegisteredTagName() + ">";

  return s;
}

std::string ElementInstance::innerHTML() {
  std::string s;

  // If Element is TemplateElement, the innerHTML content is the content of documentFragment.
  NodeInstance* parent = this;
  if (hasNodeFlag(NodeInstance::NodeFlag::IsTemplateElement)) {
    parent = static_cast<TemplateElementInstance*>(this)->content();
  }

  // Children toString
  int32_t childLen = arrayGetLength(m_ctx, parent->childNodes);

  if (childLen == 0)
    return s;

  for (int i = 0; i < childLen; i++) {
    JSValue c = JS_GetPropertyUint32(m_ctx, parent->childNodes, i);
    auto* node = static_cast<NodeInstance*>(JS_GetOpaque(c, Node::classId(c)));
    if (node->nodeType == NodeType::ELEMENT_NODE) {
      s += reinterpret_cast<ElementInstance*>(node)->outerHTML();
    } else if (node->nodeType == NodeType::TEXT_NODE) {
      s += reinterpret_cast<TextNodeInstance*>(node)->toString();
    }

    JS_FreeValue(m_ctx, c);
  }
  return s;
}

void ElementInstance::_notifyNodeRemoved(NodeInstance* insertionNode) {
  if (insertionNode->isConnected()) {
    traverseNode(this, [](NodeInstance* node) {
      auto* Element = Element::instance(node->m_context);
      if (node->prototype() == Element) {
        auto element = reinterpret_cast<ElementInstance*>(node);
        element->_notifyChildRemoved();
      }

      return false;
    });
  }
}

void ElementInstance::_notifyChildRemoved() {
  std::string prop = "id";
  if (m_attributes->hasAttribute(prop)) {
    JSValue idValue = m_attributes->getAttribute(prop);
    JSAtom id = JS_ValueToAtom(m_ctx, idValue);
    document()->removeElementById(id, this);
    JS_FreeValue(m_ctx, idValue);
    JS_FreeAtom(m_ctx, id);
  }
}

void ElementInstance::_notifyNodeInsert(NodeInstance* insertNode) {
  if (insertNode->isConnected()) {
    traverseNode(this, [](NodeInstance* node) {
      auto* Element = Element::instance(node->m_context);
      if (node->prototype() == Element) {
        auto element = reinterpret_cast<ElementInstance*>(node);
        element->_notifyChildInsert();
      }

      return false;
    });
  }
}

void ElementInstance::_notifyChildInsert() {
  std::string prop = "id";
  if (m_attributes->hasAttribute(prop)) {
    JSValue idValue = m_attributes->getAttribute(prop);
    JSAtom id = JS_ValueToAtom(m_ctx, idValue);
    document()->addElementById(id, this);
    JS_FreeValue(m_ctx, idValue);
    JS_FreeAtom(m_ctx, id);
  }
}

void ElementInstance::_didModifyAttribute(std::string& name, JSValue oldId, JSValue newId) {
  if (name == "id") {
    _beforeUpdateId(oldId, newId);
  }
}

void ElementInstance::_beforeUpdateId(JSValue oldIdValue, JSValue newIdValue) {
  JSAtom oldId = JS_ValueToAtom(m_ctx, oldIdValue);
  JSAtom newId = JS_ValueToAtom(m_ctx, newIdValue);

  if (oldId == newId) {
    JS_FreeAtom(m_ctx, oldId);
    JS_FreeAtom(m_ctx, newId);
    return;
  }

  if (!JS_IsNull(oldIdValue)) {
    document()->removeElementById(oldId, this);
  }

  if (!JS_IsNull(newIdValue)) {
    document()->addElementById(newId, this);
  }

  JS_FreeAtom(m_ctx, oldId);
  JS_FreeAtom(m_ctx, newId);
}

void ElementInstance::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  if (m_attributes != nullptr) {
    JS_MarkValue(rt, m_attributes->toQuickJS(), mark_func);
  }
  NodeInstance::trace(rt, val, mark_func);
}

ElementInstance::ElementInstance(Element* element, std::string tagName, bool shouldAddUICommand)
    : m_tagName(tagName), NodeInstance(element, NodeType::ELEMENT_NODE, Element::classId(), exoticMethods, "Element") {
  m_attributes = makeGarbageCollected<ElementAttributes>()->initialize(m_ctx, &ElementAttributes::classId);
  JSValue arguments[] = {jsObject};
  JSValue style = JS_CallConstructor(m_ctx, CSSStyleDeclaration::instance(m_context)->jsObject, 1, arguments);
  m_style = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(style, CSSStyleDeclaration::kCSSStyleDeclarationClassId));

  JS_DefinePropertyValueStr(m_ctx, jsObject, "style", m_style->jsObject, JS_PROP_C_W_E);

  if (shouldAddUICommand) {
    std::unique_ptr<NativeString> args_01 = stringToNativeString(tagName);
    element->m_context->uiCommandBuffer()->addCommand(m_eventTargetId, UICommand::createElement, *args_01, nativeEventTarget);
  }
}

JSClassExoticMethods ElementInstance::exoticMethods{nullptr, nullptr, nullptr, nullptr, hasProperty, getProperty, setProperty};

StyleDeclarationInstance* ElementInstance::style() {
  return m_style;
}

IMPL_PROPERTY_GETTER(BoundingClientRect, x)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->x);
}

IMPL_PROPERTY_GETTER(BoundingClientRect, y)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->y);
}

IMPL_PROPERTY_GETTER(BoundingClientRect, width)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->width);
}

IMPL_PROPERTY_GETTER(BoundingClientRect, height)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->height);
}

IMPL_PROPERTY_GETTER(BoundingClientRect, top)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->top);
}

IMPL_PROPERTY_GETTER(BoundingClientRect, right)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->right);
}

IMPL_PROPERTY_GETTER(BoundingClientRect, bottom)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->bottom);
}

IMPL_PROPERTY_GETTER(BoundingClientRect, left)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->left);
}

}  // namespace kraken::binding::qjs
