/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
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

namespace kraken {

const std::string ATTR_ID = "id";
const std::string ATTR_CLASS = "class";
const std::string ATTR_STYLE = "style";

void bindElement(std::unique_ptr<ExecutionContext>& context) {
  JSValue classObject = Element::constructor(context.get());
  JSValue prototype = Element::prototype(context.get());

  // Install methods on prototype.
  INSTALL_FUNCTION(Element, prototype, getBoundingClientRect, 0);
  INSTALL_FUNCTION(Element, prototype, hasAttribute, 1);
  INSTALL_FUNCTION(Element, prototype, setAttribute, 2);
  INSTALL_FUNCTION(Element, prototype, getAttribute, 2);
  INSTALL_FUNCTION(Element, prototype, removeAttribute, 1);
  INSTALL_FUNCTION(Element, prototype, toBlob, 0);
  INSTALL_FUNCTION(Element, prototype, click, 2);
  INSTALL_FUNCTION(Element, prototype, scroll, 2);
  // ScrollTo is same as scroll which reuse scroll functions. Macro expand is not support here.
  installFunctionProperty(context.get(), prototype, "scrollTo", Element::m_scroll_, 1);
  INSTALL_FUNCTION(Element, prototype, scrollBy, 2);

  // Install Getter and Setter properties.
  // Install readonly properties.
  INSTALL_READONLY_PROPERTY(Element, prototype, nodeName);
  INSTALL_READONLY_PROPERTY(Element, prototype, tagName);
  INSTALL_READONLY_PROPERTY(Element, prototype, offsetLeft);
  INSTALL_READONLY_PROPERTY(Element, prototype, offsetTop);
  INSTALL_READONLY_PROPERTY(Element, prototype, offsetWidth);
  INSTALL_READONLY_PROPERTY(Element, prototype, offsetHeight);
  INSTALL_READONLY_PROPERTY(Element, prototype, clientWidth);
  INSTALL_READONLY_PROPERTY(Element, prototype, clientHeight);
  INSTALL_READONLY_PROPERTY(Element, prototype, clientTop);
  INSTALL_READONLY_PROPERTY(Element, prototype, clientLeft);
  INSTALL_READONLY_PROPERTY(Element, prototype, scrollHeight);
  INSTALL_READONLY_PROPERTY(Element, prototype, scrollWidth);
  INSTALL_READONLY_PROPERTY(Element, prototype, firstElementChild);
  INSTALL_READONLY_PROPERTY(Element, prototype, lastElementChild);
  INSTALL_READONLY_PROPERTY(Element, prototype, children);
  INSTALL_READONLY_PROPERTY(Element, prototype, attributes);

  // Install properties.
  INSTALL_PROPERTY(Element, prototype, id);
  INSTALL_PROPERTY(Element, prototype, className);
  INSTALL_PROPERTY(Element, prototype, style);
  INSTALL_PROPERTY(Element, prototype, innerHTML);
  INSTALL_PROPERTY(Element, prototype, outerHTML);
  INSTALL_PROPERTY(Element, prototype, scrollTop);
  INSTALL_PROPERTY(Element, prototype, scrollLeft);

  context->defineGlobalProperty("Element", classObject);
  context->defineGlobalProperty("HTMLElement", JS_DupValue(context->ctx(), classObject));
}

bool isJavaScriptExtensionElementInstance(ExecutionContext* context, JSValue instance) {
  JSValue classObject = context->contextData()->constructorForType(&elementTypeInfo);
  if (JS_IsInstanceOf(context->ctx(), instance, classObject)) {
    auto* elementInstance = static_cast<Element*>(JS_GetOpaque(instance, Element::classId));
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

JSClassID NamedNodeMap::classId{0};

JSValue NamedNodeMap::getNamedItem(const std::string& name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return JS_NULL;
  }

  return JS_DupValue(m_ctx, m_map[name]);
}

JSValue NamedNodeMap::setNamedItem(const std::string& name, JSValue value) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return JS_ThrowTypeError(m_ctx, "Failed to execute 'setNamedItem' on 'NamedNodeMap': '%s' is not a valid item name.", name.c_str());
  }

  if (name == "class") {
    std::string classNameString = jsValueToStdString(m_ctx, value);
    m_className->set(classNameString);
  }

  // If item exists, should free the previous value.
  if (m_map.count(name) > 0) {
    JS_FreeValue(m_ctx, m_map[name]);
  }

  m_map[name] = JS_DupValue(m_ctx, value);

  return JS_NULL;
}

bool NamedNodeMap::hasNamedItem(std::string& name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return false;
  }

  return m_map.count(name) > 0;
}

