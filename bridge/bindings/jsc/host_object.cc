/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "host_object.h"
#include "foundation/logging.h"

namespace kraken::binding::jsc {

HostObject::HostObject(JSContext *context, std::string name)
  : context(context), name(std::move(name)), ctx(context->context()), contextId(context->getContextId()) {
  JSClassDefinition hostObjectDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_HOST_OBJECT_DEFINITION(hostObjectDefinition, this->name.c_str(), HostObject);
  jsClass = JSClassCreate(&hostObjectDefinition);
  jsObject = JSObjectMake(context->context(), jsClass, this);
}

JSValueRef HostObject::proxyGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                        JSValueRef *exception) {
  auto hostObject = static_cast<HostObject *>(JSObjectGetPrivate(object));
  auto &context = hostObject->context;
  std::string name = JSStringToStdString(propertyName);
  JSValueRef ret = hostObject->getProperty(name, exception);
  if (!context->handleException(*exception)) {
    return nullptr;
  }
  return ret;
}

bool HostObject::proxySetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value,
                                  JSValueRef *exception) {
  auto hostObject = static_cast<HostObject *>(JSObjectGetPrivate(object));
  auto &context = hostObject->context;
  std::string &&name = JSStringToStdString(propertyName);
  hostObject->setProperty(name, value, exception);
  JSStringRelease(propertyName);
  return context->handleException(*exception);
}

void HostObject::proxyFinalize(JSObjectRef obj) {
  auto hostObject = static_cast<HostObject *>(JSObjectGetPrivate(obj));
  JSObjectSetPrivate(obj, nullptr);
  JSClassRelease(hostObject->jsClass);
  delete hostObject;
}

void HostObject::proxyGetPropertyNames(JSContextRef ctx, JSObjectRef object, JSPropertyNameAccumulatorRef accumulator) {
  auto hostObject = static_cast<HostObject *>(JSObjectGetPrivate(object));
  hostObject->getPropertyNames(accumulator);
}

HostObject::~HostObject() {
}

JSValueRef HostObject::getProperty(std::string &name, JSValueRef *exception) {
  if (m_propertyMap.count(name) > 0) {
    return m_propertyMap[name];
  }
  return nullptr;
}

void HostObject::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  if (m_propertyMap.count(name) > 0) {
    JSValueUnprotect(ctx, m_propertyMap[name]);
  }

  JSValueProtect(ctx, value);
  m_propertyMap[name] = value;
}

void HostObject::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &prop : m_propertyMap) {
    JSPropertyNameAccumulatorAddName(accumulator, JSStringCreateWithUTF8CString(prop.first.c_str()));
  }
}

} // namespace kraken::binding::jsc
