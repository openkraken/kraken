/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "bridge_jsc.h"
#include "dart_methods.h"
#include "event_target.h"
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
  : NodeInstance(element, NodeType::ELEMENT_NODE), nativeElement(new NativeElement(nativeNode)),
    tagNameStringRef_(JSStringRetain(JSStringCreateWithUTF8CString(tagName))) {}

JSElement::ElementInstance::ElementInstance(JSElement *element, JSValueRef tagNameValue, double targetId,
                                            JSValueRef *exception)
  : NodeInstance(element, NodeType::ELEMENT_NODE), nativeElement(new NativeElement(nativeNode)) {
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
    getDartMethod()->initBody(element->contextId, nativeElement);
  } else {
    ::foundation::UICommandTaskMessageQueue::instance(element->context->getContextId())
      ->registerCommand(targetId, UICommandType::createElement, args, argsLength, nativeElement);
  }
}

JSElement::ElementInstance::~ElementInstance() {
  JSStringRelease(tagNameStringRef_);
  if (style != nullptr && context->isValid()) JSValueUnprotect(_hostClass->ctx, style->object);
  delete nativeElement;
}

JSValueRef JSElement::ElementInstance::getBoundingClientRect(JSContextRef ctx, JSObjectRef function,
                                                             JSObjectRef thisObject, size_t argumentCount,
                                                             const JSValueRef *arguments, JSValueRef *exception) {
  auto elementInstance = reinterpret_cast<JSElement::ElementInstance *>(JSObjectGetPrivate(function));
  getDartMethod()->requestUpdateFrame();
  NativeBoundingClientRect *nativeBoundingClientRect =
    elementInstance->nativeElement->getBoundingClientRect(elementInstance->nativeElement);
  auto boundingClientRect = new BoundingClientRect(elementInstance->context, nativeBoundingClientRect);
  return boundingClientRect->jsObject;
}

const std::unordered_map<std::string, JSElement::ElementProperty> &JSElement::ElementInstance::getElementPropertyMap() {
  static const std::unordered_map<std::string, ElementProperty> propertyHandler = {
    {"style", ElementProperty::kStyle},
    {"nodeName", ElementProperty::kNodeName},
    {"offsetLeft", ElementProperty::kOffsetLeft},
    {"offsetTop", ElementProperty::kOffsetTop},
    {"offsetWidth", ElementProperty::kOffsetWidth},
    {"offsetHeight", ElementProperty::kOffsetHeight},
    {"clientWidth", ElementProperty::kClientWidth},
    {"clientHeight", ElementProperty::kClientHeight},
    {"clientTop", ElementProperty::kClientTop},
    {"clientLeft", ElementProperty::kClientLeft},
    {"scrollTop", ElementProperty::kScrollTop},
    {"scrollLeft", ElementProperty::kScrollLeft},
    {"scrollHeight", ElementProperty::kScrollHeight},
    {"scrollWidth", ElementProperty::kScrollWidth},
    {"getBoundingClientRect", ElementProperty::kGetBoundingClientRect},
    {"click", ElementProperty::kClick},
    {"scroll", ElementProperty::kScroll},
    {"scrollBy", ElementProperty::kScrollBy},
    {"toBlob", ElementProperty::kToBlob},
    {"getAttribute", ElementProperty::kGetAttribute},
    {"setAttribute", ElementProperty::kSetAttribute},
    {"children", ElementProperty::kChildren}};
  return propertyHandler;
}

JSValueRef JSElement::ElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getElementPropertyMap();

  if (!propertyMap.contains(name)) {
    return JSNode::NodeInstance::getProperty(name, exception);
  }

  ElementProperty property = propertyMap[name];

  switch (property) {
  case ElementProperty::kStyle: {
    if (style == nullptr) {
      style =
        new CSSStyleDeclaration::StyleDeclarationInstance(CSSStyleDeclaration::instance(context), this);
      JSValueProtect(_hostClass->ctx, style->object);
    }

    return style->object;
  }
  case ElementProperty::kNodeName:
    return JSValueMakeString(_hostClass->ctx, tagNameStringRef_);
  case ElementProperty::kOffsetLeft: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetLeft(nativeElement));
  }
  case ElementProperty::kOffsetTop: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetTop(nativeElement));
  }
  case ElementProperty::kOffsetWidth: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetWidth(nativeElement));
  }
  case ElementProperty::kOffsetHeight: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetHeight(nativeElement));
  }
  case ElementProperty::kClientWidth: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientWidth(nativeElement));
  }
  case ElementProperty::kClientHeight: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientHeight(nativeElement));
  }
  case ElementProperty::kClientTop: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientTop(nativeElement));
  }
  case ElementProperty::kClientLeft: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientLeft(nativeElement));
  }
  case ElementProperty::kScrollTop: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollTop(nativeElement));
  }
  case ElementProperty::kScrollLeft: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollLeft(nativeElement));
  }
  case ElementProperty::kScrollHeight: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollHeight(nativeElement));
  }
  case ElementProperty::kScrollWidth: {
    getDartMethod()->requestUpdateFrame();
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollWidth(nativeElement));
  }
  case ElementProperty::kGetBoundingClientRect: {
    return m_getBoundingClientRect.function();
  }
  case ElementProperty::kClick: {
    return m_click.function();
  }
  case ElementProperty::kScroll: {
    return m_scroll.function();
  }
  case ElementProperty::kScrollBy: {
    return m_scrollBy.function();
  }
  case ElementProperty::kToBlob: {
    return m_toBlob.function();
  }
  case ElementProperty::kGetAttribute: {
    return m_getAttribute.function();
  }
  case ElementProperty::kSetAttribute: {
    return m_setAttribute.function();
  }
  case ElementProperty::kChildren: {
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
  }

  return nullptr;
}

