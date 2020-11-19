/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "console.h"
#include <sstream>

#ifdef ENABLE_DEBUGGER
#include "JavaScriptCore/JSGlobalObject.h"
#include "JavaScriptCore/runtime/ConsoleTypes.h"
#include <devtools/impl/jsc_console_client_impl.h>
#endif

namespace kraken::binding::jsa {
namespace {
using namespace alibaba::jsa;
using namespace foundation;

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

} // namespace kraken
