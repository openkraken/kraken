/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_INTERNAL_H
#define KRAKENBRIDGE_JS_CONTEXT_INTERNAL_H

#include "include/kraken_bridge.h"
#include <chrono>
#include <codecvt>
#include <locale>
#include <map>
#include <string>
#include <unordered_map>
#include <vector>

#ifndef __has_builtin
#define __has_builtin(x) 0
#endif

#if __has_builtin(__builtin_expect) || defined(__GNUC__)
#define JSC_LIKELY(EXPR) __builtin_expect((bool)(EXPR), true)
#define JSC_UNLIKELY(EXPR) __builtin_expect((bool)(EXPR), false)
#else
#define JSC_LIKELY(EXPR) (EXPR)
#define JSC_UNLIKELY(EXPR) (EXPR)
#endif

namespace kraken::binding::jsc {

static inline bool isNumberIndex(std::string &name) {
  if (name.empty()) return false;
  char f = name[0];
  return f >= '0' && f <= '9';
}

inline JSValueRef getObjectPropertyValue(JSContextRef ctx, const std::string& key, JSObjectRef object, JSValueRef *exception) {
  JSStringRef keyRef = JSStringCreateWithUTF8CString(key.c_str());
  JSValueRef result = JSObjectGetProperty(ctx, object, keyRef, exception);
  JSStringRelease(keyRef);
  return result;
}

inline bool objectHasProperty(JSContextRef ctx, const std::string key, JSObjectRef object) {
  JSStringRef keyRef = JSStringCreateWithUTF8CString(key.c_str());
  bool result = JSObjectHasProperty(ctx, object, keyRef);
  JSStringRelease(keyRef);
  return result;
}

template <typename T> std::string toUTF8(const std::basic_string<T, std::char_traits<T>, std::allocator<T>> &source) {
  std::string result;

  std::wstring_convert<std::codecvt_utf8_utf16<T>, T> convertor;
  result = convertor.to_bytes(source);

  return result;
}

template <typename T>
void fromUTF8(const std::string &source, std::basic_string<T, std::char_traits<T>, std::allocator<T>> &result) {
  std::wstring_convert<std::codecvt_utf8_utf16<T>, T> convertor;
  result = convertor.from_bytes(source);
}

inline std::string trim(std::string &str) {
  str.erase(0, str.find_first_not_of(' ')); // prefixing spaces
  str.erase(str.find_last_not_of(' ') + 1); // surfixing spaces
  return str;
}

std::unique_ptr<JSContext> createJSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);

#if ENABLE_PROFILE
std::unordered_map<std::string, double> *getNativeFunctionCallTime();
std::unordered_map<std::string, int> *getNativeFunctionCallCount();
#endif

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_JS_CONTEXT_INTERNAL_H
