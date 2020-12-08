/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "style_declaration.h"
#include "foundation/ui_command_queue.h"
#include <map>
#include <vector>

namespace kraken::binding::jsc {

void bindCSSStyleDeclaration(std::unique_ptr<JSContext> &context) {
  auto style = CSSStyleDeclaration::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "CSSStyleDeclaration", style->classObject);
}

namespace {

static std::string parseJavaScriptCSSPropertyName(std::string &propertyName) {
  static std::unordered_map<std::string, std::string> propertyCache{};

  if (propertyCache.contains(propertyName)) {
    return propertyCache[propertyName];
  }

  std::vector<char> buffer(propertyName.size() + 1);

  size_t hyphen = 0;
  for (size_t i = 0; i < propertyName.size(); ++i) {
    char c = propertyName[i + hyphen];
    if (!c) break;
    if (c == '-') {
      hyphen++;
      buffer[i] = toASCIIUpper(propertyName[i + hyphen]);
    } else {
      buffer[i] = c;
    }
  }

  buffer.emplace_back('\0');

  std::string result = std::string(buffer.data());

  propertyCache[propertyName] = result;
  return result;
}

} // namespace

CSSStyleDeclaration::CSSStyleDeclaration(JSContext *context) : HostClass(context, "CSSStyleDeclaration") {}

std::unordered_map<JSContext *, CSSStyleDeclaration *> CSSStyleDeclaration::instanceMap{};

CSSStyleDeclaration *CSSStyleDeclaration::instance(JSContext *context) {
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new CSSStyleDeclaration(context);
  }
  return instanceMap[context];
}

CSSStyleDeclaration::~CSSStyleDeclaration() {
  instanceMap.erase(context);
}

JSObjectRef CSSStyleDeclaration::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                     const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Illegal constructor", exception);
  }

  const JSValueRef eventTargetValueRef = arguments[0];
  JSObjectRef eventTargetObjectRef = JSValueToObject(ctx, eventTargetValueRef, exception);

  auto eventTargetInstance =
    static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(eventTargetObjectRef));
  auto style = new StyleDeclarationInstance(this, eventTargetInstance);
  return style->object;
}

CSSStyleDeclaration::StyleDeclarationInstance::StyleDeclarationInstance(
  CSSStyleDeclaration *cssStyleDeclaration, JSEventTarget::EventTargetInstance *ownerEventTarget)
  : Instance(cssStyleDeclaration), ownerEventTarget(ownerEventTarget) {}

CSSStyleDeclaration::StyleDeclarationInstance::~StyleDeclarationInstance() {
  for (auto &string : properties) {
    JSStringRelease(string.second);
  }
}

JSValueRef CSSStyleDeclaration::StyleDeclarationInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getStyleDeclarationPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];
    switch (property) {
    case CSSStyleDeclarationProperty::kSetProperty: {
      return m_setProperty.function();
    }
    case CSSStyleDeclarationProperty::kGetPropertyValue: {
      return m_getPropertyValue.function();
    }
    case CSSStyleDeclarationProperty::kRemoveProperty: {
      return m_removeProperty.function();
    }
    }
  } else if (properties.contains(name)) {
    return JSValueMakeString(_hostClass->ctx, properties[name]);
  }

  return JSValueMakeString(_hostClass->ctx, JSStringCreateWithUTF8CString(""));
}

void CSSStyleDeclaration::StyleDeclarationInstance::setProperty(std::string &name, JSValueRef value,
                                                                JSValueRef *exception) {
  internalSetProperty(name, value, exception);
}

void CSSStyleDeclaration::StyleDeclarationInstance::internalSetProperty(std::string &name, JSValueRef value,
                                                                        JSValueRef *exception) {
  if (name == "setProperty" || name == "removeProperty" || name == "getPropertyValue") return;

  JSStringRef valueStr;
  if (JSValueIsNull(_hostClass->ctx, value)) {
    valueStr = JSStringCreateWithUTF8CString("");
  } else {
    valueStr = JSValueToStringCopy(_hostClass->ctx, value, exception);
  }

  JSStringRetain(valueStr);

  name = parseJavaScriptCSSPropertyName(name);

  properties[name] = valueStr;

  NativeString args_01{};
  NativeString args_02{};
  buildUICommandArgs(name, valueStr, args_01, args_02);
  foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
    ->registerCommand(ownerEventTarget->eventTargetId, UICommand::setStyle, args_01, args_02, nullptr);
}

void CSSStyleDeclaration::StyleDeclarationInstance::internalRemoveProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string &&name = JSStringToStdString(nameRef);
  name = parseJavaScriptCSSPropertyName(name);

  if (!properties.contains(name)) {
    return;
  }

  JSStringRef emptyStringRef = JSStringCreateWithUTF8CString("");
  JSStringRetain(emptyStringRef);
  properties[name] = emptyStringRef;


  NativeString args_01{};
  NativeString args_02{};

  buildUICommandArgs(name, emptyStringRef, args_01, args_02);

  foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
    ->registerCommand(ownerEventTarget->eventTargetId, UICommand::setStyle, args_01, args_02, nullptr);
}

