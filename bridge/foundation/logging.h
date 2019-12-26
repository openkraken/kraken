/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#ifndef KRAKEN_FOUNDATION_LOGGING_H_
#define KRAKEN_FOUNDATION_LOGGING_H_

#include <sstream>

#include "macros.h"
#include <string.h>

namespace foundation {

typedef int LogSeverity;

// Default log levels. Negative values can be used for verbose log levels.
constexpr LogSeverity LOG_VERBOSE = 0;
constexpr LogSeverity LOG_INFO = 1;
constexpr LogSeverity LOG_WARN = 2;
constexpr LogSeverity LOG_DEBUG_ = 3;
constexpr LogSeverity LOG_ERROR = 4;
constexpr LogSeverity LOG_NUM_SEVERITIES = 5;

class LogMessageVoidify {
public:
  void operator&(std::ostream &) {}
};

class LogMessage {
public:
  LogMessage(LogSeverity severity, const char *file, int line,
             const char *condition);
  ~LogMessage();

  std::ostream &stream() { return stream_; }

private:
  std::ostringstream stream_;
  const LogSeverity severity_;
  const char *file_;
  const int line_;

  KRAKEN_DISALLOW_COPY_AND_ASSIGN(LogMessage);
};

} // namespace foundation

#define KRAKEN_LOG_STREAM(severity)                                            \
  ::foundation::LogMessage(::foundation::LOG_##severity, __FILE__, __LINE__,   \
                           nullptr)                                            \
      .stream()

#define KRAKEN_LAZY_STREAM(stream, condition)                                  \
  !(condition) ? (void)0 : ::foundation::LogMessageVoidify() & (stream)

#define KRAKEN_EAT_STREAM_PARAMETERS(ignored)                                  \
  true || (ignored)                                                            \
      ? (void)0                                                                \
      : ::foundation::LogMessageVoidify() &                                    \
            ::foundation::LogMessage(::foundation::LOG_FATAL, 0, 0, nullptr)   \
                .stream()

#define KRAKEN_LOG(severity)                                                   \
  KRAKEN_LAZY_STREAM(KRAKEN_LOG_STREAM(severity), true)

#endif // KRAKEN_FOUNDATION_LOGGING_H_
