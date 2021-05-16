/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "host_class.h"
#include "foundation/logging.h"
#include "KOM/performance.h"

#define PRIVATE_PROTO_KEY "__private_proto__"

namespace kraken::binding::jsc {

HostClass::HostClass(JSContext *context, std::string name)
  : context(context), _name(name), ctx(context->context()), contextId(context->getContextId()) {
  JSClassDefinition hostClassDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_HOST_CLASS_DEFINITION(hostClassDefinition, nullptr, _name.c_str(), nullptr, nullptr, HostClass);
  jsClass = JSClassCreate(&hostClassDefinition);
  JSClassRetain(jsClass);
  classObject = JSObjectMake(ctx, jsClass, this);
  prototypeObject = JSObjectMake(ctx, nullptr, this);
  JSValueProtect(ctx, classObject);
  JSValueProtect(ctx, prototypeObject);
  JSClassDefinition hostInstanceDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_HOST_CLASS_INSTANCE_DEFINITION(hostInstanceDefinition, _name.c_str(), HostClass, nullptr);
  instanceClass = JSClassCreate(&hostInstanceDefinition);
  JSClassRetain(instanceClass);
}

HostClass::HostClass(JSContext *context, HostClass *parentHostClass, std::string name,
                     const JSStaticFunction *staticFunction, const JSStaticValue *staticValue)
  : context(context), _name(name), ctx(context->context()), _parentHostClass(parentHostClass) {
  JSClassDefinition hostClassDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_HOST_CLASS_DEFINITION(hostClassDefinition, nullptr, _name.c_str(), staticFunction, staticValue, HostClass);
  hostClassDefinition.attributes = kJSClassAttributeNone;
  jsClass = JSClassCreate(&hostClassDefinition);
  JSClassRetain(jsClass);
  classObject = JSObjectMake(ctx, jsClass, this);
  prototypeObject = JSObjectMake(ctx, nullptr, this);
  JSValueProtect(ctx, classObject);
  JSValueProtect(ctx, prototypeObject);
  JSClassDefinition hostInstanceDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_HOST_CLASS_INSTANCE_DEFINITION(hostInstanceDefinition, _name.c_str(), HostClass, nullptr);
  instanceClass = JSClassCreate(&hostInstanceDefinition);
  JSClassRetain(instanceClass);
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

JSValueRef constructorCall(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef *arguments, JSValueRef *exception) {
  auto hostClass = static_cast<HostClass *>(JSObjectGetPrivate(function));

  const JSValueRef subInstanceValue = arguments[0];
  JSObjectRef subInstanceObject = JSValueToObject(ctx, subInstanceValue, exception);
  auto instanceArguments = new JSValueRef[argumentCount - 1];

  for (int i = 1; i < argumentCount; i++) {
    instanceArguments[i - 1] = arguments[i];
  }

  JSObjectRef instanceReturn =
    hostClass->instanceConstructor(ctx, subInstanceObject, argumentCount - 1, instanceArguments, exception);
  delete[] instanceArguments;

  return instanceReturn;
}

} // namespace

JSValueRef HostClass::proxyGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                       JSValueRef *exception) {
  auto &&name = JSStringToStdString(propertyName);
  auto hostClass = static_cast<HostClass *>(JSObjectGetPrivate(object));

  if (name == "call") {
    if (hostClass->_call == nullptr) {
      hostClass->_call = makeObjectFunctionWithPrivateData(hostClass->context, hostClass, "call", constructorCall);
      JSValueProtect(hostClass->ctx, hostClass->_call);
    }
    return hostClass->_call;
  } else if (name == "prototype") {
    // We return Constructor class as the prototype of Constructor function.
    // So that a inherit js object can read constructor status function via prototype chain.
    return hostClass->prototypeObject;
  }

  return hostClass->getProperty(name, exception);
}

JSValueRef HostClass::proxyInstanceGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                               JSValueRef *exception) {
  auto hostClassInstance = reinterpret_cast<HostClass::Instance *>(JSObjectGetPrivate(object));
  auto nativePerformance = binding::jsc::NativePerformance::instance(hostClassInstance->context->uniqueId);
#if ENABLE_PROFILE
  nativePerformance->mark(PERF_JS_HOST_CLASS_GET_PROPERTY_START);
#endif
  std::string &&name = JSStringToStdString(propertyName);
  JSValueRef result = hostClassInstance->getProperty(name, exception);
#if ENABLE_PROFILE
  nativePerformance->mark(PERF_JS_HOST_CLASS_GET_PROPERTY_END);
#endif
  return result;
}

