/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "bridge_jsc.h"
#include "dart_methods.h"
#include "eventTarget.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {
using namespace foundation;

void bindElement(std::unique_ptr<JSContext> &context) {
  auto element = JSElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Element", element->classObject);
}

JSElement::JSElement(JSContext *context) : JSNode(context, "Element") {}

JSElement *JSElement::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSElement *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSElement(context);
  }
  return instanceMap[context];
}

JSObjectRef JSElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                           const JSValueRef *arguments, JSValueRef *exception) {
  JSValueRef tagNameValue = arguments[0];
  double targetId;

  if (argumentCount == 2) {
    targetId = JSValueToNumber(ctx, arguments[1], exception);
  } else {
    targetId = NAN;
  }

  auto instance = new ElementInstance(this, tagNameValue, targetId, exception);
  return instance->object;
}

JSElement::ElementInstance::ElementInstance(JSElement *element, const char *tagName)
  : NodeInstance(element, NodeType::ELEMENT_NODE), tagNameStringRef_(JSStringCreateWithUTF8CString(tagName)) {}
JSElement::ElementInstance::ElementInstance(JSElement *element, JSValueRef tagNameValue, double targetId,
                                            JSValueRef *exception)
  : NodeInstance(element, new NativeElement(this), NodeType::ELEMENT_NODE) {
  JSStringRef tagNameStrRef = tagNameStringRef_ = JSValueToStringCopy(element->ctx, tagNameValue, exception);

  JSStringRetain(tagNameStringRef_);

  NativeString tagName{};
  tagName.string = JSStringGetCharactersPtr(tagNameStrRef);
  tagName.length = JSStringGetLength(tagNameStrRef);

  const int32_t argsLength = 1;
  auto **args = new NativeString *[argsLength];
  args[0] = tagName.clone();

  // If target did't set up by constructor parameter, use default eventTargetId.
  if (isnan(targetId)) {
    targetId = eventTargetId;
  }

  // No needs to send create element for BODY element.
  if (targetId == BODY_TARGET_ID) {
    ::foundation::UICommandTaskMessageQueue::instance(element->context->getContextId())
      ->registerCommand(targetId, UICommandType::initBody, args, argsLength, nativeEventTarget);
  } else {
    ::foundation::UICommandTaskMessageQueue::instance(element->context->getContextId())
      ->registerCommand(targetId, UICommandType::createElement, args, argsLength, nativeEventTarget);
  }
}

JSElement::ElementInstance::~ElementInstance() {
  JSStringRelease(tagNameStringRef_);
  if (style != nullptr) {
    JSValueUnprotect(_hostClass->ctx, style->object);
  }
}

JSValueRef JSElement::ElementInstance::getBoundingClientRect(JSContextRef ctx, JSObjectRef function,
                                                             JSObjectRef thisObject, size_t argumentCount,
                                                             const JSValueRef *arguments, JSValueRef *exception) {
  auto elementInstance = reinterpret_cast<JSElement::ElementInstance *>(JSObjectGetPrivate(function));
  getDartMethod()->requestUpdateFrame();
  auto nativeElement = reinterpret_cast<NativeElement *>(elementInstance->nativeEventTarget);
  NativeBoundingClientRect *nativeBoundingClientRect =
    nativeElement->getBoundingClientRect(elementInstance->_hostClass->contextId, elementInstance->eventTargetId);
  auto boundingClientRect = new BoundingClientRect(elementInstance->_hostClass->context, nativeBoundingClientRect);
  return boundingClientRect->jsObject;
}

