/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "host_class.h"
#include "foundation/logging.h"

namespace kraken::binding::jsc {

HostClass::HostClass(JSContext *context, std::string name)
  : context(context), _name(std::move(name)), ctx(context->context()), contextId(context->getContextId()) {
  JSClassDefinition hostClassDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_HOST_CLASS_DEFINITION(hostClassDefinition, _name.c_str(), nullptr, nullptr, HostClass);
  jsClass = JSClassCreate(&hostClassDefinition);
  classObject = JSObjectMake(ctx, jsClass, this);

  JSClassDefinition hostInstanceDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_HOST_CLASS_INSTANCE_DEFINITION(hostInstanceDefinition, _name.c_str(), HostClass);
  instanceClass = JSClassCreate(&hostInstanceDefinition);
}

HostClass::HostClass(JSContext *context, HostClass *parentHostClass, std::string name,
                     const JSStaticFunction *staticFunction, const JSStaticValue *staticValue)
  : context(context), _name(std::move(name)), ctx(context->context()), _parentHostClass(parentHostClass) {
  JSClassDefinition hostClassDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_HOST_CLASS_DEFINITION(hostClassDefinition, _name.c_str(), staticFunction, staticValue, HostClass);
  hostClassDefinition.attributes = kJSClassAttributeNone;
  jsClass = JSClassCreate(&hostClassDefinition);
  classObject = JSObjectMake(ctx, jsClass, this);
  JSClassDefinition hostInstanceDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_HOST_CLASS_INSTANCE_DEFINITION(hostInstanceDefinition, _name.c_str(), HostClass);
  instanceClass = JSClassCreate(&hostInstanceDefinition);
}

void HostClass::proxyInitialize(JSContextRef ctx, JSObjectRef object) {
  JSObjectRef global = JSContextGetGlobalObject(ctx);
  JSStringRef functionString = JSStringCreateWithUTF8CString("Function");
  JSValueRef value = JSObjectGetProperty(ctx, global, functionString, nullptr);
  JSObjectRef funcCtor = JSValueToObject(ctx, value, nullptr);
  JSStringRef prototypeKey = JSStringCreateWithUTF8CString("prototype");
  JSValueRef prototype = JSObjectGetPrototype(ctx, funcCtor);
  JSObjectSetProperty(ctx, object, prototypeKey, prototype, kJSPropertyAttributeNone, nullptr);
  JSStringRelease(functionString);
}

void HostClass::proxyFinalize(JSObjectRef object) {
  auto hostClass = static_cast<HostClass *>(JSObjectGetPrivate(object));
  JSObjectSetPrivate(object, nullptr);
  JSClassRelease(hostClass->jsClass);
  JSClassRelease(hostClass->instanceClass);
  delete hostClass;
}

bool HostClass::proxyHasInstance(JSContextRef ctx, JSObjectRef constructor, JSValueRef possibleInstance,
                                 JSValueRef *exception) {
  if (!JSValueIsObject(ctx, possibleInstance)) {
    return false;
  }

  JSObjectRef instanceObject = JSValueToObject(ctx, possibleInstance, exception);
  auto constructorHostClass = static_cast<HostClass *>(JSObjectGetPrivate(constructor));
  auto instanceHostClass = static_cast<HostClass *>(JSObjectGetPrivate(instanceObject));

  if (constructorHostClass == nullptr || instanceHostClass == nullptr) return false;
  return constructorHostClass == instanceHostClass;
}

JSObjectRef HostClass::proxyCallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  auto hostClass = static_cast<HostClass *>(JSObjectGetPrivate(constructor));
  return hostClass->instanceConstructor(ctx, constructor, argumentCount, arguments, exception);
}

JSValueRef HostClass::proxyCallAsFunction(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                          size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  return JSValueMakeUndefined(ctx);
}

namespace {

JSValueRef constructorCall(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto hostClass = static_cast<HostClass *>(JSObjectGetPrivate(function));

  const JSValueRef instanceThisObject = arguments[0];
  JSValueRef *instanceArguments = new JSValueRef[argumentCount - 1];

  for (int i = 1; i < argumentCount; i ++) {
    instanceArguments[0] = arguments[i];
  }

  JSObjectRef instanceReturn =
    hostClass->instanceConstructor(ctx, thisObject, argumentCount - 1, instanceArguments, exception);
  delete[] instanceArguments;

  return instanceReturn;
}

}

JSValueRef HostClass::proxyGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                       JSValueRef *exception) {
  auto &&name = JSStringToStdString(propertyName);
  auto hostClass = static_cast<HostClass *>(JSObjectGetPrivate(object));

  if (name == "call") {
    return propertyBindingFunction(hostClass->context, hostClass, "call", constructorCall);
  }

  KRAKEN_LOG(VERBOSE) << "Constructor get property " << name;
  return nullptr;
}

void HostClass::proxyInstanceInitialize(JSContextRef ctx, JSObjectRef object) {
  auto hostClassInstance = static_cast<HostClass::Instance *>(JSObjectGetPrivate(object));
  hostClassInstance->initialized();
}

JSValueRef HostClass::proxyInstanceGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                               JSValueRef *exception) {
  auto hostClassInstance = reinterpret_cast<HostClass::Instance *>(JSObjectGetPrivate(object));
  std::string name = JSStringToStdString(propertyName);
  JSValueRef result = hostClassInstance->getProperty(name, exception);

  return result;
}

bool HostClass::proxyInstanceSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                         JSValueRef value, JSValueRef *exception) {
  auto hostClassInstance = static_cast<HostClass::Instance *>(JSObjectGetPrivate(object));
  JSStringRetain(propertyName);
  hostClassInstance->setProperty(propertyName, value, exception);
  JSStringRelease(propertyName);
  return hostClassInstance->_hostClass->context->handleException(*exception);
}

void HostClass::proxyInstanceGetPropertyNames(JSContextRef ctx, JSObjectRef object,
                                              JSPropertyNameAccumulatorRef accumulator) {
  auto hostClassInstance = static_cast<HostClass::Instance *>(JSObjectGetPrivate(object));
  hostClassInstance->getPropertyNames(accumulator);
}

void HostClass::proxyInstanceFinalize(JSObjectRef object) {
  auto hostClassInstance = static_cast<HostClass::Instance *>(JSObjectGetPrivate(object));
  delete hostClassInstance;
}

JSObjectRef HostClass::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                         const JSValueRef *arguments, JSValueRef *exception) {
  return JSObjectMake(ctx, nullptr, nullptr);
}
HostClass::~HostClass() {}

HostClass::Instance::Instance(HostClass *hostClass) : _hostClass(hostClass) {
  object = JSObjectMake(hostClass->ctx, hostClass->instanceClass, this);
}
void HostClass::Instance::initialized() {}
JSValueRef HostClass::Instance::getProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}
void HostClass::Instance::setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) {}
void HostClass::Instance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {}
HostClass::Instance::~Instance() {}
} // namespace kraken::binding::jsc
