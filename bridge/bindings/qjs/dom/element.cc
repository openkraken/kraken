/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "document.h"
#include "dart_methods.h"
#include "bridge_qjs.h"
#include "bindings/qjs/bom/blob.h"
#include "foundation/bridge_callback.h"

namespace kraken::binding::qjs {

std::once_flag kElementInitOnceFlag;

void bindElement(std::unique_ptr<JSContext> &context) {
  auto *constructor = Element::instance(context.get());
  context->defineGlobalProperty("Element", constructor->classObject);
}

OBJECT_INSTANCE_IMPL(Element);

JSClassID Element::kElementClassId{0};

Element::Element(JSContext *context) : Node(context, "Element") {
  std::call_once(kElementInitOnceFlag, []() {
    JS_NewClassID(&kElementClassId);
  });
}

JSClassID Element::classId() {
  return kElementClassId;
}

static inline bool isNumberIndex(std::string &name) {
  if (name.empty()) return false;
  char f = name[0];
  return f >= '0' && f <= '9';
}

JSValue ElementAttributes::getAttribute(std::string &name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return JS_NULL;
  }

  return m_attributes[name];
}

ElementAttributes::~ElementAttributes() {
  for (auto &attr : m_attributes) {
    JS_FreeValue(m_ctx, attr.second);
  }
}

JSValue ElementAttributes::setAttribute(std::string &name, JSValue value) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return JS_ThrowTypeError(m_ctx,
                             "Failed to execute 'setAttribute' on 'Element': '%s' is not a valid attribute name.",
                             name.c_str());
  }

  m_attributes[name] =  JS_DupValue(m_ctx, value);;

  return JS_NULL;
}

bool ElementAttributes::hasAttribute(std::string &name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    return false;
  }

  return m_attributes.count(name) > 0;
}

void ElementAttributes::removeAttribute(std::string &name) {
  JSValue &value = m_attributes[name];
  JS_FreeValue(m_ctx, value);
  m_attributes.erase(name);
}

void ElementAttributes::copyWith(ElementAttributes *attributes) {
  for (auto &attr : attributes->m_attributes) {
    m_attributes[attr.first] = JS_DupValue(m_ctx, attr.second);
  }
}

JSValue Element::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  if (argc == 0) return JS_ThrowTypeError(ctx, "Illegal constructor");
  JSValue &tagName = argv[0];

  if (!JS_IsString(tagName)) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }

  const char *cName = JS_ToCString(ctx, tagName);
  std::string name = std::string(cName);

  ElementInstance *element;
  if (elementCreatorMap.count(name) > 0) {
    element = elementCreatorMap[name](this, cName);
  } else if (name == "HTML") {
    element = new ElementInstance(this, cName, false);
    element->eventTargetId = HTML_TARGET_ID;
  } else {
    // Fallback to default Element class
    element = new ElementInstance(this, cName, true);
  }

  JS_FreeCString(m_ctx, cName);

  return element->instanceObject;
}

JSValue Element::getBoundingClientRect(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  getDartMethod()->flushUICommand();
  return element->callNativeMethods("getBoundingClientRect", 0, nullptr);
}

JSValue Element::hasAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute 'hasAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue &nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  auto *attributes = element->m_attributes;

  const char *cname = JS_ToCString(ctx, nameValue);
  std::string name = std::string(cname);

  JSValue result = JS_NewBool(ctx, attributes->hasAttribute(name));
  JS_FreeCString(ctx, cname);

  return result;
}

JSValue Element::setAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 2) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute 'setAttribute' on 'Element': 2 arguments required, but only %d present",
                             argc);
  }

  JSValue &nameValue = argv[0];
  JSValue &attributeValue = argv[1];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  std::string name = jsValueToStdString(ctx, nameValue);
  std::transform(name.begin(), name.end(), name.begin(), ::tolower);

  auto *attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    JSValue oldValue = attributes->getAttribute(name);
    JSValue exception = attributes->setAttribute(name, attributeValue);
    if (JS_IsException(exception)) return exception;
    element->_didModifyAttribute(name, oldValue, attributeValue);
  } else {
    JSValue exception = attributes->setAttribute(name, attributeValue);
    if (JS_IsException(exception)) return exception;
    JSValue oldValue = JS_NULL;
    element->_didModifyAttribute(name, oldValue, attributeValue);
  }

  NativeString *args_01 = stringToNativeString(name);
  NativeString *args_02 = jsValueToNativeString(ctx, attributeValue);

  ::foundation::UICommandBuffer::instance(element->m_context->getContextId())
    ->addCommand(element->eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);

  return JS_NULL;
}

