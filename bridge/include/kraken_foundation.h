/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_FOUNDATION_H
#define KRAKENBRIDGE_FOUNDATION_H

#include <atomic>
#include <cassert>
#include <codecvt>
#include <cstdint>
#include <functional>
#include <locale>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>
#define WINDOW_TARGET_ID -1
#define DOCUMENT_TARGET_ID -2

#define assert_m(exp, msg) assert(((void)msg, exp))

#define KRAKEN_EXPORT __attribute__((__visibility__("default")))

#if defined(__GNUC__) || defined(__clang__)
#define LIKELY(x) __builtin_expect(!!(x), 1)
#define UNLIKELY(x) __builtin_expect(!!(x), 0)
#define FORCE_INLINE inline __attribute__((always_inline))
#else
#define LIKELY(x) (x)
#define UNLIKELY(x) (x)
#define FORCE_INLINE inline
#endif

#define KRAKEN_DISALLOW_COPY(TypeName) TypeName(const TypeName&) = delete

#define KRAKEN_DISALLOW_ASSIGN(TypeName) TypeName& operator=(const TypeName&) = delete

#define KRAKEN_DISALLOW_MOVE(TypeName) \
  TypeName(TypeName&&) = delete;       \
  TypeName& operator=(TypeName&&) = delete

#define KRAKEN_DISALLOW_COPY_AND_ASSIGN(TypeName) \
  TypeName(const TypeName&) = delete;             \
  TypeName& operator=(const TypeName&) = delete

#define KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName) \
  TypeName(const TypeName&) = delete;                  \
  TypeName(TypeName&&) = delete;                       \
  TypeName& operator=(const TypeName&) = delete;       \
  TypeName& operator=(TypeName&&) = delete

#define KRAKEN_DISALLOW_IMPLICIT_CONSTRUCTORS(TypeName) \
  TypeName() = delete;                                  \
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName)

struct NativeString;
struct UICommandItem;

namespace foundation {

// An un thread safe queue used for dart side to read ui command items.
class UICommandCallbackQueue {
 public:
  using Callback = void (*)(void*);
  UICommandCallbackQueue() = default;
  static KRAKEN_EXPORT UICommandCallbackQueue* instance();
  KRAKEN_EXPORT void registerCallback(const Callback& callback, void* data);
  KRAKEN_EXPORT void flushCallbacks();

 private:
  struct CallbackItem {
    CallbackItem(const Callback& callback, void* data) : callback(callback), data(data){};
    Callback callback;
    void* data;
  };

  std::vector<CallbackItem> queue;
};

}  // namespace foundation

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

#endif
