/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_NATIVE_VALUE_H
#define KRAKENBRIDGE_NATIVE_VALUE_H

#include <quickjs/list.h>
#include <quickjs/quickjs.h>
#include <cinttypes>
#include <string>
#include "bindings/qjs/native_string_utils.h"

namespace kraken {

enum NativeTag {
  TAG_STRING = 0,
  TAG_INT = 1,
  TAG_BOOL = 2,
  TAG_NULL = 3,
  TAG_FLOAT64 = 4,
  TAG_JSON = 5,
  TAG_POINTER = 6,
  TAG_FUNCTION = 7,
  TAG_ASYNC_FUNCTION = 8,
};

enum class JSPointerType {
  AsyncContextContext = 0,
  NativeFunctionContext = 1,
  NativeBoundingClientRect = 2,
  NativeCanvasRenderingContext2D = 3,
  BindingObject = 4
};

class ExecutingContext;
class ScriptValue;

// Exchange data struct between dart and C++
struct NativeValue {
  union {
    int64_t int64;
    void* ptr;
  } u;
  int64_t tag;
};

struct NativeFunctionContext;

using CallNativeFunction = void (*)(NativeFunctionContext* functionContext,
                                    int32_t argc,
                                    NativeValue* argv,
                                    NativeValue* returnValue);

static void call_native_function(NativeFunctionContext* functionContext,
                                 int32_t argc,
                                 NativeValue* argv,
                                 NativeValue* returnValue);

struct NativeFunctionContext {
  CallNativeFunction call;
  NativeFunctionContext(ExecutingContext* context, JSValue callback);
  ~NativeFunctionContext();
  JSValue m_callback{JS_NULL};
  ExecutingContext* m_context{nullptr};
  JSContext* m_ctx{nullptr};
  list_head link;
};

NativeValue Native_NewNull();
NativeValue Native_NewString(NativeString* string);
NativeValue Native_NewCString(std::string string);
NativeValue Native_NewFloat64(double value);
NativeValue Native_NewBool(bool value);
NativeValue Native_NewInt64(int64_t value);
NativeValue Native_NewPtr(JSPointerType pointerType, void* ptr);
NativeValue Native_NewJSON(const ScriptValue& value);

}  // namespace kraken

#endif  // KRAKENBRIDGE_NATIVE_VALUE_H
