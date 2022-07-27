/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */

#ifndef FOUNDATION_LOGGING_H_
#define FOUNDATION_LOGGING_H_

#include <sstream>

#include <string>
#include "include/webf_bridge.h"

namespace foundation {

typedef int LogSeverity;

// Default log levels. Negative values can be used for verbose log levels.
constexpr LogSeverity VERBOSE = 0;
constexpr LogSeverity INFO = 1;
constexpr LogSeverity WARN = 2;
constexpr LogSeverity DEBUG = 3;
constexpr LogSeverity ERROR = 4;
constexpr LogSeverity FATAL = 5;

enum class MessageLevel : uint8_t {
  Log = 1,
  Warning = 2,
  Error = 3,
  Debug = 4,
  Info = 5,
};

class LogMessageVoidify {
 public:
  void operator&(std::ostream&) {}
};

class LogMessage {
 public:
  LogMessage(LogSeverity severity, const char* file, int line, const char* condition);
  ~LogMessage();

  std::ostream& stream() { return stream_; }

 private:
  std::ostringstream stream_;
  const LogSeverity severity_;
  const char* file_;
  const int line_;

  DISALLOW_COPY_AND_ASSIGN(LogMessage);
};

void printLog(int32_t contextId, std::stringstream& stream, std::string level, void* ctx);

#define WEBF_LOG_STREAM(severity) ::foundation::LogMessage(::foundation::severity, __FILE__, __LINE__, nullptr).stream()

#define WEBF_LAZY_STREAM(stream, condition) !(condition) ? (void)0 : foundation::LogMessageVoidify() & (stream)

#define WEBF_LOG(severity) WEBF_LAZY_STREAM(WEBF_LOG_STREAM(severity), true)

#define WEBF_CHECK(condition) WEBF_LAZY_STREAM(::foundation::LogMessage(::foundation::FATAL, __FILE__, __LINE__, #condition).stream(), !(condition))

}  // namespace foundation

#endif  // FOUNDATION_LOGGING_H_