JSValue Element::getAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute 'getAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue &nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.");
  }

  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  std::string name = jsValueToStdString(ctx, nameValue);

  auto *attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    return attributes->getAttribute(name);
  }

  return JS_NULL;
}

JSValue Element::removeAttribute(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute 'removeAttribute' on 'Element': 1 argument required, but only 0 present");
  }

  JSValue &nameValue = argv[0];

  if (!JS_IsString(nameValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeAttribute' on 'Element': name attribute is not valid.");
  }

  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  std::string name = jsValueToStdString(ctx, nameValue);
  auto *attributes = element->m_attributes;

  if (attributes->hasAttribute(name)) {
    JSValue idRef = attributes->getAttribute(name);
    element->m_attributes->removeAttribute(name);
    JSValue newValue = JS_NULL;
    element->_didModifyAttribute(name, idRef, newValue);

    NativeString *args_01 = stringToNativeString(name);
    ::foundation::UICommandBuffer::instance(element->m_context->getContextId())
      ->addCommand(element->eventTargetId, UICommand::removeProperty, *args_01, nullptr);
  }

  return JS_NULL;
}

struct ToBlobPromiseContext : public foundation::BridgeCallback::Context {
  explicit ToBlobPromiseContext(int32_t eventTargetId, double devicePixelRatio, JSValue promise,
                                kraken::binding::qjs::JSContext &context, JSValue callback, JSValue secondaryCallback)
    : foundation::BridgeCallback::Context(context, callback, secondaryCallback), eventTargetId(eventTargetId),
      devicePixelRatio(devicePixelRatio), promise(promise) {};

  int32_t eventTargetId;
  double devicePixelRatio;
  JSValue promise;
};

JSValue Element::toBlob(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  double devicePixelRatio = 1.0;

  if (argc > 0) {
    JSValue &devicePixelRatioValue = argv[0];

    if (!JS_IsNumber(devicePixelRatioValue)) {
      return JS_ThrowTypeError(ctx, "Failed to export blob: parameter 2 (devicePixelRatio) is not an number.");
    }

    JS_ToFloat64(ctx, &devicePixelRatio, devicePixelRatioValue);
  }

  if (getDartMethod()->toBlob == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to export blob: dart method (toBlob) is not registered.");
  }

  auto *element = reinterpret_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  getDartMethod()->flushUICommand();
  auto bridge = static_cast<JSBridge *>(element->m_context->getOwner());

  auto blobCallback = [](void *callbackContext, int32_t contextId, const char *error, uint8_t *bytes,
                         int32_t length) {
    auto toBlobPromiseContext = static_cast<ToBlobPromiseContext *>(callbackContext);
    QjsContext *ctx = toBlobPromiseContext->m_context.ctx();
    if (error == nullptr) {
      std::vector<uint8_t> vec(bytes, bytes + length);
      JSValue arrayBuffer = JS_NewArrayBuffer(ctx, bytes, length, nullptr, nullptr, false);
      Blob *constructor = Blob::instance(&toBlobPromiseContext->m_context);
      JSValue argumentsArray = JS_NewArray(ctx);
      JS_SetPropertyUint32(ctx, argumentsArray, 0, arrayBuffer);

      JSValue arguments[] = {
        argumentsArray
      };
      JSValue blobValue = JS_CallConstructor(ctx, constructor->classObject, 1, arguments);
      if (JS_IsException(blobValue)) {
        toBlobPromiseContext->m_context.handleException(&blobValue);
      } else {
        JSValue resolveArguments[] = {
          blobValue
        };
        JS_Call(ctx, toBlobPromiseContext->m_callback, toBlobPromiseContext->promise, 1, resolveArguments);
      }

      JS_FreeValue(ctx, blobValue);
      JS_FreeValue(ctx, arrayBuffer);
    } else {
      JSValue errorObject = JS_NewError(ctx);
      JSValue errorMessage = JS_NewString(ctx, error);
      JS_DefinePropertyValueStr(ctx, errorObject, "message", errorMessage,
                                JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);

      JSValue rejectArguments[] = {
        errorObject
      };
      JS_Call(ctx, toBlobPromiseContext->m_secondaryCallback, toBlobPromiseContext->promise, 1, rejectArguments);
      JS_FreeValue(ctx, errorObject);
    }
  };

  JSValue resolving_funcs[2];
  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);

  auto toBlobPromiseContext = std::make_unique<ToBlobPromiseContext>(
    element->eventTargetId,
    devicePixelRatio,
    promise,
    *element->context(),
    resolving_funcs[0],
    resolving_funcs[1]
  );

  bridge->bridgeCallback->registerCallback<void>(
    std::move(toBlobPromiseContext), [blobCallback](
      foundation::BridgeCallback::Context *callbackContext, int32_t contextId) {
      auto *toBlobPromiseContext = reinterpret_cast<ToBlobPromiseContext *>(callbackContext);
      getDartMethod()->toBlob(callbackContext, contextId, blobCallback, toBlobPromiseContext->eventTargetId,
                              toBlobPromiseContext->devicePixelRatio);
    });

  return promise;
}

