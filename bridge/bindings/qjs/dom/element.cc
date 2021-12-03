/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "bindings/qjs/bom/blob.h"
#include "bindings/qjs/html_parser.h"
#include "dart_methods.h"
#include "document.h"
#include "text_node.h"

namespace kraken::binding::qjs {

std::once_flag kElementInitOnceFlag;

void bindElement(std::unique_ptr<JSContext>& context) {
  auto* constructor = Element::instance(context.get());
  context->defineGlobalProperty("Element", constructor->classObject);
  context->defineGlobalProperty("HTMLElement", JS_DupValue(context->ctx(), constructor->classObject));
}

bool isJavaScriptExtensionElementInstance(JSContext* context, JSValue instance) {
  if (JS_IsInstanceOf(context->ctx(), instance, Element::instance(context)->classObject)) {
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

Element::Element(JSContext* context) : Node(context, "Element") {
  std::call_once(kElementInitOnceFlag, []() { JS_NewClassID(&kElementClassId); });
  JS_SetPrototype(m_ctx, m_prototypeObject, Node::instance(m_context)->prototype());
}

JSClassID Element::classId() {
  return kElementClassId;
}

JSAtom ElementAttributes::getAttribute(const std::string& name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return JS_ATOM_NULL;
  }

  return m_attributes[name];
}

ElementAttributes::~ElementAttributes() {
  for (auto& attr : m_attributes) {
    JS_FreeAtom(m_ctx, attr.second);
  }
}

JSValue ElementAttributes::setAttribute(const std::string& name, JSAtom atom) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return JS_ThrowTypeError(m_ctx, "Failed to execute 'setAttribute' on 'Element': '%s' is not a valid attribute name.", name.c_str());
  }

  if (name == "class") {
    std::string classNameString = jsAtomToStdString(m_ctx, atom);
    m_className->set(classNameString);
  }

  m_attributes[name] = JS_DupAtom(m_ctx, atom);

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
  JSAtom value = m_attributes[name];
  JS_FreeAtom(m_ctx, value);
  m_attributes.erase(name);
}

void ElementAttributes::copyWith(ElementAttributes* attributes) {
  for (auto& attr : attributes->m_attributes) {
    m_attributes[attr.first] = JS_DupAtom(m_ctx, attr.second);
  }
}

std::shared_ptr<SpaceSplitString> ElementAttributes::className() {
  return m_className;
}

std::string ElementAttributes::toString() {
  std::string s;

  for (auto& attr : m_attributes) {
    s += attr.first + "=";
    const char* pstr = JS_AtomToCString(m_ctx, attr.second);
    s += "\"" + std::string(pstr) + "\"";
    JS_FreeCString(m_ctx, pstr);
  }

  return s;
}

JSValue Element::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  if (argc == 0)
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  JSValue tagName = argv[0];

  if (!JS_IsString(tagName)) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }

  auto* context = static_cast<JSContext*>(JS_GetContextOpaque(ctx));
  std::string name = jsValueToStdString(ctx, tagName);

  auto* Document = Document::instance(context);
  if (Document->isCustomElement(name)) {
    return JS_CallConstructor(ctx, Document->getElementConstructor(context, name), argc, argv);
  }

  ElementInstance* element;
  if (name == "HTML") {
    element = new ElementInstance(this, name, false);
    element->m_eventTargetId = HTML_TARGET_ID;
  } else {
    // Fallback to default Element class
    element = new ElementInstance(this, name, true);
  }

  return element->instanceObject;
}

JSValue Element::getBoundingClientRect(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  getDartMethod()->flushUICommand();
  return element->callNativeMethods("getBoundingClientRect", 0, nullptr);
}

JSValue Element::hasAttribute(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

JSValue Element::setAttribute(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': 2 arguments required, but only %d present", argc);
  }

  JSValue nameValue = argv[0];
  JSValue attributeValue = argv[1];
  JSValue attributeString = JS_ToString(ctx, attributeValue);
  JSAtom attributeAtom = JS_ValueToAtom(ctx, attributeString);

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string name = jsValueToStdString(ctx, nameValue);
  std::transform(name.begin(), name.end(), name.begin(), ::tolower);

  auto* attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    JSAtom oldAtom = attributes->getAttribute(name);
    JSValue exception = attributes->setAttribute(name, attributeAtom);
    if (JS_IsException(exception))
      return exception;
    element->_didModifyAttribute(name, oldAtom, attributeAtom);
    JS_FreeAtom(ctx, oldAtom);
  } else {
    JSValue exception = attributes->setAttribute(name, attributeAtom);
    if (JS_IsException(exception))
      return exception;
    element->_didModifyAttribute(name, JS_ATOM_NULL, attributeAtom);
  }

  std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, attributeString);

  ::foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);

  JS_FreeValue(ctx, attributeString);
  JS_FreeAtom(ctx, attributeAtom);

  return JS_NULL;
}

JSValue Element::getAttribute(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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
    return JS_AtomToValue(ctx, attributes->getAttribute(name));
  }

  return JS_NULL;
}

