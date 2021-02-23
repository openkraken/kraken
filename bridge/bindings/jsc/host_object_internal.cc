/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "host_object_internal.h"
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
  bool handledBySelf = hostObject->setProperty(name, value, exception);
  return !context->handleException(*exception) || handledBySelf;
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
  return nullptr;
}

bool HostObject::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  return false;
}

void HostObject::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
}

} // namespace kraken::binding::jsc
