/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NATIVE_STRING_H
#define KRAKENBRIDGE_NATIVE_STRING_H

#include <quickjs/quickjs.h>
#include <cinttypes>
#include <string>
#include <memory>
#include <locale>
#include <codecvt>

namespace kraken {

struct NativeString {
  const uint16_t* string;
  uint32_t length;

  NativeString* clone();
  void free();
};

// Convert to string and return a full copy of NativeString from JSValue.
std::unique_ptr<NativeString> jsValueToNativeString(JSContext* ctx, JSValue value);

// Encode utf-8 to utf-16, and return a full copy of NativeString.
std::unique_ptr<NativeString> stringToNativeString(const std::string& string);

// Return a full copy of NativeString form JSAtom.
std::unique_ptr<NativeString> atomToNativeString(JSContext* ctx, JSAtom atom);

// Convert to string and return a full copy of std::string from JSValue.
std::string jsValueToStdString(JSContext* ctx, JSValue& value);

// Return a full copy of std::string form JSAtom.
std::string jsAtomToStdString(JSContext* ctx, JSAtom atom);

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

}

class native_string {};

#endif  // KRAKENBRIDGE_NATIVE_STRING_H