JSValue Element::click(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

JSValue Element::scroll(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

JSValue Element::scrollBy(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

std::unordered_map<std::string, ElementCreator> Element::elementCreatorMap{};

void Element::defineElement(const std::string &tagName, ElementCreator creator) {
  if (elementCreatorMap.count(tagName) > 0) return;

  elementCreatorMap[tagName] = creator;
}

PROP_GETTER(Element, nodeName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  std::string tagName = element->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

PROP_SETTER(Element, nodeName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, tagName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  std::string tagName = element->tagName();
  return JS_NewString(ctx, tagName.c_str());
}

PROP_SETTER(Element, tagName)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

enum class ViewModuleProperty {
  offsetTop,
  offsetLeft,
  offsetWidth,
  offsetHeight,
  clientWidth,
  clientHeight,
  clientTop,
  clientLeft,
  scrollTop,
  scrollLeft,
  scrollHeight,
  scrollWidth
};

PROP_GETTER(Element, offsetLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetLeft))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, offsetLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, offsetTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetTop))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, offsetTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, offsetWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetWidth))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, offsetWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, offsetHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::offsetHeight))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, offsetHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, clientWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientWidth))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, clientWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, clientHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientHeight))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, clientHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, clientTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientTop))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, clientTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, clientLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::clientLeft))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, clientLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, scrollTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollTop))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, scrollTop)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, scrollLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollLeft))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, scrollLeft)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, scrollHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollHeight))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, scrollHeight)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, scrollWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue args[] = {
    Native_NewInt32(static_cast<int32_t>(ViewModuleProperty::scrollWidth))
  };
  return element->callNativeMethods("getViewModuleProperty", 1, args);
}
PROP_SETTER(Element, scrollWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

PROP_GETTER(Element, children)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  JSValue array = JS_NewArray(ctx);
  JSValue pushMethod = JS_GetPropertyStr(ctx, array, "push");

  for (auto &childNode : element->childNodes) {
    if (childNode->nodeType == NodeType::ELEMENT_NODE) {
      JSValue arguments[] = {
        JS_DupValue(element->m_ctx, childNode->instanceObject)
      };
      JS_Call(ctx, pushMethod, array, 1, arguments);
    }
  }

  return array;
}
PROP_SETTER(Element, children)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) { return JS_NULL; }

JSClassID ElementInstance::classID() {
  return Element::classId();
}

JSValue ElementInstance::internalGetTextContent() {
  return NodeInstance::internalGetTextContent();
}

void ElementInstance::internalSetTextContent(JSValue content) {}

std::string ElementInstance::tagName() {
  std::string tagName = std::string(m_tagName);
  std::transform(tagName.begin(), tagName.end(), tagName.begin(), ::toupper);
  return tagName;
}

std::string ElementInstance::getRegisteredTagName() {
  return std::string();
}

void ElementInstance::_notifyNodeRemoved(NodeInstance *insertionNode) {
  if (insertionNode->isConnected()) {
    traverseNode(this, [](NodeInstance *node) {
      auto *Element = Element::instance(node->m_context);
      if (node->prototype() == Element) {
        auto element = reinterpret_cast<ElementInstance *>(node);
        element->_notifyChildRemoved();
      }

      return false;
    });
  }
}