void NamedNodeMap::removeNamedItem(std::string& name) {
  JSValue value = m_map[name];
  JS_FreeValue(m_ctx, value);
  m_map.erase(name);
}

void NamedNodeMap::copyWith(NamedNodeMap* map) {
  for (auto& item : map->m_map) {
    m_map[item.first] = JS_DupValue(m_ctx, item.second);
  }
}

std::string NamedNodeMap::toString() {
  std::string s;

  for (auto& item : m_map) {
    s += item.first + "=";
    const char* pstr = JS_ToCString(m_ctx, item.second);
    s += "\"" + std::string(pstr) + "\"";
    JS_FreeCString(m_ctx, pstr);
  }

  return s;
}

void NamedNodeMap::dispose() const {
  for (auto& item : m_map) {
    JS_FreeValueRT(m_runtime, item.second);
  }
}

void NamedNodeMap::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  for (auto& item : m_map) {
    JS_MarkValue(rt, item.second, mark_func);
  }
}

JSClassID Element::classId{0};

Element* Element::create(JSContext* ctx) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue prototype = context->contextData()->prototypeForType(&elementTypeInfo);
  auto* element = makeGarbageCollected<Element>()->initialize<Element>(ctx, &classId);
  // Let eventTarget instance inherit EventTarget prototype methods.
  JS_SetPrototype(ctx, element->toQuickJS(), prototype);
  return element;
}

JSValue Element::constructor(ExecutionContext* context) {
  return context->contextData()->constructorForType(&elementTypeInfo);
}

JSValue Element::prototype(ExecutionContext* context) {
  return context->contextData()->prototypeForType(&elementTypeInfo);
}

// JSValue Element::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
//  if (argc == 0)
//    return JS_ThrowTypeError(ctx, "Illegal constructor");
//  JSValue tagName = argv[0];
//
//  if (!JS_IsString(tagName)) {
//    return JS_ThrowTypeError(ctx, "Illegal constructor");
//  }
//
//  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
//  std::string name = jsValueToStdString(ctx, tagName);
//
//  auto* Document = Document::instance(context);
//  if (Document->isCustomElement(name)) {
//    return JS_CallConstructor(ctx, Document->getElementConstructor(context, name), argc, argv);
//  }
//
//  auto* element = new Element(this, name, true);
//  return element->jsObject;
//}

IMPL_FUNCTION(Element, getBoundingClientRect)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  getDartMethod()->flushUICommand();
  return element->callNativeMethods("getBoundingClientRect", 0, nullptr);
}

IMPL_FUNCTION(Element, hasAttribute)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'hasAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'hasAttribute' on 'Element': name attribute is not valid.");
  }

  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  auto* attributes = element->m_attributes;

  const char* cname = JS_ToCString(ctx, nameValue);
  std::string name = std::string(cname);

  JSValue result = JS_NewBool(ctx, attributes->hasNamedItem(name));
  JS_FreeCString(ctx, cname);

  return result;
}

IMPL_FUNCTION(Element, setAttribute)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': 2 arguments required, but only %d present", argc);
  }

  JSValue nameValue = argv[0];
  JSValue attributeValue = JS_ToString(ctx, argv[1]);

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  std::string name = jsValueToStdString(ctx, nameValue);
  std::transform(name.begin(), name.end(), name.begin(), ::tolower);

  auto* attributes = element->m_attributes;

  if (name == ATTR_STYLE) {
    auto* style = element->m_style;
    style->setCssText(jsValueToStdString(ctx, attributeValue));
  }

  if (attributes->hasNamedItem(name)) {
    JSValue oldAttribute = attributes->getNamedItem(name);
    JSValue exception = attributes->setNamedItem(name, attributeValue);
    if (JS_IsException(exception))
      return exception;
    element->_didModifyAttribute(name, oldAttribute, attributeValue);
    JS_FreeValue(ctx, oldAttribute);
  } else {
    JSValue exception = attributes->setNamedItem(name, attributeValue);
    if (JS_IsException(exception))
      return exception;
    element->_didModifyAttribute(name, JS_NULL, attributeValue);
  }

  std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, attributeValue);

  element->context()->uiCommandBuffer()->addCommand(element->eventTargetId(), UICommand::setProperty, *args_01, *args_02, nullptr);

  JS_FreeValue(ctx, attributeValue);

  return JS_NULL;
}

IMPL_FUNCTION(Element, getAttribute)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'getAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  std::string name = jsValueToStdString(ctx, nameValue);

  auto* attributes = element->m_attributes;

  if (attributes->hasNamedItem(name)) {
    return attributes->getNamedItem(name);
  }

  return JS_NULL;
}

