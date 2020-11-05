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


JSObjectRef propertyBindingFunction(JSContext *context, void *data, const char *name,
                                    JSObjectCallAsFunctionCallback callback) {
  JSClassDefinition functionDefinition = kJSClassDefinitionEmpty;
  functionDefinition.className = name;
  functionDefinition.callAsFunction = callback;
  functionDefinition.version = 0;
  JSClassRef functionClass = JSClassCreate(&functionDefinition);
  return JSObjectMake(context->context(), functionClass, data);
}

NativeString *stdStringToNativeString(std::string string) {
  JSStringRef stringRef = JSStringCreateWithUTF8CString(string.c_str());
  auto nativeString = new NativeString();
  nativeString->string = JSStringGetCharactersPtr(stringRef);
  nativeString->length = JSStringGetLength(stringRef);
  return nativeString;
}
} // namespace kraken::binding::jsc
