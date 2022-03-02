/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_FOUNDATION_LOGGING_H_
#define KRAKEN_FOUNDATION_LOGGING_H_

#include <sstream>

#include <string>
#include "include/kraken_bridge.h"

namespace foundation {



typedef int LogSeverity;

// Default log levels. Negative values can be used for verbose log levels.
constexpr LogSeverity _LOG_VERBOSE = 0;
constexpr LogSeverity _LOG_INFO = 1;
constexpr LogSeverity _LOG_WARN = 2;
constexpr LogSeverity _LOG_DEBUG = 3;
constexpr LogSeverity _LOG_ERROR = 4;
constexpr LogSeverity _LOG_NUM_SEVERITIES = 5;
constexpr LogSeverity _LOG_FATAL = 6;

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

  KRAKEN_DISALLOW_COPY_AND_ASSIGN(LogMessage);
};

void printLog(int32_t contextId, std::stringstream& stream, std::string level, void* ctx);

#define KRAKEN_LOG_STREAM(severity) ::foundation::LogMessage(::foundation::_LOG_##severity, __FILE__, __LINE__, nullptr).stream()

#define KRAKEN_LAZY_STREAM(stream, condition) !(condition) ? (void)0 : foundation::LogMessageVoidify() & (stream)

#define KRAKEN_LOG(severity) KRAKEN_LAZY_STREAM(KRAKEN_LOG_STREAM(severity), true)

#define KRAKEN_CHECK(condition) KRAKEN_LAZY_STREAM(::foundation::LogMessage(::foundation::_LOG_FATAL, __FILE__, __LINE__, #condition).stream(), !(condition))

}  // namespace foundation

#endif  // KRAKEN_FOUNDATION_LOGGING_H_