IMPL_FUNCTION(Element, removeAttribute)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeAttribute' on 'Element': name attribute is not valid.");
  }

  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  std::string name = jsValueToStdString(ctx, nameValue);
  auto* attributes = element->m_attributes;

  if (attributes->hasNamedItem(name)) {
    JSValue targetValue = attributes->getNamedItem(name);
    attributes->removeNamedItem(name);
    element->_didModifyAttribute(name, targetValue, JS_NULL);
    JS_FreeValue(ctx, targetValue);

    std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
    element->context()->uiCommandBuffer()->addCommand(element->eventTargetId(), UICommand::removeProperty, *args_01, nullptr);
  }

  return JS_NULL;
}

IMPL_FUNCTION(Element, toBlob)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

  auto* element = reinterpret_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
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

IMPL_FUNCTION(Element, click)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
#if FLUTTER_BACKEND
  getDartMethod()->flushUICommand();
  auto element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  return element->callNativeMethods("click", 0, nullptr);
#elif UNIT_TEST
  auto element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  TEST_dispatchEvent(element, "click");
  return JS_UNDEFINED;
#else
  return JS_UNDEFINED;
#endif
}

IMPL_FUNCTION(Element, scroll)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return element->callNativeMethods("scroll", 2, arguments);
}

IMPL_FUNCTION(Element, scrollBy)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return element->callNativeMethods("scrollBy", 2, arguments);
}

IMPL_PROPERTY_GETTER(Element, nodeName)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  std::string tagName = element->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

IMPL_PROPERTY_GETTER(Element, tagName)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  std::string tagName = element->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

IMPL_PROPERTY_GETTER(Element, className)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  return element->getAttribute(ATTR_CLASS);
}

IMPL_PROPERTY_SETTER(Element, className)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  element->setAttribute(ATTR_CLASS, argv[0]);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Element, id)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  return element->getAttribute(ATTR_ID;
}

IMPL_PROPERTY_SETTER(Element, id)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  element->setAttribute(ATTR_ID, argv[0]);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Element, style)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  // The style property must return a CSS declaration block object.
  return element->m_style;
}

IMPL_PROPERTY_SETTER(Element, style)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  element->setAttribute(ATTR_STYLE, argv[0]);
  return JS_NULL;
}

enum class ViewModuleProperty { offsetTop, offsetLeft, offsetWidth, offsetHeight, clientWidth, clientHeight, clientTop, clientLeft, scrollTop, scrollLeft, scrollHeight, scrollWidth };

IMPL_PROPERTY_GETTER(Element, offsetLeft)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetLeft))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_GETTER(Element, offsetTop)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetTop))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_GETTER(Element, offsetWidth)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetWidth))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_GETTER(Element, offsetHeight)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetHeight))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_GETTER(Element, clientWidth)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientWidth))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_GETTER(Element, clientHeight)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientHeight))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_GETTER(Element, clientTop)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientTop))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_GETTER(Element, clientLeft)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientLeft))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_GETTER(Element, scrollTop)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollTop))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_SETTER(Element, scrollTop)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollTop)), jsValueToNativeValue(ctx, argv[0])};
  return element->callNativeMethods("setViewModuleProperty", 2, args);
}

IMPL_PROPERTY_GETTER(Element, scrollLeft)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollLeft))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
IMPL_PROPERTY_SETTER(Element, scrollLeft)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollLeft)), jsValueToNativeValue(ctx, argv[0])};
  return element->callNativeMethods("setViewModuleProperty", 2, args);
}

IMPL_PROPERTY_GETTER(Element, scrollHeight)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollHeight))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

IMPL_PROPERTY_GETTER(Element, scrollWidth)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  NativeValue args[] = {Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollWidth))};
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}

// Definition for firstElementChild
IMPL_PROPERTY_GETTER(Element, firstElementChild)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
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
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
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
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
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
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  return JS_DupValue(ctx, element->m_attributes->toQuickJS());
}

IMPL_PROPERTY_GETTER(Element, innerHTML)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  return JS_NewString(ctx, element->innerHTML().c_str());
}

IMPL_PROPERTY_SETTER(Element, innerHTML)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  const char* chtml = JS_ToCString(ctx, argv[0]);

  if (element->hasNodeFlag(NodeInstance::NodeFlag::IsTemplateElement)) {
    auto* templateElement = static_cast<TemplateElementInstance*>(element);
    HTMLParser::parseHTML(chtml, strlen(chtml), templateElement->content());
  } else {
    HTMLParser::parseHTML(chtml, strlen(chtml), element);
  }

  JS_FreeCString(ctx, chtml);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Element, outerHTML)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<Element*>(JS_GetOpaque(this_val, Element::classId));
  return JS_NewString(ctx, element->outerHTML().c_str());
}

