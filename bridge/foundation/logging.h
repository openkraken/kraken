/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_FOUNDATION_LOGGING_H_
#define KRAKEN_FOUNDATION_LOGGING_H_

#include <sstream>
#include <string>

#define KRAKEN_LOG_STREAM(severity) ::kraken::LogMessage(::kraken::LOG_##severity, __FILE__, __LINE__, nullptr).stream()

#define KRAKEN_LAZY_STREAM(stream, condition) !(condition) ? (void)0 : ::kraken::LogMessageVoidify() & (stream)

#define KRAKEN_EAT_STREAM_PARAMETERS(ignored) true || (ignored) ? (void)0 : ::LogMessageVoidify() & ::LogMessage(::LOG_FATAL, 0, 0, nullptr).stream()

#define KRAKEN_LOG(severity) KRAKEN_LAZY_STREAM(KRAKEN_LOG_STREAM(severity), true)

#define KRAKEN_CHECK(condition) KRAKEN_LAZY_STREAM(::kraken::LogMessage(::kraken::LOG_FATAL, __FILE__, __LINE__, #condition).stream(), !(condition))

namespace kraken {

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
};

void printLog(int32_t contextId, std::stringstream& stream, std::string level, void* ctx);

}  // namespace kraken

#endif  // KRAKEN_FOUNDATION_LOGGING_H_
