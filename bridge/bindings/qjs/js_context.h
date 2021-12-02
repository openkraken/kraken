/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_H
#define KRAKENBRIDGE_JS_CONTEXT_H

#include <quickjs/list.h>
#include <quickjs/quickjs.h>
#include <atomic>
#include <cassert>
#include <cmath>
#include <cstring>
#include <locale>
#include <memory>
#include <mutex>
#include <unordered_map>
#include "js_context_macros.h"
#include "kraken_foundation.h"
#include "qjs_patch.h"
using QjsContext = JSContext;
using JSExceptionHandler = std::function<void(int32_t contextId, const char* message)>;

namespace kraken::binding::qjs {

static std::once_flag kinitJSClassIDFlag;

JSRuntime* getGlobalJSRuntime();
class WindowInstance;
class DocumentInstance;
class JSContext;

static inline bool isNumberIndex(const std::string& name) {
  if (name.empty())
    return false;
  char f = name[0];
  return f >= '0' && f <= '9';
}

struct PromiseContext {
  void* data;
  JSContext* context;
  JSValue resolveFunc;
  JSValue rejectFunc;
  JSValue promise;
  list_head link;
};

struct AtomJob {
  JSAtom atom;
  list_head link;
};

bool isContextValid(int32_t contextId);

class JSContext {
 public:
  JSContext() = delete;
  JSContext(int32_t contextId, const JSExceptionHandler& handler, void* owner);
  ~JSContext();

  bool evaluateJavaScript(const uint16_t* code, size_t codeLength, const char* sourceURL, int startLine);
  bool evaluateJavaScript(const char16_t* code, size_t length, const char* sourceURL, int startLine);
  bool evaluateJavaScript(const char* code, size_t codeLength, const char* sourceURL, int startLine);
  bool evaluateByteCode(uint8_t* bytes, size_t byteLength);
  bool isValid() const;
  JSValue global();
  QjsContext* ctx();
  JSRuntime* runtime();
  int32_t getContextId() const;
  void* getOwner();
  bool handleException(JSValue* exc);
  void drainPendingPromiseJobs();
  void defineGlobalProperty(const char* prop, JSValueConst value);
  uint8_t* dumpByteCode(const char* code, uint32_t codeLength, const char* sourceURL, size_t* bytecodeLength);

  std::chrono::time_point<std::chrono::system_clock> timeOrigin;
  std::unordered_map<std::string, void*> constructorMap;

  int32_t uniqueId;
  struct list_head node_job_list;
  struct list_head timer_job_list;
  struct list_head document_job_list;
  struct list_head module_job_list;
  struct list_head module_callback_job_list;
  struct list_head promise_job_list;
  struct list_head atom_job_list;
  struct list_head native_function_job_list;

  static JSClassID kHostClassClassId;
  static JSClassID kHostObjectClassId;
  static JSClassID kHostExoticObjectClassId;

 private:
  static void promiseRejectTracker(QjsContext* ctx, JSValueConst promise, JSValueConst reason, JS_BOOL is_handled, void* opaque);
  void dispatchGlobalErrorEvent(JSValueConst error);
  void dispatchGlobalPromiseRejectionEvent(JSValueConst promise, JSValueConst error);
  void reportError(JSValueConst error);

  int32_t contextId;
  JSExceptionHandler _handler;
  void* owner;
  JSValue globalObject{JS_NULL};
  bool ctxInvalid_{false};
  QjsContext* m_ctx{nullptr};
  friend WindowInstance;
  friend DocumentInstance;
  WindowInstance* m_window{nullptr};
};

// The read object's method or properties via Proxy, we should redirect this_val from Proxy into target property of
// proxy object.
static JSValue handleCallThisOnProxy(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int data_len, JSValueConst* data) {
  JSValue f = data[0];
  JSValue result;
  if (JS_IsProxy(this_val)) {
    result = JS_Call(ctx, f, JS_GetProxyTarget(this_val), argc, argv);
  } else {
    result = JS_Call(ctx, f, this_val, argc, argv);
  }
  return result;
}

class ObjectProperty {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(ObjectProperty);

