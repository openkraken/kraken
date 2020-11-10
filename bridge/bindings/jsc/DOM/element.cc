/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
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
  static std::unordered_map<JSContext *, JSElement*> instanceMap {};
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
    UICommandTaskMessageQueue::instance(element->context->getContextId())
      ->registerCommand(targetId, UICommandType::initBody, args, argsLength, nativeEventTarget);
  } else {
    UICommandTaskMessageQueue::instance(element->context->getContextId())
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

JSValueRef JSElement::ElementInstance::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);
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
  }

  return JSNode::NodeInstance::getProperty(nameRef, exception);
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

BoundingClientRect::BoundingClientRect(JSContext *context, NativeBoundingClientRect *boundingClientRect)
  : HostObject(context, "BoundingClientRect"), nativeBoundingClientRect(boundingClientRect) {}

JSValueRef BoundingClientRect::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  auto name = JSStringToStdString(nameRef);

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