JSValueRef JSElement::ElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto nativeElement = reinterpret_cast<NativeElement *>(nativeEventTarget);

  if (name == "style") {
    if (style == nullptr) {
      style =
        new CSSStyleDeclaration::StyleDeclarationInstance(CSSStyleDeclaration::instance(_hostClass->context), this);
      JSValueProtect(_hostClass->ctx, style->object);
    }

    return style->object;
  } else if (name == "nodeName") {
    return JSValueMakeString(_hostClass->ctx, tagNameStringRef_);
  } else if (name == "offsetLeft") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetLeft(_hostClass->contextId, eventTargetId));
  } else if (name == "offsetTop") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetTop(_hostClass->contextId, eventTargetId));
  } else if (name == "offsetWidth") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetWidth(_hostClass->contextId, eventTargetId));
  } else if (name == "offsetHeight") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetHeight(_hostClass->contextId, eventTargetId));
  } else if (name == "clientWidth") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientWidth(_hostClass->contextId, eventTargetId));
  } else if (name == "clientHeight") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientHeight(_hostClass->contextId, eventTargetId));
  } else if (name == "clientTop") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientTop(_hostClass->contextId, eventTargetId));
  } else if (name == "clientLeft") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientLeft(_hostClass->contextId, eventTargetId));
  } else if (name == "scrollTop") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollTop(_hostClass->contextId, eventTargetId));
  } else if (name == "scrollLeft") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollLeft(_hostClass->contextId, eventTargetId));
  } else if (name == "scrollHeight") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollHeight(_hostClass->contextId, eventTargetId));
  } else if (name == "scrollWidth") {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollWidth(_hostClass->contextId, eventTargetId));
  } else if (name == "getBoundingClientRect") {
    if (_getBoundingClientRect == nullptr) {
      _getBoundingClientRect =
        propertyBindingFunction(_hostClass->context, this, "getBoundingClientRect", getBoundingClientRect);
    }
    return _getBoundingClientRect;
  } else if (name == "click") {
    if (_click == nullptr) {
      _click = propertyBindingFunction(_hostClass->context, this, "click", click);
    }
    return _click;
  } else if (name == "scroll") {
    if (_scroll == nullptr) {
      _scroll = propertyBindingFunction(_hostClass->context, this, "scroll", scroll);
    }
    return _scroll;
  } else if (name == "scrollBy") {
    if (_scrollBy == nullptr) {
      _scrollBy = propertyBindingFunction(_hostClass->context, this, "scrollBy", scrollBy);
    }
    return _scrollBy;
  } else if (name == "toBlob") {
    if (_toBlob == nullptr) {
      _toBlob = propertyBindingFunction(_hostClass->context, this, "toBlob", toBlob);
    }
    return _toBlob;
  } else if (name == "getAttribute") {
    if (_getAttribute == nullptr) {
      _getAttribute = propertyBindingFunction(_hostClass->context, this, "getAttribute", getAttribute);
    }
    return _getAttribute;
  } else if (name == "setAttribute") {
    if (_setAttribute == nullptr) {
      _setAttribute = propertyBindingFunction(_hostClass->context, this, "setAttribute", setAttribute);
    }
    return _setAttribute;
  } else if (name == "children") {
    JSValueRef arguments[childNodes.size()];

    size_t elementCount = 0;
    for (int i = 0; i < childNodes.size(); i++) {
      if (childNodes[i]->nodeType == NodeType::ELEMENT_NODE) {
        arguments[i] = childNodes[i]->object;
        elementCount++;
      }
    }

    return JSObjectMakeArray(_hostClass->ctx, elementCount, arguments, nullptr);
  }

  return JSNode::NodeInstance::getProperty(name, exception);
}

void JSElement::ElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  NodeInstance::getPropertyNames(accumulator);

  for (auto &property : getElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSStringRef JSElement::ElementInstance::internalTextContent() {
  std::vector<char> buffer;

  for (auto &node : childNodes) {
    JSStringRef nodeText = node->internalTextContent();
    size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(nodeText);
    std::vector<char> nodeBuffer(maxBufferSize);
    JSStringGetUTF8CString(nodeText, nodeBuffer.data(), maxBufferSize);
    std::string nodeString = std::string(nodeBuffer.data());
    buffer.reserve(buffer.size() + nodeString.size());
    buffer.insert(buffer.end(), nodeString.begin(), nodeString.end());
  }

  return JSStringCreateWithUTF8CString(buffer.data());
}

std::array<JSStringRef, 1> &JSElement::ElementInstance::getElementPropertyNames() {
  static std::array<JSStringRef, 1> propertyNames{JSStringCreateWithUTF8CString("style")};
  return propertyNames;
}

JSValueRef JSElement::ElementInstance::setAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                    size_t argumentCount, const JSValueRef arguments[],
                                                    JSValueRef *exception) {
  if (argumentCount != 2) {
    JSC_THROW_ERROR(ctx,
                    ("Failed to execute 'setAttribute' on 'Element': 2 arguments required, but only " +
                     std::to_string(argumentCount) + " present")
                      .c_str(),
                    exception);
    return nullptr;
  }

  const JSValueRef nameValueRef = arguments[0];
  const JSValueRef attributeValueRef = arguments[1];

  if (!JSValueIsString(ctx, nameValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.", exception);
    return nullptr;
  }

  if (!JSValueIsString(ctx, attributeValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setAttribute' on 'Element': value is not valid.", exception);
    return nullptr;
  }

  JSStringRef nameStringRef = JSValueToStringCopy(ctx, nameValueRef, exception);
  JSStringRef valueStringRef = JSValueToStringCopy(ctx, attributeValueRef, exception);
  std::string &&name = JSStringToStdString(nameStringRef);

  auto elementInstance = reinterpret_cast<JSElement::ElementInstance *>(JSObjectGetPrivate(function));

  JSStringRetain(valueStringRef);
  elementInstance->attributes[name] = valueStringRef;

  return nullptr;
}

JSValueRef JSElement::ElementInstance::getAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                    size_t argumentCount, const JSValueRef *arguments,
                                                    JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'getAttribute' on 'Element': 1 argument required, but only 0 present",
                    exception);
    return nullptr;
  }

  const JSValueRef nameValueRef = arguments[0];

  if (!JSValueIsString(ctx, nameValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.", exception);
    return nullptr;
  }

  JSStringRef nameStringRef = JSValueToStringCopy(ctx, nameValueRef, exception);
  std::string &&name = JSStringToStdString(nameStringRef);
  auto elementInstance = reinterpret_cast<JSElement::ElementInstance *>(JSObjectGetPrivate(function));
  if (elementInstance->attributes.contains(name)) {
    return JSValueMakeString(ctx, elementInstance->attributes[name]);
  }

  return nullptr;
}