 public:
  ObjectProperty() = delete;
  explicit ObjectProperty(JSContext* context, JSValueConst thisObject, const char* property, JSCFunction getterFunction, JSCFunction setterFunction) {
    JSValue ge = JS_NewCFunction(context->ctx(), getterFunction, "get", 0);
    JSValue se = JS_NewCFunction(context->ctx(), setterFunction, "set", 1);

    JSValue pge = JS_NewCFunctionData(context->ctx(), handleCallThisOnProxy, 0, 0, 1, &ge);
    JSValue pse = JS_NewCFunctionData(context->ctx(), handleCallThisOnProxy, 1, 0, 1, &se);

    JS_FreeValue(context->ctx(), ge);
    JS_FreeValue(context->ctx(), se);

    JSAtom key = JS_NewAtom(context->ctx(), property);
    JS_DefinePropertyGetSet(context->ctx(), thisObject, key, pge, pse, JS_PROP_C_W_E);
    JS_FreeAtom(context->ctx(), key);
  };
  explicit ObjectProperty(JSContext* context, JSValueConst thisObject, const char* property, JSCFunction getterFunction) {
    JSValue get = JS_NewCFunction(context->ctx(), getterFunction, "get", 0);
    JSAtom key = JS_NewAtom(context->ctx(), property);
    JS_DefineProperty(context->ctx(), thisObject, key, JS_UNDEFINED, get, JS_UNDEFINED, JS_PROP_HAS_CONFIGURABLE | JS_PROP_ENUMERABLE | JS_PROP_HAS_GET);
    JS_FreeAtom(context->ctx(), key);
  }
  explicit ObjectProperty(JSContext* context, JSValueConst thisObject, const char* property, JSValue value) {
    JS_DefinePropertyValueStr(context->ctx(), thisObject, property, value, JS_PROP_ENUMERABLE);
  }
};

class ObjectFunction {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(ObjectFunction);

 public:
  ObjectFunction() = delete;
  explicit ObjectFunction(JSContext* context, JSValueConst thisObject, const char* functionName, JSCFunction function, int argc) {
    JSValue f = JS_NewCFunction(context->ctx(), function, functionName, argc);
    JSValue pf = JS_NewCFunctionData(context->ctx(), handleCallThisOnProxy, argc, 0, 1, &f);
    JSAtom key = JS_NewAtom(context->ctx(), functionName);

    JS_FreeValue(context->ctx(), f);

// We should avoid overwrite exist property functions.
#ifdef DEBUG
    assert_m(JS_HasProperty(context->ctx(), thisObject, key) == 0, (std::string("Found exist function property: ") + std::string(functionName)).c_str());
#endif

    JS_DefinePropertyValue(context->ctx(), thisObject, key, pf, JS_PROP_ENUMERABLE);
    JS_FreeAtom(context->ctx(), key);
  };
};

class JSValueHolder {
 public:
  JSValueHolder() = delete;
  explicit JSValueHolder(QjsContext* ctx, JSValue value) : m_value(value), m_ctx(ctx){};
  ~JSValueHolder() { JS_FreeValue(m_ctx, m_value); }
  inline void value(JSValue value) {
    if (!JS_IsNull(m_value)) {
      JS_FreeValue(m_ctx, m_value);
    }
    m_value = JS_DupValue(m_ctx, value);
  };
  inline JSValue value() const { return JS_DupValue(m_ctx, m_value); }

 private:
  QjsContext* m_ctx{nullptr};
  JSValue m_value{JS_NULL};
};

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler& handler, void* owner);

// Convert to string and return a full copy of NativeString from JSValue.
std::unique_ptr<NativeString> jsValueToNativeString(QjsContext* ctx, JSValue value);

void buildUICommandArgs(QjsContext* ctx, JSValue key, NativeString& args_01);

// Encode utf-8 to utf-16, and return a full copy of NativeString.
std::unique_ptr<NativeString> stringToNativeString(const std::string& string);

// Return a full copy of NativeString form JSAtom.
std::unique_ptr<NativeString> atomToNativeString(QjsContext* ctx, JSAtom atom);

// Convert to string and return a full copy of std::string from JSValue.
std::string jsValueToStdString(QjsContext* ctx, JSValue& value);

// Return a full copy of std::string form JSAtom.
std::string jsAtomToStdString(QjsContext* ctx, JSAtom atom);

// JS array operation utilities.
void arrayPushValue(QjsContext* ctx, JSValue array, JSValue val);
void arrayInsert(QjsContext* ctx, JSValue array, uint32_t start, JSValue targetValue);
int32_t arrayGetLength(QjsContext* ctx, JSValue array);
int32_t arrayFindIdx(QjsContext* ctx, JSValue array, JSValue target);
void arraySpliceValue(QjsContext* ctx, JSValue array, uint32_t start, uint32_t deleteCount);
void arraySpliceValue(QjsContext* ctx, JSValue array, uint32_t start, uint32_t deleteCount, JSValue replacedValue);

// JS object operation utilities.
JSValue objectGetKeys(QjsContext* ctx, JSValue obj);

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_JS_CONTEXT_H
