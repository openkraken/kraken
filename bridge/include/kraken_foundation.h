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

class UICommandBuffer {
 public:
  UICommandBuffer() = delete;
  explicit UICommandBuffer(int32_t contextId);
  static KRAKEN_EXPORT UICommandBuffer* instance(int32_t contextId);

  KRAKEN_EXPORT void addCommand(int32_t id, int32_t type, void* nativePtr, bool batchedUpdate);
  KRAKEN_EXPORT void addCommand(int32_t id, int32_t type, void* nativePtr);
  KRAKEN_EXPORT void addCommand(int32_t id, int32_t type, NativeString& args_01, NativeString& args_02, void* nativePtr);
  KRAKEN_EXPORT void addCommand(int32_t id, int32_t type, NativeString& args_01, void* nativePtr);
  KRAKEN_EXPORT UICommandItem* data();
  KRAKEN_EXPORT int64_t size();
  KRAKEN_EXPORT void clear();

 private:
  int32_t contextId;
  std::atomic<bool> update_batched{false};
  std::vector<UICommandItem> queue;
};

typedef int LogSeverity;

// Default log levels. Negative values can be used for verbose log levels.
constexpr LogSeverity LOG_VERBOSE = 0;
constexpr LogSeverity LOG_INFO = 1;
constexpr LogSeverity LOG_WARN = 2;
constexpr LogSeverity LOG_DEBUG_ = 3;
constexpr LogSeverity LOG_ERROR = 4;
constexpr LogSeverity LOG_NUM_SEVERITIES = 5;
constexpr LogSeverity LOG_FATAL = 6;

class LogMessageVoidify {
 public:
  void operator&(std::ostream&) {}
};

class KRAKEN_EXPORT LogMessage {
 public:
  LogMessage(LogSeverity severity, const char* file, int line, const char* condition);
  ~LogMessage();

  std::ostream& stream() { return stream_; }

 private:
  std::ostringstream stream_;
  const LogSeverity severity_;
  const char* file_;
  const int line_;

  KRAKEN_DISALLOW_COPY_AND_ASSIGN(LogMessage);
};

void printLog(int32_t contextId, std::stringstream& stream, std::string level, void* ctx);

}  // namespace foundation

#define KRAKEN_LOG_STREAM(severity) ::foundation::LogMessage(::foundation::LOG_##severity, __FILE__, __LINE__, nullptr).stream()

#define KRAKEN_LAZY_STREAM(stream, condition) !(condition) ? (void)0 : ::foundation::LogMessageVoidify() & (stream)

#define KRAKEN_EAT_STREAM_PARAMETERS(ignored) true || (ignored) ? (void)0 : ::foundation::LogMessageVoidify() & ::foundation::LogMessage(::foundation::LOG_FATAL, 0, 0, nullptr).stream()

#define KRAKEN_LOG(severity) KRAKEN_LAZY_STREAM(KRAKEN_LOG_STREAM(severity), true)

#define KRAKEN_CHECK(condition) KRAKEN_LAZY_STREAM(::foundation::LogMessage(::foundation::LOG_FATAL, __FILE__, __LINE__, #condition).stream(), !(condition))

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