struct ToBlobPromiseContext {
  ToBlobPromiseContext() = delete;
  ToBlobPromiseContext(JSBridge *bridge, JSContext *context, double id, double devicePixelRatio)
    : id(id), devicePixelRatio(devicePixelRatio), bridge(bridge), context(context){};
  double id;
  double devicePixelRatio;
  JSBridge *bridge;
  JSContext *context;
};

JSValueRef JSElement::ElementInstance::toBlob(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                              size_t argumentCount, const JSValueRef *arguments,
                                              JSValueRef *exception) {
  const JSValueRef &idValueRef = arguments[0];
  const JSValueRef &devicePixelRatioValueRef = arguments[1];
  const JSValueRef &callbackValueRef = arguments[2];

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));

  if (!JSValueIsNumber(ctx, idValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: missing element's id.", exception);
    return nullptr;
  }

  if (!JSValueIsNumber(ctx, devicePixelRatioValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: parameter 2 (devicePixelRatio) is not an number.", exception);
    return nullptr;
  }

  if (!JSValueIsObject(ctx, callbackValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackValueRef, exception);

  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  if (getDartMethod()->toBlob == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: dart method (toBlob) is not registered.", exception);
    return nullptr;
  }

  double id = JSValueToNumber(ctx, idValueRef, exception);
  double devicePixelRatio = JSValueToNumber(ctx, devicePixelRatioValueRef, exception);
  auto bridge = static_cast<JSBridge *>(context->getOwner());

  auto toBlobPromiseContext = new ToBlobPromiseContext(bridge, context, id, devicePixelRatio);

  auto promiseCallback = [](JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception) -> JSValueRef {
    const JSValueRef resolveValueRef = arguments[0];
    const JSValueRef rejectValueRef = arguments[1];

    auto toBlobPromiseContext = reinterpret_cast<ToBlobPromiseContext *>(JSObjectGetPrivate(function));
    auto callbackContext = std::make_unique<foundation::BridgeCallback::Context>(
      *toBlobPromiseContext->context, resolveValueRef, rejectValueRef, exception);

    auto handleTransientToBlobCallback = [](void *ptr, int32_t contextId, const char *error, uint8_t *bytes,
                                            int32_t length) {
      auto callbackContext = static_cast<BridgeCallback::Context *>(ptr);
      JSContext &_context = callbackContext->_context;
      JSContextRef ctx = callbackContext->_context.context();

      JSValueRef resolveValueRef = callbackContext->_callback;
      JSValueRef rejectValueRef = callbackContext->_secondaryCallback;

      if (!checkContext(contextId, &_context)) return;
      if (error != nullptr) {
        JSStringRef errorStringRef = JSStringCreateWithUTF8CString(error);
        const JSValueRef arguments[] = {JSValueMakeString(ctx, errorStringRef)};
        JSObjectRef rejectObjectRef = JSValueToObject(ctx, rejectValueRef, nullptr);
        JSObjectCallAsFunction(ctx, rejectObjectRef, callbackContext->_context.global(), 1, arguments, nullptr);
      } else {
        std::vector<uint8_t> vec(bytes, bytes + length);
        JSObjectRef resolveObjectRef = JSValueToObject(ctx, resolveValueRef, nullptr);
        auto blob = new JSBlob(&callbackContext->_context, std::move(vec));
        const JSValueRef arguments[] = {blob->jsObject};

        JSObjectCallAsFunction(ctx, resolveObjectRef, callbackContext->_context.global(), 1, arguments, nullptr);
      }
    };

    toBlobPromiseContext->bridge->bridgeCallback->registerCallback<void>(
      std::move(callbackContext), [toBlobPromiseContext, handleTransientToBlobCallback](
                                    BridgeCallback::Context *callbackContext, int32_t contextId) {
        getDartMethod()->toBlob(callbackContext, contextId, handleTransientToBlobCallback, toBlobPromiseContext->id,
                                toBlobPromiseContext->devicePixelRatio);
      });

    delete toBlobPromiseContext;

    return nullptr;
  };

  return JSObjectMakePromise(context, toBlobPromiseContext, promiseCallback, exception);
}

JSValueRef JSElement::ElementInstance::click(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                             size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto elementInstance = reinterpret_cast<JSElement::ElementInstance *>(JSObjectGetPrivate(function));
  auto nativeElement = reinterpret_cast<NativeElement *>(elementInstance->nativeEventTarget);
  nativeElement->click(elementInstance->_hostClass->contextId, elementInstance->eventTargetId);

  return nullptr;
}

JSValueRef JSElement::ElementInstance::scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                              size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef xValueRef = arguments[0];
  const JSValueRef yValueRef = arguments[1];

  double x = 0.0;
  double y = 0.0;

  if (JSValueIsNumber(ctx, xValueRef) && argumentCount > 0) {
    x = JSValueToNumber(ctx, xValueRef, exception);
  }

  if (JSValueIsNumber(ctx, yValueRef) && argumentCount > 1) {
    y = JSValueToNumber(ctx, yValueRef, exception);
  }

  auto elementInstance = reinterpret_cast<JSElement::ElementInstance *>(JSObjectGetPrivate(function));
  auto nativeElement = reinterpret_cast<NativeElement *>(elementInstance->nativeEventTarget);
  nativeElement->scroll(elementInstance->_hostClass->contextId, elementInstance->eventTargetId, x, y);

  return nullptr;
}

JSValueRef JSElement::ElementInstance::scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef xValueRef = arguments[0];
  const JSValueRef yValueRef = arguments[1];

  double x = 0.0;
  double y = 0.0;

  if (JSValueIsNumber(ctx, xValueRef) && argumentCount > 0) {
    x = JSValueToNumber(ctx, xValueRef, exception);
  }

  if (JSValueIsNumber(ctx, yValueRef) && argumentCount > 1) {
    y = JSValueToNumber(ctx, yValueRef, exception);
  }

  auto elementInstance = reinterpret_cast<JSElement::ElementInstance *>(JSObjectGetPrivate(function));
  auto nativeElement = reinterpret_cast<NativeElement *>(elementInstance->nativeEventTarget);
  nativeElement->scrollBy(elementInstance->_hostClass->contextId, elementInstance->eventTargetId, x, y);

  return nullptr;
}