IMPL_PROPERTY_SETTER(Element, outerHTML)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

// JSClassID Element::classId {
//  return Element::classId;
//}

// Element::~Element() {}

JSValue Element::internalGetTextContent() {
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

void Element::internalSetTextContent(JSValue content) {
  internalClearChild();

  JSValue textNodeValue = JS_CallConstructor(m_ctx, TextNode::instance(m_context)->jsObject, 1, &content);
  auto* textNodeInstance = static_cast<TextNodeInstance*>(JS_GetOpaque(textNodeValue, TextNode::classId()));
  internalAppendChild(textNodeInstance);
  JS_FreeValue(m_ctx, textNodeValue);
}

std::shared_ptr<SpaceSplitString> Element::classNames() {
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

std::string Element::tagName() {
  std::string tagName = std::string(m_tagName);
  std::transform(tagName.begin(), tagName.end(), tagName.begin(), ::toupper);
  return tagName;
}

std::string Element::getRegisteredTagName() {
  return m_tagName;
}

std::string Element::outerHTML() {
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

std::string Element::innerHTML() {
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
      s += reinterpret_cast<Element*>(node)->outerHTML();
    } else if (node->nodeType == NodeType::TEXT_NODE) {
      s += reinterpret_cast<TextNodeInstance*>(node)->toString();
    }

    JS_FreeValue(m_ctx, c);
  }
  return s;
}

void Element::_notifyNodeRemoved(NodeInstance* insertionNode) {
  if (insertionNode->isConnected()) {
    traverseNode(this, [](NodeInstance* node) {
      auto* Element = Element::instance(node->m_context);
      if (node->prototype() == Element) {
        auto element = reinterpret_cast<Element*>(node);
        element->_notifyChildRemoved();
      }

      return false;
    });
  }
}

void Element::_notifyChildRemoved() {
  if (m_attributes->hasNamedItem(ATTR_ID)) {
    JSValue idValue = m_attributes->getNamedItem(ATTR_ID);
    JSAtom id = JS_ValueToAtom(m_ctx, idValue);
    document()->removeElementById(id, this);
    JS_FreeValue(m_ctx, idValue);
    JS_FreeAtom(m_ctx, id);
  }
}

void Element::_notifyNodeInsert(NodeInstance* insertNode) {
  if (insertNode->isConnected()) {
    traverseNode(this, [](NodeInstance* node) {
      auto* Element = Element::instance(node->m_context);
      if (node->prototype() == Element) {
        auto element = reinterpret_cast<Element*>(node);
        element->_notifyChildInsert();
      }

      return false;
    });
  }
}

void Element::_notifyChildInsert() {
  if (m_attributes->hasNamedItem(ATTR_ID)) {
    JSValue idValue = m_attributes->getNamedItem(ATTR_ID);
    JSAtom id = JS_ValueToAtom(m_ctx, idValue);
    document()->addElementById(id, this);
    JS_FreeValue(m_ctx, idValue);
    JS_FreeAtom(m_ctx, id);
  }
}

void Element::_didModifyAttribute(std::string& name, JSValue oldId, JSValue newId) {
  if (name == ATTR_ID) {
    _beforeUpdateId(oldId, newId);
  }
}

void Element::_beforeUpdateId(JSValue oldIdValue, JSValue newIdValue) {
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

void Element::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  if (m_attributes != nullptr) {
    JS_MarkValue(rt, m_attributes->toQuickJS(), mark_func);
  }
  NodeInstance::trace(rt, val, mark_func);
}

// Element::Element(Element* element, std::string tagName, bool shouldAddUICommand): Node() {
//  m_attributes = makeGarbageCollected<NamedNodeMap>()->initialize(m_ctx, &NamedNodeMap::classId);
//  JSValue arguments[] = {jsObject};
//  JSValue style = JS_CallConstructor(m_ctx, CSSStyleDeclaration::instance(m_context)->jsObject, 1, arguments);
//  m_style = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(style, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
//
//  JS_DefinePropertyValueStr(m_ctx, jsObject, "style", m_style->jsObject, JS_PROP_C_W_E);
//
//  if (shouldAddUICommand) {
//    std::unique_ptr<NativeString> args_01 = stringToNativeString(tagName);
//    element->m_context->uiCommandBuffer()->addCommand(m_eventTargetId, UICommand::createElement, *args_01, nativeEventTarget);
//  }
//}

JSClassExoticMethods Element::exoticMethods{nullptr, nullptr, nullptr, nullptr, hasProperty, getProperty, setProperty};

void Element::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {}
void Element::dispose() const {}

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

}  // namespace kraken
