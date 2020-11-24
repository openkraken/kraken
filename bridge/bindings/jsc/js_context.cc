/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "js_context.h"
#include "bindings/jsc/KOM/window.h"
#include "bindings/jsc/macros.h"
#include "dart_methods.h"
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

  timeOrigin = std::chrono::system_clock::now();
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

JSObjectRef JSObjectMakePromise(JSContext *context, void *data, JSObjectCallAsFunctionCallback callback,
                                JSValueRef *exception) {
  JSValueRef promiseConstructorValueRef =
    JSObjectGetProperty(context->context(), context->global(), JSStringCreateWithUTF8CString("Promise"), exception);
  JSObjectRef promiseConstructor = JSValueToObject(context->context(), promiseConstructorValueRef, exception);

  JSObjectRef functionArgs = propertyBindingFunction(context, data, "P", callback);
  const JSValueRef constructorArguments[1]{functionArgs};

  return JSObjectCallAsConstructor(context->context(), promiseConstructor, 1, constructorArguments, exception);
}

NativeString **buildUICommandArgs(JSStringRef key) {
  auto args = new NativeString *[1];
  NativeString nativeKey{};
  nativeKey.string = JSStringGetCharactersPtr(key);
  nativeKey.length = JSStringGetLength(key);
  args[0] = nativeKey.clone();

  JSStringRelease(key);
  return args;
}
NativeString **buildUICommandArgs(std::string &key) {
  auto args = new NativeString *[1];

  JSStringRef keyStringRef = JSStringCreateWithUTF8CString(key.c_str());
  NativeString nativeKey{};
  nativeKey.string = JSStringGetCharactersPtr(keyStringRef);
  nativeKey.length = JSStringGetLength(keyStringRef);
  args[0] = nativeKey.clone();

  JSStringRelease(keyStringRef);
  return args;
}
NativeString **buildUICommandArgs(std::string &key, JSStringRef value) {
  auto args = new NativeString *[2];
  JSStringRef keyStringRef = JSStringCreateWithUTF8CString(key.c_str());

  NativeString nativeKey{};
  nativeKey.string = JSStringGetCharactersPtr(keyStringRef);
  nativeKey.length = JSStringGetLength(keyStringRef);

  NativeString nativeValue{};
  nativeValue.string = JSStringGetCharactersPtr(value);
  nativeValue.length = JSStringGetLength(value);

  args[0] = nativeKey.clone();
  args[1] = nativeValue.clone();

  JSStringRelease(keyStringRef);
  JSStringRelease(value);
  return args;
}

NativeString **buildUICommandArgs(std::string &key, std::string &value) {
  auto args = new NativeString *[2];
  JSStringRef keyStringRef = JSStringCreateWithUTF8CString(key.c_str());
  JSStringRef valueStringRef = JSStringCreateWithUTF8CString(value.c_str());

  NativeString nativeKey{};
  nativeKey.string = JSStringGetCharactersPtr(keyStringRef);
  nativeKey.length = JSStringGetLength(keyStringRef);

  NativeString nativeValue{};
  nativeValue.string = JSStringGetCharactersPtr(valueStringRef);
  nativeValue.length = JSStringGetLength(valueStringRef);

  args[0] = nativeKey.clone();
  args[1] = nativeValue.clone();

  JSStringRelease(keyStringRef);
  JSStringRelease(valueStringRef);

  return args;
}

JSFunctionHolder::JSFunctionHolder(JSContext *context, void *data, std::string name,
                                   JSObjectCallAsFunctionCallback callback)
  : context(context), m_data(data), m_callback(callback), m_name(std::move(name)) {}

JSFunctionHolder::~JSFunctionHolder() {
  if (context->isValid() && m_function != nullptr) {
    JSValueUnprotect(context->context(), m_function);
  }
}

JSObjectRef JSFunctionHolder::function() {
  if (m_function == nullptr) {
    m_function = propertyBindingFunction(context, m_data, m_name.c_str(), m_callback);
    JSValueProtect(context->context(), m_function);
  }
  return m_function;
}

JSStringHolder::JSStringHolder(JSContext *context, const std::string& string)
  : m_context(context), m_string(JSStringRetain(JSStringCreateWithUTF8CString(string.c_str()))) {}

JSStringHolder::~JSStringHolder() {
  if (m_string != nullptr) JSStringRelease(m_string);
}

JSValueRef JSStringHolder::makeString() {
  if (m_string == nullptr) return nullptr;
  return JSValueMakeString(m_context->context(), m_string);
}

void JSStringHolder::setString(JSStringRef value) {
  assert(value != nullptr);

  // Should release previous string reference.
  if (m_string != nullptr) {
    JSStringRelease(m_string);
  }

  m_string = JSStringRetain(value);
}

size_t JSStringHolder::utf8Size() {
  return JSStringGetMaximumUTF8CStringSize(m_string);
}

size_t JSStringHolder::size() {
  return JSStringGetLength(m_string);
}

std::string JSStringHolder::string() {
  return JSStringToStdString(m_string);
}

const JSChar *JSStringHolder::ptr() {
  return JSStringGetCharactersPtr(m_string);
}

bool JSStringHolder::empty() {
  return size() == 0;
}
JSStringHolder::JSStringHolder(JSContext *context, JSStringRef string): m_context(context), m_string(string) {}

} // namespace kraken::binding::jsc
