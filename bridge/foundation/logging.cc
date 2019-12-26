/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include <algorithm>
#include <iostream>

#include "logging.h"

#if defined(IS_ANDROID)
#include <android/log.h>
#elif defined(IS_IOS)
#include <syslog.h>
#endif

namespace foundation {
namespace {

const char *const kLogSeverityNames[LOG_NUM_SEVERITIES] = {
    "VERBOSE", "INFO", "WARN", "DEBUG", "ERROR"};
const char *GetNameForLogSeverity(LogSeverity severity) {
  if (severity >= LOG_INFO && severity < LOG_NUM_SEVERITIES)
    return kLogSeverityNames[severity];
  return "UNKNOWN";
}

const char *StripDots(const char *path) {
  while (strncmp(path, "../", 3) == 0)
    path += 3;
  return path;
}

const char *StripPath(const char *path) {
  auto p = strrchr(path, '/');
  if (p)
    return p + 1;
  else
    return path;
}

} // namespace

LogMessage::LogMessage(LogSeverity severity, const char *file, int line,
                       const char *condition)
    : severity_(severity), file_(file), line_(line) {
  stream_ << "[";
  if (severity >= LOG_INFO)
    stream_ << GetNameForLogSeverity(severity);
  else
    stream_ << "VERBOSE" << -severity;
  stream_ << ":" << (severity > LOG_INFO ? StripDots(file_) : StripPath(file_))
          << "(" << line_ << ")] ";

  if (condition)
    stream_ << "Check failed: " << condition << ". ";
}

LogMessage::~LogMessage() {
  stream_ << std::endl;

#if defined(IS_ANDROID)
  android_LogPriority priority = ANDROID_LOG_VERBOSE;

  switch (severity_) {
  case LOG_VERBOSE:
    priority = ANDROID_LOG_VERBOSE;
    break;
  case LOG_INFO:
    priority = ANDROID_LOG_INFO;
    break;
  case LOG_DEBUG_:
    priority = ANDROID_LOG_DEBUG;
    break;
  case LOG_WARN:
    priority = ANDROID_LOG_WARN;
    break;
  case LOG_ERROR:
    priority = ANDROID_LOG_ERROR;
    break;
  }
  __android_log_write(priority, "KRAKEN_NATIVE_LOG", stream_.str().c_str());
#elif defined(IS_IOS)
  syslog(LOG_ALERT, "%s", stream_.str().c_str());
#else
  std::cerr << stream_.str();
  std::cerr.flush();
#endif
}

} // namespace foundation
