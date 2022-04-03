/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "native_string_utils.h"
#include "bindings/qjs/qjs_engine_patch.h"

namespace kraken {

std::unique_ptr<NativeString> jsValueToNativeString(JSContext* ctx, JSValue value) {
  bool isValueString = true;
  if (JS_IsNull(value)) {
    value = JS_NewString(ctx, "");
    isValueString = false;
  } else if (!JS_IsString(value)) {
    value = JS_ToString(ctx, value);
    isValueString = false;
  }

  uint32_t length;
  uint16_t* buffer = JS_ToUnicode(ctx, value, &length);
  std::unique_ptr<NativeString> ptr = std::make_unique<NativeString>(buffer, length);

  if (!isValueString) {
    JS_FreeValue(ctx, value);
  }
  return ptr;
}

std::unique_ptr<NativeString> stringToNativeString(const std::string& string) {
  std::u16string utf16;
  fromUTF8(string, utf16);
  NativeString tmp{reinterpret_cast<const uint16_t*>(utf16.c_str()), static_cast<uint32_t>(utf16.size())};
  return std::unique_ptr<NativeString>(tmp.clone());
}

std::unique_ptr<NativeString> atomToNativeString(JSContext* ctx, JSAtom atom) {
  JSValue stringValue = JS_AtomToString(ctx, atom);
  std::unique_ptr<NativeString> string = jsValueToNativeString(ctx, stringValue);
  JS_FreeValue(ctx, stringValue);
  return string;
}

std::string jsValueToStdString(JSContext* ctx, JSValue& value) {
  const char* cString = JS_ToCString(ctx, value);
  std::string str = std::string(cString);
  JS_FreeCString(ctx, cString);
  return str;
}

}  // namespace kraken
