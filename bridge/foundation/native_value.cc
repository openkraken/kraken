/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "native_value.h"
#include "bindings/qjs/qjs_engine_patch.h"
#include "bindings/qjs/script_value.h"
#include "core/executing_context.h"

namespace kraken {

NativeValue Native_NewNull() {
  return (NativeValue){.u = {.int64 = 0}, NativeTag::TAG_NULL};
}

NativeValue Native_NewString(NativeString* string) {
  return (NativeValue){
      .u = {.ptr = static_cast<void*>(string)},
      NativeTag::TAG_STRING,
  };
}

NativeValue Native_NewCString(std::string string) {
  std::unique_ptr<NativeString> nativeString = stringToNativeString(string);
  // NativeString owned by NativeValue will be freed by users.
  return Native_NewString(nativeString.release());
}

NativeValue Native_NewFloat64(double value) {
  int64_t result;
  memcpy(&result, reinterpret_cast<void*>(&value), sizeof(double));

  return (NativeValue){
      .u = {.int64 = result},
      NativeTag::TAG_FLOAT64,
  };
}

NativeValue Native_NewPtr(JSPointerType pointerType, void* ptr) {
  return (NativeValue){.u = {.ptr = ptr}, NativeTag::TAG_POINTER};
}

NativeValue Native_NewBool(bool value) {
  return (NativeValue){
      .u = {.int64 = value ? 1 : 0},
      NativeTag::TAG_BOOL,
  };
}

NativeValue Native_NewInt64(int64_t value) {
  return (NativeValue){
      .u = {.int64 = value},
      NativeTag::TAG_INT,
  };
}

NativeValue Native_NewJSON(const ScriptValue& value) {
  ExceptionState exception_state;
  ScriptValue json = value.ToJSONStringify(&exception_state);
  if (exception_state.HasException()) {
    return Native_NewNull();
  }

  AtomicString str = json.ToString();
  auto native_string = str.ToNativeString();
  NativeValue result = (NativeValue){
      .u = {.ptr = static_cast<void*>(native_string.release())},
      NativeTag::TAG_JSON,
  };
  return result;
}

}  // namespace kraken