BoundingClientRect::BoundingClientRect(JSContext *context, NativeBoundingClientRect *boundingClientRect)
  : HostObject(context, "BoundingClientRect"), nativeBoundingClientRect(boundingClientRect) {}

JSValueRef BoundingClientRect::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "x") {
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->x);
  } else if (name == "y") {
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->y);
  } else if (name == "width") {
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->width);
  } else if (name == "height") {
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->height);
  } else if (name == "left") {
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->left);
  } else if (name == "right") {
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->right);
  } else if (name == "bottom") {
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->bottom);
  } else if (name == "top") {
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->top);
  }

  return nullptr;
}

std::array<JSStringRef, 8> &BoundingClientRect::getBoundingClientRectPropertyNames() {
  static std::array<JSStringRef, 8> propertyNames{
    JSStringCreateWithUTF8CString("x"),      JSStringCreateWithUTF8CString("y"),
    JSStringCreateWithUTF8CString("width"),  JSStringCreateWithUTF8CString("height"),
    JSStringCreateWithUTF8CString("top"),    JSStringCreateWithUTF8CString("right"),
    JSStringCreateWithUTF8CString("bottom"), JSStringCreateWithUTF8CString("left"),
  };
  return propertyNames;
}

void BoundingClientRect::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getBoundingClientRectPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

BoundingClientRect::~BoundingClientRect() {
  delete nativeBoundingClientRect;
}

} // namespace kraken::binding::jsc
