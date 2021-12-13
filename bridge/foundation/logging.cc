/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "logging.h"
#include <algorithm>
#include "colors.h"

#include "page.h"

#if defined(IS_ANDROID)
#include <android/log.h>
#elif defined(IS_IOS)
#include <syslog.h>
#else
#include <iostream>
#endif

#if ENABLE_DEBUGGER
#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/ConsoleTypes.h>
#include <JavaScriptCore/JSGlobalObject.h>
#include "inspector/impl/jsc_console_client_impl.h"
#endif

namespace foundation {
namespace {

const char* const kLogSeverityNames[LOG_NUM_SEVERITIES] = {"VERBOSE", BOLD("INFO"), FYEL("WARN"), BOLD("DEBUG"), FRED("ERROR")};
const char* GetNameForLogSeverity(LogSeverity severity) {
  if (severity >= LOG_INFO && severity < LOG_NUM_SEVERITIES)
    return kLogSeverityNames[severity];
  return FCYN("UNKNOWN");
}

const char* StripDots(const char* path) {
  while (strncmp(path, "../", 3) == 0)
    path += 3;
  return path;
}

const char* StripPath(const char* path) {
  auto p = strrchr(path, '/');
  if (p)
    return p + 1;
  else
    return path;
}

}  // namespace

LogMessage::LogMessage(LogSeverity severity, const char* file, int line, const char* condition) : severity_(severity), file_(file), line_(line) {
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

#ifdef ENABLE_DEBUGGER
void pipeMessageToInspector(JSGlobalContextRef ctx, const std::string message, const JSC::MessageLevel logLevel) {
  JSObjectRef globalObjectRef = JSContextGetGlobalObject(ctx);
  auto client = JSObjectGetPrivate(globalObjectRef);
  if (client && client != ((void*)0x1)) {
    auto client_impl = reinterpret_cast<kraken::debugger::JSCConsoleClientImpl*>(client);
    client_impl->sendMessageToConsole(logLevel, message);
  }
};
#endif

enum class MessageLevel : uint8_t {
  Log = 1,
  Warning = 2,
  Error = 3,
  Debug = 4,
  Info = 5,
};

void printLog(int32_t contextId, std::stringstream& stream, std::string level, void* ctx) {
  MessageLevel _log_level = MessageLevel::Info;
  switch (level[0]) {
    case 'l':
      KRAKEN_LOG(VERBOSE) << stream.str();
      _log_level = MessageLevel::Log;
      break;
    case 'i':
      KRAKEN_LOG(INFO) << stream.str();
      _log_level = MessageLevel::Info;
      break;
    case 'd':
      KRAKEN_LOG(DEBUG_) << stream.str();
      _log_level = MessageLevel::Debug;
      break;
    case 'w':
      KRAKEN_LOG(WARN) << stream.str();
      _log_level = MessageLevel::Warning;
      break;
    case 'e':
      KRAKEN_LOG(ERROR) << stream.str();
      _log_level = MessageLevel::Error;
      break;
    default:
      KRAKEN_LOG(VERBOSE) << stream.str();
  }

  if (kraken::KrakenPage::consoleMessageHandler != nullptr) {
    kraken::KrakenPage::consoleMessageHandler(ctx, stream.str(), static_cast<int>(_log_level));
  }
}

}  // namespace foundation