JSValueRef HostClass::proxyPrototypeGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                                JSValueRef *exception) {
  auto hostClass = reinterpret_cast<HostClass *>(JSObjectGetPrivate(object));
  std::string &&name = JSStringToStdString(propertyName);
  JSValueRef result = hostClass->prototypeGetProperty(name, exception);
  return result;
}

bool HostClass::proxyInstanceSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                         JSValueRef value, JSValueRef *exception) {
  auto hostClassInstance = static_cast<HostClass::Instance *>(JSObjectGetPrivate(object));
  auto nativePerformance = binding::jsc::NativePerformance::instance(hostClassInstance->context->uniqueId);
#if ENABLE_PROFILE
  nativePerformance->mark(PERF_JS_HOST_CLASS_SET_PROPERTY_START);
#endif
  std::string &&name = JSStringToStdString(propertyName);
  bool handledBySelf = hostClassInstance->setProperty(name, value, exception);
  bool result = !hostClassInstance->context->handleException(*exception) || handledBySelf;
#if ENABLE_PROFILE
  nativePerformance->mark(PERF_JS_HOST_CLASS_SET_PROPERTY_END);
#endif
  return result;
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
HostClass::~HostClass() {
  if (context->isValid()) {
    if (_call != nullptr) JSValueUnprotect(ctx, _call);
    JSValueUnprotect(ctx, classObject);
    JSValueUnprotect(ctx, prototypeObject);
  }

  JSClassRelease(jsClass);
  JSClassRelease(instanceClass);
}

JSValueRef HostClass::getProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}

void HostClass::initPrototype() const {
  JSClassDefinition prototypeDefinition = kJSClassDefinitionEmpty;
  prototypeDefinition.getProperty = proxyPrototypeGetProperty;
  JSClassRef prototypeClass = JSClassCreate(&prototypeDefinition);
  JSObjectRef prototype = JSObjectMake(ctx, prototypeClass, (void*)this);
  JSStringRef constructorString = JSStringCreateWithUTF8CString("constructor");
  JSObjectSetProperty(ctx, prototype, constructorString, classObject, kJSClassAttributeNone, nullptr);
  JSStringRelease(constructorString);
  JSObjectSetPrototype(ctx, classObject, prototype);
}

JSValueRef HostClass::prototypeGetProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}

bool HostClass::hasProto(JSContextRef ctx, JSObjectRef child, JSValueRef *exception) {
  static JSStringRef privateKey = JSStringCreateWithUTF8CString(PRIVATE_PROTO_KEY);
  return JSObjectHasProperty(ctx, child, privateKey);
}

JSObjectRef HostClass::getProto(JSContextRef ctx, JSObjectRef child, JSValueRef *exception) {
  static JSStringRef privateKey = JSStringCreateWithUTF8CString(PRIVATE_PROTO_KEY);
  JSValueRef result = JSObjectGetProperty(ctx, child, privateKey, exception);
  if (result == nullptr) return nullptr;
  return JSValueToObject(ctx, result, exception);
}

void HostClass::setProto(JSContextRef ctx, JSObjectRef prototype, JSObjectRef child, JSValueRef *exception) {
  static JSStringRef privateKey = JSStringCreateWithUTF8CString(PRIVATE_PROTO_KEY);
  JSObjectSetProperty(ctx, child, privateKey, prototype, kJSPropertyAttributeReadOnly, exception);
}

HostClass::Instance::Instance(HostClass *hostClass)
  : _hostClass(hostClass), context(_hostClass->context), ctx(_hostClass->ctx), contextId(_hostClass->contextId) {
  object = JSObjectMake(hostClass->ctx, hostClass->instanceClass, this);
}

JSValueRef HostClass::Instance::getProperty(std::string &name, JSValueRef *exception) {
  return nullptr;
}

bool HostClass::Instance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  return false;
}

void HostClass::Instance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {}
HostClass::Instance::~Instance() {}
} // namespace kraken::binding::jsc