JSValue Element::removeAttribute(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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
    JSAtom id = attributes->getAttribute(name);
    element->m_attributes->removeAttribute(name);
    element->_didModifyAttribute(name, id, JS_ATOM_NULL);

    std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
    ::foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::removeProperty, *args_01, nullptr);
  }

  return JS_NULL;
}

JSValue Element::toBlob(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  double devicePixelRatio = 1.0;

  if (argc > 0) {
    JSValue devicePixelRatioValue = argv[0];

    if (!JS_IsNumber(devicePixelRatioValue)) {
      return JS_ThrowTypeError(ctx, "Failed to export blob: parameter 2 (devicePixelRatio) is not an number.");
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
    QjsContext* ctx = promiseContext->context->ctx();
    if (error == nullptr) {
      std::vector<uint8_t> vec(bytes, bytes + length);
      JSValue arrayBuffer = JS_NewArrayBuffer(ctx, bytes, length, nullptr, nullptr, false);
      Blob* constructor = Blob::instance(promiseContext->context);
      JSValue argumentsArray = JS_NewArray(ctx);
      JSValue pushMethod = JS_GetPropertyStr(ctx, argumentsArray, "push");
      JS_Call(ctx, pushMethod, argumentsArray, 1, &arrayBuffer);
      JSValue blobValue = JS_CallConstructor(ctx, constructor->classObject, 1, &argumentsArray);

      if (JS_IsException(blobValue)) {
        promiseContext->context->handleException(&blobValue);
      } else {
        JSValue ret = JS_Call(ctx, promiseContext->resolveFunc, promiseContext->promise, 1, &blobValue);
        JS_FreeValue(ctx, ret);
      }

      JS_FreeValue(ctx, pushMethod);
      JS_FreeValue(ctx, blobValue);
      JS_FreeValue(ctx, argumentsArray);
      JS_FreeValue(ctx, arrayBuffer);
    } else {
      JSValue errorObject = JS_NewError(ctx);
      JSValue errorMessage = JS_NewString(ctx, error);
      JS_SetPropertyStr(ctx, errorObject, "message", errorMessage);
      JSValue ret = JS_Call(ctx, promiseContext->rejectFunc, promiseContext->promise, 1, &errorObject);
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

JSValue Element::click(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("click", 0, nullptr);
}

JSValue Element::scroll(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return element->callNativeMethods("scroll", 2, arguments);
}

JSValue Element::scrollBy(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return element->callNativeMethods("scrollBy", 2, arguments);
}

PROP_GETTER(ElementInstance, nodeName)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string tagName = element->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

PROP_SETTER(ElementInstance, nodeName)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, tagName)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string tagName = element->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

PROP_SETTER(ElementInstance, tagName)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, className)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  JSAtom valueAtom = element->m_attributes->getAttribute("class");
  return JS_AtomToString(ctx, valueAtom);
}

PROP_SETTER(ElementInstance, className)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  JSAtom atom = JS_ValueToAtom(ctx, argv[0]);
  element->m_attributes->setAttribute("class", atom);
  std::unique_ptr<NativeString> args_01 = stringToNativeString("class");
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, argv[0]);
  ::foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
  JS_FreeAtom(ctx, atom);
  return JS_NULL;
}

enum class ViewModuleProperty { offsetTop, offsetLeft, offsetWidth, offsetHeight, clientWidth, clientHeight, clientTop, clientLeft, scrollTop, scrollLeft, scrollHeight, scrollWidth };

PROP_GETTER(ElementInstance, offsetLeft)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetLeft))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, offsetLeft)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, offsetTop)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetTop))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, offsetTop)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, offsetWidth)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetWidth))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, offsetWidth)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, offsetHeight)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetHeight))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, offsetHeight)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, clientWidth)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientWidth))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, clientWidth)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, clientHeight)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientHeight))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, clientHeight)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, clientTop)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientTop))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, clientTop)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, clientLeft)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientLeft))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, clientLeft)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, scrollTop)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollTop))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, scrollTop)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollTop)), jsValueToNativeValue(ctx, argv[0])};
  return element->callNativeMethods("setViewModuleProperty", 2, args);
}

PROP_GETTER(ElementInstance, scrollLeft)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollLeft))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, scrollLeft)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollLeft)), jsValueToNativeValue(ctx, argv[0])};
  return element->callNativeMethods("setViewModuleProperty", 2, args);
}

PROP_GETTER(ElementInstance, scrollHeight)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollHeight))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(ElementInstance, scrollHeight)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, scrollWidth)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollWidth))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

PROP_SETTER(ElementInstance, scrollWidth)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

// Definition for firstElementChild
PROP_GETTER(ElementInstance, firstElementChild)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  int32_t len = arrayGetLength(ctx, element->childNodes);

  for (int i = 0; i < len; i++) {
    JSValue v = JS_GetPropertyUint32(ctx, element->childNodes, i);
    auto* instance = static_cast<NodeInstance*>(JS_GetOpaque(v, Node::classId(v)));
    if (instance->nodeType == NodeType::ELEMENT_NODE) {
      return instance->instanceObject;
    }
    JS_FreeValue(ctx, v);
  }

  return JS_NULL;
}

