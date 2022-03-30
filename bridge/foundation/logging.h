/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKEN_FOUNDATION_LOGGING_H_
#define KRAKEN_FOUNDATION_LOGGING_H_

#include <sstream>

#include <string>
#include "include/kraken_bridge.h"

namespace foundation {

typedef int LogSeverity;

// Default log levels. Negative values can be used for verbose log levels.
constexpr LogSeverity VERBOSE = 0;
constexpr LogSeverity INFO = 1;
constexpr LogSeverity WARN = 2;
constexpr LogSeverity DEBUG = 3;
constexpr LogSeverity ERROR = 4;
constexpr LogSeverity FATAL = 5;

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

#define KRAKEN_LOG_STREAM(severity) ::foundation::LogMessage(::foundation::severity, __FILE__, __LINE__, nullptr).stream()

#define KRAKEN_LAZY_STREAM(stream, condition) !(condition) ? (void)0 : foundation::LogMessageVoidify() & (stream)

#define KRAKEN_LOG(severity) KRAKEN_LAZY_STREAM(KRAKEN_LOG_STREAM(severity), true)

#define KRAKEN_CHECK(condition) KRAKEN_LAZY_STREAM(::foundation::LogMessage(::foundation::FATAL, __FILE__, __LINE__, #condition).stream(), !(condition))

}  // namespace foundation

#endif  // KRAKEN_FOUNDATION_LOGGING_H_
