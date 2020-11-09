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
  static JSElement *_instance{nullptr};
  if (_instance == nullptr) {
    _instance = new JSElement(context);
  }
  return _instance;
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

JSElement::ElementInstance::ElementInstance(JSElement *element, JSValueRef tagNameValue, double targetId,
                                            JSValueRef *exception)
  : NodeInstance(element, NodeType::ELEMENT_NODE) {
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

JSValueRef JSElement::ElementInstance::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);

  if (name == "style") {
    if (style == nullptr) {
      style =
        new CSSStyleDeclaration::StyleDeclarationInstance(CSSStyleDeclaration::instance(_hostClass->context), this);
      JSValueProtect(_hostClass->ctx, style->object);
    }

    return style->object;
  } else if (name == "nodeName") {
    return JSValueMakeString(_hostClass->ctx, tagNameStringRef_);
  }

  return JSNode::NodeInstance::getProperty(nameRef, exception);
}

void JSElement::ElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  NodeInstance::getPropertyNames(accumulator);

  for (auto &property : getElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::array<JSStringRef, 1> &JSElement::ElementInstance::getElementPropertyNames() {
  static std::array<JSStringRef, 1> propertyNames{JSStringCreateWithUTF8CString("style")};
  return propertyNames;
}

} // namespace kraken::binding::jsc
