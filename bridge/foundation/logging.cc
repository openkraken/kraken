/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <algorithm>
#include <iostream>

#include "colors.h"
#include "logging.h"

#if defined(IS_ANDROID)
#include <android/log.h>
#elif defined(IS_IOS)
#include <syslog.h>
#endif

namespace foundation {
namespace {

const char *const kLogSeverityNames[LOG_NUM_SEVERITIES] = {"VERBOSE", BOLD("INFO"), FYEL("WARN"), BOLD("DEBUG"),
                                                           FRED("ERROR")};
const char *GetNameForLogSeverity(LogSeverity severity) {
  if (severity >= LOG_INFO && severity < LOG_NUM_SEVERITIES) return kLogSeverityNames[severity];
  return FCYN("UNKNOWN");
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

LogMessage::LogMessage(LogSeverity severity, const char *file, int line)
  : severity_(severity), file_(file), line_(line) {}

LogMessage::~LogMessage() {
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
  std::cout << stream_.str();
  std::cout << std::endl;
  std::cout.flush();
#endif
}

} // namespace foundation
