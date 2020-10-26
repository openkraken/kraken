/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "js_context.h"
#include "bindings/jsc/macros.h"
#include <memory>
#include <mutex>
#include <vector>

namespace kraken::binding::jsc {

JSContext::JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner)
  : contextId(contextId), _handler(handler), owner(owner), ctxInvalid_(false) {

  ctx_ = JSGlobalContextCreateInGroup(nullptr, nullptr);

  JSObjectRef global = JSContextGetGlobalObject(ctx_);
  JSStringRef windowName = JSStringCreateWithUTF8CString("window");
  JSStringRef globalThis = JSStringCreateWithUTF8CString("globalThis");
  JSObjectSetProperty(ctx_, global, windowName, global, kJSPropertyAttributeNone, nullptr);
  JSObjectSetProperty(ctx_, global, globalThis, global, kJSPropertyAttributeNone, nullptr);

  JSStringRelease(windowName);
  JSStringRelease(globalThis);
}

JSContext::~JSContext() {
  ctxInvalid_ = true;
  JSGlobalContextRelease(ctx_);
}

bool JSContext::evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine) {
  JSStringRef sourceRef = JSStringCreateWithCharacters(code, codeLength);
  JSStringRef sourceURLRef = nullptr;
  if (sourceURL != nullptr) {
    sourceURLRef = JSStringCreateWithUTF8CString(sourceURL);
  }

  JSValueRef exc = nullptr; // exception
  JSEvaluateScript(ctx_, sourceRef, nullptr /*null means global*/, sourceURLRef, startLine, &exc);

  JSStringRelease(sourceRef);
  if (sourceURLRef) {
    JSStringRelease(sourceURLRef);
  }

  return handleException(exc);
}

bool JSContext::evaluateJavaScript(const char *code, const char *sourceURL, int startLine) {
  JSStringRef sourceRef = JSStringCreateWithUTF8CString(code);
  JSStringRef sourceURLRef = nullptr;
  if (sourceURL != nullptr) {
    sourceURLRef = JSStringCreateWithUTF8CString(sourceURL);
  }

  JSValueRef exc = nullptr; // exception
  JSEvaluateScript(ctx_, sourceRef, nullptr /*null means global*/, sourceURLRef, startLine, &exc);

  JSStringRelease(sourceRef);
  if (sourceURLRef) {
    JSStringRelease(sourceURLRef);
  }

  return handleException(exc);
}

bool JSContext::isValid() {
  return !ctxInvalid_;
}

int32_t JSContext::getContextId() {
  assert(!ctxInvalid_ && "context has been released");
  return contextId;
}

void *JSContext::getOwner() {
  assert(!ctxInvalid_ && "context has been released");
  return owner;
}

bool JSContext::handleException(JSValueRef exc) {
  if (JSC_UNLIKELY(exc)) {
    HANDLE_JSC_EXCEPTION(ctx_, exc, _handler);
    return false;
  }
  return true;
}

JSObjectRef JSContext::global() {
  return JSContextGetGlobalObject(ctx_);
}

JSGlobalContextRef JSContext::context() {
  assert(!ctxInvalid_ && "context has been released");
  return ctx_;
}

void JSContext::reportError(const char *errmsg) {
  _handler(contextId, errmsg);
}

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner) {
  return std::make_unique<JSContext>(contextId, handler, owner);
}

std::string JSStringToStdString(JSStringRef jsString) {
  size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(jsString);
  std::vector<char> buffer(maxBufferSize);
  JSStringGetUTF8CString(jsString, buffer.data(), maxBufferSize);
  return std::string(buffer.data());
}

HostObject::HostObject(JSContext *context, std::string name) : context(context), name(name), ctx(context->context()) {
  JSClassDefinition hostObjectDefinition = kJSClassDefinitionEmpty;
  JSC_CREATE_CLASS_DEFINITION(hostObjectDefinition, name.c_str(), HostObject);
  jsClass = JSClassCreate(&hostObjectDefinition);
  jsObject = JSObjectMake(context->context(), jsClass, this);
}

JSValueRef HostObject::proxyGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                        JSValueRef *exception) {
  auto hostObject = static_cast<HostObject *>(JSObjectGetPrivate(object));
  auto &context = hostObject->context;
  JSStringRetain(propertyName);
  JSValueRef ret = hostObject->getProperty(propertyName, exception);
  JSStringRelease(propertyName);
  if (!context->handleException(*exception)) {
    return nullptr;
  }
  return ret;
}

bool HostObject::proxySetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value,
                                  JSValueRef *exception) {
  auto hostObject = static_cast<HostObject *>(JSObjectGetPrivate(object));
  auto &context = hostObject->context;
  JSStringRetain(propertyName);
  hostObject->setProperty(propertyName, value, exception);
  JSStringRelease(propertyName);
  return context->handleException(*exception);
}

void HostObject::finalize(JSObjectRef obj) {
  auto hostObject = static_cast<HostObject *>(JSObjectGetPrivate(obj));
  JSObjectSetPrivate(obj, nullptr);
  JSClassRelease(hostObject->jsClass);
  delete hostObject;
}

bool HostObject::hasInstance(JSContextRef ctx, JSObjectRef constructor, JSValueRef possibleInstance,
                             JSValueRef *exception) {
  auto hostObject = static_cast<HostObject *>(JSObjectGetPrivate(constructor));

  if (!JSValueIsObject(ctx, possibleInstance)) {
    return false;
  }

  JSObjectRef instanceObject = JSValueToObject(ctx, possibleInstance, exception);
  auto instanceHostObject = static_cast<HostObject *>(JSObjectGetPrivate(instanceObject));

  if (instanceHostObject == nullptr) {
    return false;
  }

  return instanceHostObject->name == hostObject->name;
}

void HostObject::proxyGetPropertyNames(JSContextRef ctx, JSObjectRef object, JSPropertyNameAccumulatorRef accumulator) {
  auto hostObject = static_cast<HostObject *>(JSObjectGetPrivate(object));
  hostObject->getPropertyNames(accumulator);
}

HostObject::~HostObject() {}

JSValueRef HostObject::getProperty(JSStringRef name, JSValueRef *exception) {
  return nullptr;
}

void HostObject::setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) {}

void HostObject::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {}

} // namespace kraken::binding::jsc