PROP_SETTER(ElementInstance, firstElementChild)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

// Definition for lastElementChild
PROP_GETTER(ElementInstance, lastElementChild)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  int32_t len = arrayGetLength(ctx, element->childNodes);

  for (int i = len - 1; i >= 0; i--) {
    JSValue v = JS_GetPropertyUint32(ctx, element->childNodes, i);
    auto* instance = static_cast<NodeInstance*>(JS_GetOpaque(v, Node::classId(v)));
    if (instance->nodeType == NodeType::ELEMENT_NODE) {
      return instance->instanceObject;
    }
    JS_FreeValue(ctx, v);
  }

  return JS_NULL;
}
PROP_SETTER(ElementInstance, lastElementChild)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, children)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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
PROP_SETTER(ElementInstance, children)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(ElementInstance, innerHTML)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return JS_NewString(ctx, element->innerHTML().c_str());
}
PROP_SETTER(ElementInstance, innerHTML)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  const char* chtml = JS_ToCString(ctx, argv[0]);
  HTMLParser::parseHTML(chtml, strlen(chtml), element);
  JS_FreeCString(ctx, chtml);
  return JS_NULL;
}

PROP_GETTER(ElementInstance, outerHTML)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return JS_NewString(ctx, element->outerHTML().c_str());
}
PROP_SETTER(ElementInstance, outerHTML)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

  JSValue textNodeValue = JS_CallConstructor(m_ctx, TextNode::instance(m_context)->classObject, 1, &content);
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
  // Children toString
  int32_t childLen = arrayGetLength(m_ctx, childNodes);

  if (childLen == 0)
    return s;

  for (int i = 0; i < childLen; i++) {
    JSValue c = JS_GetPropertyUint32(m_ctx, childNodes, i);
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
  std::string id = "id";
  if (m_attributes->hasAttribute(id)) {
    JSAtom v = m_attributes->getAttribute(id);
    document()->removeElementById(v, this);
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
  std::string idKey = "id";
  if (m_attributes->hasAttribute(idKey)) {
    JSAtom v = m_attributes->getAttribute(idKey);
    document()->addElementById(v, this);
  }
}

void ElementInstance::_didModifyAttribute(std::string& name, JSAtom oldId, JSAtom newId) {
  if (name == "id") {
    _beforeUpdateId(oldId, newId);
  }
}

void ElementInstance::_beforeUpdateId(JSAtom oldId, JSAtom newId) {
  if (oldId == newId) {
    return;
  }

  if (oldId != JS_ATOM_NULL) {
    document()->removeElementById(oldId, this);
  }

  if (newId != JS_ATOM_NULL) {
    document()->addElementById(newId, this);
  }
}

ElementInstance::ElementInstance(Element* element, std::string tagName, bool shouldAddUICommand)
    : m_tagName(tagName), NodeInstance(element, NodeType::ELEMENT_NODE, DocumentInstance::instance(Document::instance(element->m_context)), Element::classId(), exoticMethods, "Element") {
  m_attributes = new ElementAttributes(m_context);
  JSValue arguments[] = {instanceObject};
  JSValue style = JS_CallConstructor(m_ctx, CSSStyleDeclaration::instance(m_context)->classObject, 1, arguments);
  m_style = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(style, CSSStyleDeclaration::kCSSStyleDeclarationClassId));

  JS_DefinePropertyValueStr(m_ctx, instanceObject, "style", m_style->instanceObject, JS_PROP_C_W_E);
  JS_DefinePropertyValueStr(m_ctx, instanceObject, "attributes", m_attributes->jsObject, JS_PROP_C_W_E);

  if (shouldAddUICommand) {
    std::unique_ptr<NativeString> args_01 = stringToNativeString(tagName);
    ::foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(m_eventTargetId, UICommand::createElement, *args_01, nativeEventTarget);
  }
}

JSClassExoticMethods ElementInstance::exoticMethods{nullptr, nullptr, nullptr, nullptr, hasProperty, getProperty, setProperty};

StyleDeclarationInstance* ElementInstance::style() {
  return m_style;
}

ElementAttributes* ElementInstance::attributes() {
  return m_attributes;
}

PROP_GETTER(BoundingClientRect, x)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->x);
}
PROP_SETTER(BoundingClientRect, x)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(BoundingClientRect, y)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->y);
}
PROP_SETTER(BoundingClientRect, y)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(BoundingClientRect, width)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->width);
}
PROP_SETTER(BoundingClientRect, width)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(BoundingClientRect, height)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->height);
}
PROP_SETTER(BoundingClientRect, height)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(BoundingClientRect, top)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->top);
}
PROP_SETTER(BoundingClientRect, top)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(BoundingClientRect, right)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->right);
}
PROP_SETTER(BoundingClientRect, right)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(BoundingClientRect, bottom)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->bottom);
}
PROP_SETTER(BoundingClientRect, bottom)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

PROP_GETTER(BoundingClientRect, left)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* boundingClientRect = static_cast<BoundingClientRect*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, boundingClientRect->m_nativeBoundingClientRect->left);
}
PROP_SETTER(BoundingClientRect, left)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

}  // namespace kraken::binding::qjs