void ElementInstance::_notifyChildRemoved() {
  std::string id = "id";
  if (m_attributes->hasAttribute(id)) {
    JSValue v = m_attributes->getAttribute(id);
    document()->removeElementById(v, this);
  }
}

void ElementInstance::_notifyNodeInsert(NodeInstance *insertNode) {
  if (insertNode->isConnected()) {
    traverseNode(this, [](NodeInstance *node) {
      auto *Element = Element::instance(node->m_context);
      if (node->prototype() == Element) {
        auto element = reinterpret_cast<ElementInstance *>(node);
        element->_notifyChildInsert();
      }

      return false;
    });
  }
}

void ElementInstance::_notifyChildInsert() {
  std::string idKey = "id";
  if (m_attributes->hasAttribute(idKey)) {
    JSValue v = m_attributes->getAttribute(idKey);
    document()->addElementById(v, this);
  }
}

void ElementInstance::_didModifyAttribute(std::string &name, JSValue &oldId, JSValue &newId) {
  if (name == "id") {
    _beforeUpdateId(oldId, newId);
  }
}

void ElementInstance::_beforeUpdateId(JSValue &oldId, JSValue &newId) {
  JSAtom oldIdAtom = JS_ValueToAtom(m_ctx, oldId);
  JSAtom newIdAtom = JS_ValueToAtom(m_ctx, newId);

  if (oldIdAtom == newIdAtom) {
    return;
  }

  if (!JS_IsNull(oldId)) {
    document()->removeElementById(oldId, this);
  }

  if (!JS_IsNull(newId)) {
    document()->addElementById(newId, this);
  }
}

ElementInstance::ElementInstance(Element *element, const char *tagName, bool shouldAddUICommand) :
  m_tagName(tagName),
  NodeInstance(element, NodeType::ELEMENT_NODE,
               DocumentInstance::instance(
                 Document::instance(
                   element->m_context)), Element::classId(), exoticMethods, tagName) {

  m_attributes = new ElementAttributes(m_context);
  m_style = new StyleDeclarationInstance(CSSStyleDeclaration::instance(m_context), this);

  JS_DefinePropertyValueStr(m_ctx, instanceObject, "style", m_style->instanceObject,
                            JS_PROP_NORMAL | JS_PROP_ENUMERABLE);
  JS_DefinePropertyValueStr(m_ctx, instanceObject, "attributes", m_attributes->jsObject,
                            JS_PROP_NORMAL | JS_PROP_ENUMERABLE);

  if (shouldAddUICommand) {
    std::string str = std::string(tagName);
    NativeString *args_01 = stringToNativeString(str);
    ::foundation::UICommandBuffer::instance(m_context->getContextId())
      ->addCommand(eventTargetId, UICommand::createElement, *args_01, &nativeEventTarget);
  }
}

JSClassExoticMethods ElementInstance::exoticMethods{
  nullptr,
  nullptr,
  nullptr,
  nullptr,
  nullptr,
  getProperty,
  setProperty
};

JSValue ElementInstance::getProperty(QjsContext *ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(obj, Element::classId()));
  auto *prototype = static_cast<Element *>(element->prototype());
  if (JS_HasProperty(ctx, prototype->m_prototypeObject, atom)) {
    return JS_GetPropertyInternal(ctx, prototype->m_prototypeObject, atom, element->instanceObject, 0);
  }

  const char *ckey = JS_AtomToCString(ctx, atom);
  std::string key = std::string(ckey);
  JS_FreeCString(ctx, ckey);

  if (key.substr(0, 2) == "on") {
    return element->getPropertyHandler(key);
  }

  return JS_DupValue(ctx, element->m_properties[atom]);
}
int ElementInstance::setProperty(QjsContext *ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  auto *element = static_cast<ElementInstance *>(JS_GetOpaque(obj, Element::classId()));
  const char *ckey = JS_AtomToCString(ctx, atom);
  std::string key = std::string(ckey);

  if (key.substr(0, 2) == "on") {
    element->setPropertyHandler(key, value);
  } else {
    JSValue newValue = JS_DupValue(ctx, value);

    element->m_properties[atom] = newValue;

    // Create strong reference and gc can find it.
    std::string privateKey = "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(newValue)));
    JS_DefinePropertyValueStr(ctx, element->instanceObject, privateKey.c_str(), newValue, JS_PROP_NORMAL);
  }

  JS_FreeCString(ctx, ckey);

  return 0;
}

}
