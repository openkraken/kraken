/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "console.h"
#include <algorithm>
#include <sstream>

#ifdef ENABLE_DEBUGGER
#include "JavaScriptCore/JSGlobalObject.h"
#include "JavaScriptCore/runtime/ConsoleTypes.h"
#include <devtools/impl/jsc_console_client_impl.h>
#endif

namespace kraken {
namespace binding {
namespace {
using namespace alibaba::jsa;

void printLog(std::stringstream &stream, std::string level) {
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
  auto client = reinterpret_cast<JSC::JSGlobalObject *>(context.globalImpl())->consoleClient();
  if (client && client != ((void *)0x1)) {
    auto client_impl = reinterpret_cast<kraken::Debugger::JSCConsoleClientImpl *>(client);
    client_impl->sendMessageToConsole(_log_level, stream.str());
  }
#endif
}

Value print(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  std::stringstream stream;

  const Value &log = args[0];
  if (log.isString()) {
    stream << log.getString(context).utf8(context);
  } else {
    KRAKEN_LOG(ERROR) << "Failed to execute 'print': log must be string.";
    return Value::undefined();
  }

  std::string logLevel = "log";
  const Value &level = args[1];
  if (level.isString()) {
    logLevel = level.getString(context).utf8(context);
  }

  printLog(stream, logLevel);
  return Value::undefined();
}

} // namespace

////////////////

void bindConsole(std::unique_ptr<JSContext> &context) {
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_print__", 0, print);
}

} // namespace binding
} // namespace kraken
