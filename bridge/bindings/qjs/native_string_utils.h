/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NATIVE_STRING_UTILS_H
#define KRAKENBRIDGE_NATIVE_STRING_UTILS_H

#include <quickjs/quickjs.h>
#include <codecvt>
#include <locale>
#include <memory>
#include <string>

#include "foundation/native_string.h"

namespace kraken {

// Convert to string and return a full copy of NativeString from JSValue.
std::unique_ptr<NativeString> jsValueToNativeString(JSContext* ctx, JSValue value);

// Encode utf-8 to utf-16, and return a full copy of NativeString.
std::unique_ptr<NativeString> stringToNativeString(const std::string& string);

std::string nativeStringToStdString(const NativeString* native_string);

template <typename T>
std::string toUTF8(const std::basic_string<T, std::char_traits<T>, std::allocator<T>>& source) {
  std::string result;

  std::wstring_convert<std::codecvt_utf8_utf16<T>, T> convertor;
  result = convertor.to_bytes(source);

  return result;
}

template <typename T>
void fromUTF8(const std::string& source, std::basic_string<T, std::char_traits<T>, std::allocator<T>>& result) {
  std::wstring_convert<std::codecvt_utf8_utf16<T>, T> convertor;
  result = convertor.from_bytes(source);
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_NATIVE_STRING_UTILS_H