void JSElement::ElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getElementPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    switch (property) {
    case ElementProperty::kScrollTop:
      getDartMethod()->requestUpdateFrame();
      nativeElement->setScrollTop(nativeElement, JSValueToNumber(_hostClass->ctx, value, exception));
      break;
    case ElementProperty::kScrollLeft:
      getDartMethod()->requestUpdateFrame();
      nativeElement->setScrollLeft(nativeElement, JSValueToNumber(_hostClass->ctx, value, exception));
      break;
    default:
      break;
    }
  }

  NodeInstance::setProperty(name, value, exception);
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

std::vector<JSStringRef> &JSElement::ElementInstance::getElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{JSStringCreateWithUTF8CString("style"),
                                                JSStringCreateWithUTF8CString("getAttribute"),
                                                JSStringCreateWithUTF8CString("setAttribute")};
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

  getDartMethod()->requestUpdateFrame();

  auto elementInstance = reinterpret_cast<JSElement::ElementInstance *>(JSObjectGetPrivate(function));

  JSStringRetain(valueStringRef);
  elementInstance->attributes[name] = valueStringRef;

  std::string valueString = JSStringToStdString(valueStringRef);
  auto args = buildUICommandArgs(name, valueString);

  ::foundation::UICommandTaskMessageQueue::instance(elementInstance->_hostClass->contextId)
    ->registerCommand(elementInstance->eventTargetId, UICommandType::setProperty, args, 2, nullptr);

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
  const JSValueRef &devicePixelRatioValueRef = arguments[0];

  if (!JSValueIsNumber(ctx, devicePixelRatioValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: parameter 2 (devicePixelRatio) is not an number.", exception);
    return nullptr;
  }

  if (getDartMethod()->toBlob == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: dart method (toBlob) is not registered.", exception);
    return nullptr;
  }

  auto elementInstance = reinterpret_cast<JSElement::ElementInstance *>(JSObjectGetPrivate(function));
  auto context = elementInstance->context;
  getDartMethod()->requestUpdateFrame();

  double devicePixelRatio = JSValueToNumber(ctx, devicePixelRatioValueRef, exception);
  auto bridge = static_cast<JSBridge *>(context->getOwner());

  auto toBlobPromiseContext =
    new ToBlobPromiseContext(bridge, context, elementInstance->eventTargetId, devicePixelRatio);

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
        JSBlob *Blob = JSBlob::instance(&callbackContext->_context);
        auto blob = new JSBlob::BlobInstance(Blob, std::move(vec));
        const JSValueRef arguments[] = {blob->object};

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
  getDartMethod()->requestUpdateFrame();
  elementInstance->nativeElement->click(elementInstance->nativeElement);

  return nullptr;
}

JSValueRef JSElement::ElementInstance::scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                              size_t argumentCount, const JSValueRef *arguments,
                                              JSValueRef *exception) {
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
  getDartMethod()->requestUpdateFrame();
  elementInstance->nativeElement->scroll(elementInstance->nativeElement, x, y);

  return nullptr;
}

JSValueRef JSElement::ElementInstance::scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                size_t argumentCount, const JSValueRef *arguments,
                                                JSValueRef *exception) {
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
  getDartMethod()->requestUpdateFrame();
  elementInstance->nativeElement->scrollBy(elementInstance->nativeElement, x, y);

  return nullptr;
}

BoundingClientRect::BoundingClientRect(JSContext *context, NativeBoundingClientRect *boundingClientRect)
  : HostObject(context, "BoundingClientRect"), nativeBoundingClientRect(boundingClientRect) {}

JSValueRef BoundingClientRect::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPropertyMap();

  if (!propertyMap.contains(name)) return nullptr;
  auto property = propertyMap[name];

  switch (property) {
  case kX:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->x);
  case kY:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->y);
  case kWidth:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->width);
  case kHeight:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->height);
  case kLeft:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->left);
  case kTop:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->top);
  case kRight:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->right);
  case kBottom:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->bottom);
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

const std::unordered_map<std::string, BoundingClientRect::BoundingClientRectProperty> &
BoundingClientRect::getPropertyMap() {
  static const std::unordered_map<std::string, BoundingClientRectProperty> propertyMap{
    {"x", BoundingClientRectProperty::kX},         {"y", BoundingClientRectProperty::kY},
    {"width", BoundingClientRectProperty::kWidth}, {"height", BoundingClientRectProperty::kHeight},
    {"top", BoundingClientRectProperty::kTop},     {"left", BoundingClientRectProperty::kLeft},
    {"right", BoundingClientRectProperty::kRight}, {"bottom", BoundingClientRectProperty::kBottom}};
  return propertyMap;
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
