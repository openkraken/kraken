/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <algorithm>
#include "colors.h"
#include "logging.h"

#if defined(IS_ANDROID)
#include <android/log.h>
#elif defined(IS_IOS)
#include <syslog.h>
#else
#include <iostream>
#endif

#if ENABLE_DEBUGGER
#include <JavaScriptCore/ConsoleTypes.h>
#include <JavaScriptCore/JSGlobalObject.h>
#include "inspector/impl/jsc_console_client_impl.h"
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

LogMessage::LogMessage(LogSeverity severity, const char *file, int line, const char* condition)
  : severity_(severity), file_(file), line_(line) {
  if (condition)
    stream_ << "Check failed: " << condition << ". ";
}

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
  if (severity_ == LOG_ERROR) {
    std::cerr << stream_.str() << std::endl;
    std::cerr.flush();
  } else {
    std::cout << stream_.str() << std::endl;
    std::cout.flush();
  }
#endif
}

void printLog(std::stringstream &stream, std::string level, JSObjectRef global) {
#ifdef ENABLE_DEBUGGER
    JSC::MessageLevel _log_level = JSC::MessageLevel::Log;
#endif
    switch (level[0]) {
      case 'l':
        KRAKEN_LOG(VERBOSE) << stream.str();
#ifdef ENABLE_DEBUGGER
        _log_level = JSC::MessageLevel::Log;
#endif
        break;
      case 'i':
        KRAKEN_LOG(INFO) << stream.str();
#ifdef ENABLE_DEBUGGER
        _log_level = JSC::MessageLevel::Info;
#endif
        break;
      case 'd':
        KRAKEN_LOG(DEBUG_) << stream.str();
#ifdef ENABLE_DEBUGGER
        _log_level = JSC::MessageLevel::Debug;
#endif
        break;
      case 'w':
        KRAKEN_LOG(WARN) << stream.str();
#ifdef ENABLE_DEBUGGER
        _log_level = JSC::MessageLevel::Warning;
#endif
        break;
      case 'e':
        KRAKEN_LOG(ERROR) << stream.str();
#ifdef ENABLE_DEBUGGER
        _log_level = JSC::MessageLevel::Error;
#endif
        break;
      default:
        KRAKEN_LOG(VERBOSE) << stream.str();
    }

#ifdef ENABLE_DEBUGGER
  auto client = reinterpret_cast<JSC::JSGlobalObject *>(global)->consoleClient();
  if (client && client != ((void *)0x1)) {
    auto client_impl = reinterpret_cast<kraken::debugger::JSCConsoleClientImpl *>(client);
    client_impl->sendMessageToConsole(_log_level, stream.str());
  }
#endif
  }

} // namespace foundation
