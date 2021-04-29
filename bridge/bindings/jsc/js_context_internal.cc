/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "js_context_internal.h"
#include "bindings/jsc/KOM/timer.h"
#include "bindings/jsc/kraken.h"
#include "dart_methods.h"
#include <memory>
#include <mutex>
#include <vector>

namespace kraken::binding::jsc {

std::vector<JSStaticFunction> JSContext::globalFunctions{};
std::vector<JSStaticValue> JSContext::globalValue{};

static std::atomic<int32_t> context_unique_id{0};

JSContext::JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner)
  : contextId(contextId), _handler(handler), owner(owner), ctxInvalid_(false), uniqueId(context_unique_id++) {

  JSClassDefinition contextDefinition = kJSClassDefinitionEmpty;

  const JSStaticFunction functionEnd = {nullptr};
  const JSStaticValue valueEnd = {nullptr};

  globalFunctions.emplace_back(functionEnd);
  globalValue.emplace_back(valueEnd);

  contextDefinition.staticFunctions = globalFunctions.data();
  contextDefinition.staticValues = globalValue.data();

  JSClassRef contextClass = JSClassCreate(&contextDefinition);

  ctx_ = JSGlobalContextCreateInGroup(nullptr, contextClass);

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

bool JSContext::evaluateJavaScript(const char16_t *code, size_t length, const char *sourceURL, int startLine) {
  JSStringRef sourceRef = JSStringCreateWithCharacters(reinterpret_cast<const JSChar *>(code), length);
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

void throwJSError(JSContextRef ctx, const char *msg, JSValueRef *exception) {
  JSStringRef _errmsg = JSStringCreateWithUTF8CString(msg);
  const JSValueRef args[] = {JSValueMakeString(ctx, _errmsg), nullptr};
  *exception = JSObjectMakeError(ctx, 1, args, nullptr);
  JSStringRelease(_errmsg);
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

JSObjectRef makeObjectFunctionWithPrivateData(JSContext *context, void *data, const char *name,
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

  JSObjectRef functionArgs = makeObjectFunctionWithPrivateData(context, data, "P", callback);
  const JSValueRef constructorArguments[1]{functionArgs};

  return JSObjectCallAsConstructor(context->context(), promiseConstructor, 1, constructorArguments, exception);
}

namespace {
const JSChar *cloneString(const JSChar *string, size_t length) {
  auto *newString = new JSChar[length];
  for (size_t i = 0; i < length; i++) {
    newString[i] = string[i];
  }
  return newString;
};
} // namespace

void buildUICommandArgs(JSStringRef key, NativeString &args_01) {
  args_01.length = JSStringGetLength(key);
  args_01.string = cloneString(JSStringGetCharactersPtr(key), args_01.length);
}

void buildUICommandArgs(std::string &key, NativeString &args_01) {
  JSStringRef keyStringRef = JSStringCreateWithUTF8CString(key.c_str());
  args_01.length = JSStringGetLength(keyStringRef);
  args_01.string = cloneString(JSStringGetCharactersPtr(keyStringRef), args_01.length);
  JSStringRelease(keyStringRef);
}

void buildUICommandArgs(std::string &key, JSStringRef value, NativeString &args_01, NativeString &args_02) {
  JSStringRef keyStringRef = JSStringCreateWithUTF8CString(key.c_str());

  args_01.length = JSStringGetLength(keyStringRef);
  args_01.string = cloneString(JSStringGetCharactersPtr(keyStringRef), args_01.length);

  args_02.length = JSStringGetLength(value);
  args_02.string = cloneString(JSStringGetCharactersPtr(value), args_02.length);

  JSStringRelease(keyStringRef);
}

void buildUICommandArgs(std::string &key, std::string &value, NativeString &args_01, NativeString &args_02) {
  JSStringRef keyStringRef = JSStringCreateWithUTF8CString(key.c_str());
  JSStringRef valueStringRef = JSStringCreateWithUTF8CString(value.c_str());

  args_01.length = JSStringGetLength(keyStringRef);
  args_01.string = cloneString(JSStringGetCharactersPtr(keyStringRef), args_01.length);

  args_02.length = JSStringGetLength(valueStringRef);
  args_02.string = cloneString(JSStringGetCharactersPtr(valueStringRef), args_02.length);

  JSStringRelease(keyStringRef);
  JSStringRelease(valueStringRef);
}

NativeString *stringToNativeString(std::string &string) {
  std::u16string utf16;
  fromUTF8(string, utf16);
  NativeString tmp{};
  tmp.string = reinterpret_cast<const uint16_t *>(utf16.c_str());
  tmp.length = utf16.size();
  return tmp.clone();
}

NativeString *stringRefToNativeString(JSStringRef string) {
  NativeString tmp{};
  tmp.string = JSStringGetCharactersPtr(string);
  tmp.length = JSStringGetLength(string);
  return tmp.clone();
}

JSFunctionHolder::JSFunctionHolder(JSContext *context, JSObjectRef root, void *data, const std::string& name,
                                   JSObjectCallAsFunctionCallback callback) {
  JSStringHolder nameStringHolder = JSStringHolder(context, name);
  JSObjectRef function;
  // If context is nullptr, create normal js function without private data
  if (data == nullptr) {
    function = JSObjectMakeFunctionWithCallback(context->context(), nameStringHolder.getString(), callback);
  } else {
    function = makeObjectFunctionWithPrivateData(context, data, name.c_str(), callback);
  }

  JSObjectSetProperty(context->context(), root, nameStringHolder.getString(), function, kJSPropertyAttributeNone, nullptr);
}

JSStringHolder::JSStringHolder(JSContext *context, const std::string &string)
  : m_context(context), m_string(JSStringRetain(JSStringCreateWithUTF8CString(string.c_str()))) {}

JSStringHolder::~JSStringHolder() {
  if (m_string != nullptr) JSStringRelease(m_string);
}

JSValueRef JSStringHolder::makeString() {
  if (m_string == nullptr) return nullptr;
  return JSValueMakeString(m_context->context(), m_string);
}

JSStringRef JSStringHolder::getString() {
  return m_string;
}

void JSStringHolder::setString(JSStringRef value) {
  assert(value != nullptr);

  // Should release previous string reference.
  if (m_string != nullptr) {
    JSStringRelease(m_string);
  }

  m_string = JSStringRetain(value);
}

void JSStringHolder::setString(NativeString *value) {
  JSStringRef ref = JSStringCreateWithCharacters(value->string, value->length);
  m_string = JSStringRetain(ref);
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

JSValueHolder::JSValueHolder(JSContext *context, JSValueRef value) : m_value(value), m_context(context) {
  if (m_value != nullptr) {
    JSValueProtect(context->context(), m_value);
  }
}
JSValueHolder::~JSValueHolder() {
  if (m_context->isValid() && m_value != nullptr) {
    JSValueUnprotect(m_context->context(), m_value);
  }
}

JSValueRef JSValueHolder::value() {
  return m_value;
}

void JSValueHolder::setValue(JSValueRef value) {
  m_value = value;
  JSValueProtect(m_context->context(), m_value);
}

} // namespace kraken::binding::jsc