JSValueRef CSSStyleDeclaration::StyleDeclarationInstance::internalGetPropertyValue(JSStringRef nameRef,
                                                                                   JSValueRef *exception) {
  std::string &&name = JSStringToStdString(nameRef);
  name = parseJavaScriptCSSPropertyName(name);

  return JSValueMakeString(_hostClass->ctx, properties[name]);
}

JSValueRef CSSStyleDeclaration::StyleDeclarationInstance::setProperty(JSContextRef ctx, JSObjectRef function,
                                                                      JSObjectRef thisObject, size_t argumentCount,
                                                                      const JSValueRef *arguments,
                                                                      JSValueRef *exception) {
  if (argumentCount != 2) {
    JSC_THROW_ERROR(ctx, "Failed to execute setProperty: 2 arguments is required.", exception);
    return nullptr;
  }

  const JSValueRef propertyValueRef = arguments[0];
  const JSValueRef valueValueRef = arguments[1];

  if (!JSValueIsString(ctx, propertyValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute setProperty: property value type is not a string.", exception);
    return nullptr;
  }

  JSStringRef propertyStringRef = JSValueToStringCopy(ctx, propertyValueRef, exception);

  if (!JSValueIsString(ctx, valueValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute setProperty: value type is not a string.", exception);
    return nullptr;
  }

  auto styleInstance = static_cast<CSSStyleDeclaration::StyleDeclarationInstance *>(JSObjectGetPrivate(function));
  std::string name = JSStringToStdString(propertyStringRef);
  styleInstance->internalSetProperty(name, valueValueRef, exception);

  return nullptr;
}

JSValueRef CSSStyleDeclaration::StyleDeclarationInstance::removeProperty(JSContextRef ctx, JSObjectRef function,
                                                                         JSObjectRef thisObject, size_t argumentCount,
                                                                         const JSValueRef *arguments,
                                                                         JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute removeProperty: 1 arguments is required.", exception);
    return nullptr;
  }

  const JSValueRef propertyValueRef = arguments[0];

  if (!JSValueIsString(ctx, propertyValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute removeProperty: property value type is not a string.", exception);
    return nullptr;
  }

  JSStringRef propertyStringRef = JSValueToStringCopy(ctx, propertyValueRef, exception);
  auto styleInstance = static_cast<CSSStyleDeclaration::StyleDeclarationInstance *>(JSObjectGetPrivate(function));
  styleInstance->internalRemoveProperty(propertyStringRef, exception);
  return nullptr;
}

JSValueRef CSSStyleDeclaration::StyleDeclarationInstance::getPropertyValue(JSContextRef ctx, JSObjectRef function,
                                                                           JSObjectRef thisObject, size_t argumentCount,
                                                                           const JSValueRef *arguments,
                                                                           JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute getPropertyValue: 1 arguments is required.", exception);
    return nullptr;
  }

  const JSValueRef propertyValueRef = arguments[0];

  if (!JSValueIsString(ctx, propertyValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute getPropertyValue: property value type is not a string.", exception);
    return nullptr;
  }

  JSStringRef propertyStringRef = JSValueToStringCopy(ctx, propertyValueRef, exception);
  auto styleInstance = static_cast<CSSStyleDeclaration::StyleDeclarationInstance *>(JSObjectGetPrivate(function));
  return styleInstance->internalGetPropertyValue(propertyStringRef, exception);
}

void CSSStyleDeclaration::StyleDeclarationInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &prop : properties) {
    JSPropertyNameAccumulatorAddName(accumulator, JSStringCreateWithUTF8CString(prop.first.c_str()));
  }

  for (auto &prop : getStyleDeclarationPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, prop);
  }
}

std::array<JSStringRef, 3> &CSSStyleDeclaration::StyleDeclarationInstance::getStyleDeclarationPropertyNames() {
  static std::array<JSStringRef, 3> propertyNames{
    JSStringCreateWithUTF8CString("setProperty"),
    JSStringCreateWithUTF8CString("removeProperty"),
    JSStringCreateWithUTF8CString("getPropertyValue"),
  };
  return propertyNames;
}
const std::unordered_map<std::string, CSSStyleDeclaration::StyleDeclarationInstance::CSSStyleDeclarationProperty> &
CSSStyleDeclaration::StyleDeclarationInstance::getStyleDeclarationPropertyMap() {
  static const std::unordered_map<std::string, CSSStyleDeclarationProperty> propertyMap{
    {"setProperty", CSSStyleDeclarationProperty::kSetProperty},
    {"getPropertyValue", CSSStyleDeclarationProperty::kGetPropertyValue},
    {"removeProperty", CSSStyleDeclarationProperty::kRemoveProperty}};
  return propertyMap;
}

} // namespace kraken::binding::jsc
