/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "console.h"
#include <algorithm>
#include <cassert>
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

void logArgs(std::stringstream &stream, JSContext &context, const Value *args,
             size_t count, int start);

void printLog(std::stringstream &stream, foundation::LogSeverity level);

void logWithLevel(std::stringstream &stream, JSContext &context,
                  const Value &value);

void logArray(std::stringstream &stream, JSContext &context,
              const Array &value);

void logObject(std::stringstream &stream, JSContext &context,
               const Object &object);

void logFunction(std::stringstream &stream, JSContext &context,
                 const Function &func);

void logArgs(std::stringstream &stream, JSContext &context, const Value *args,
             size_t count, int start) {
  for (size_t i = start; i < count; i++) {
    logWithLevel(stream, context, args[i]);
    if (i != count - 1) {
      stream << " ";
    }
  }
}

void logWithLevel(std::stringstream &stream, JSContext &context,
                  const Value &value) {
  if (value.isString()) {
    stream << "'" << value.getString(context).utf8(context) << "'";
  } else if (value.isBool()) {
    if (value.getBool()) {
      stream << "true";
    } else {
      stream << "false";
    }
  } else if (value.isNumber()) {
    stream << value.getNumber();
  } else if (value.isNull()) {
    stream << "null";
  } else if (value.isUndefined()) {
    stream << "undefined";
  } else if (value.isObject()) {
    auto &&object = value.asObject(context);
    if (object.isArray(context)) {
      logArray(stream, context, object.asArray(context));
    } else if (object.isFunction(context)) {
      logFunction(stream, context, object.asFunction(context));
    } else {
      logObject(stream, context, object);
    }
  } else {
    stream << "unknown";
  }
}

void logArray(std::stringstream &stream, JSContext &context,
              const Array &array) {
  size_t length = array.length(context);
  stream << "[";
  for (size_t i = 0; i < length; i++) {
    auto &&value = array.getValueAtIndex(context, i);
    logWithLevel(stream, context, value);
    if (i < length - 1) {
      stream << ", ";
    }
  }
  stream << "]";
}

void logObject(std::stringstream &stream, JSContext &context,
               const Object &object) {
  auto &&names = object.getPropertyNames(context);
  size_t nameLength = names.length(context);

  stream << "{\n";
  for (size_t i = 0; i < nameLength; i++) {
    auto &&key = names.getValueAtIndex(context, i);
    auto &&value = object.getProperty(context, key.asString(context));
    stream << "  ";
    logWithLevel(stream, context, key);
    stream << ": ";
    logWithLevel(stream, context, value);
    if (i < nameLength - 1) {
      stream << ",\n";
    } else {
      stream << "\n";
    }
  }
  stream << "}";
}

void logFunction(std::stringstream &stream, JSContext &context,
                 const Function &func) {
  auto &&nameValue = func.getProperty(context, "name");
  std::string name = nameValue.asString(context).utf8(context);
  stream << "[Function: " << name << "]";
}

void printLog(std::stringstream &stream, foundation::LogSeverity level) {
#ifdef ENABLE_DEBUGGER
  JSC::MessageLevel _log_level = JSC::MessageLevel::Log;
#endif
  switch (level) {
  case foundation::LOG_VERBOSE:
    KRAKEN_LOG(VERBOSE) << "[JS_LOG] " << stream.str();
#ifdef ENABLE_DEBUGGER
    _log_level = JSC::MessageLevel::Log;
#endif
    break;
  case foundation::LOG_INFO:
    KRAKEN_LOG(INFO) << "[JS_LOG] " << stream.str();
#ifdef ENABLE_DEBUGGER
    _log_level = JSC::MessageLevel::Info;
#endif
    break;
  case foundation::LOG_DEBUG_:
    KRAKEN_LOG(DEBUG_) << "[JS_LOG] " << stream.str();
#ifdef ENABLE_DEBUGGER
    _log_level = JSC::MessageLevel::Debug;
#endif
    break;
  case foundation::LOG_WARN:
    KRAKEN_LOG(WARN) << "[JS_LOG] " << stream.str();
#ifdef ENABLE_DEBUGGER
    _log_level = JSC::MessageLevel::Warning;
#endif
    break;
  case foundation::LOG_ERROR:
    KRAKEN_LOG(ERROR) << "[JS_LOG] " << stream.str();
#ifdef ENABLE_DEBUGGER
    _log_level = JSC::MessageLevel::Error;
#endif
    break;
  default:
    KRAKEN_LOG(VERBOSE) << "[JS_LOG] " << stream.str();
  }

#ifdef ENABLE_DEBUGGER
  auto client = reinterpret_cast<JSC::JSGlobalObject *>(context.globalImpl())
                    ->consoleClient();
  if (client && client != ((void *)0x1)) {
    auto client_impl =
        reinterpret_cast<kraken::Debugger::JSCConsoleClientImpl *>(client);
    client_impl->sendMessageToConsole(_log_level, stream.str());
  }
#endif
}

Value log(JSContext &context, const Value &thisVal, const Value *args,
          size_t count) {
  std::stringstream stream;
  logArgs(stream, context, args, count, 0);
  printLog(stream, foundation::LOG_VERBOSE);
  return Value::undefined();
}

Value info(JSContext &context, const Value &thisVal, const Value *args,
           size_t count) {
  std::stringstream stream;
  logArgs(stream, context, args, count, 0);
  printLog(stream, foundation::LOG_INFO);
  return Value::undefined();
}

Value warn(JSContext &context, const Value &thisVal, const Value *args,
           size_t count) {
  std::stringstream stream;
  logArgs(stream, context, args, count, 0);
  printLog(stream, foundation::LOG_WARN);
  return Value::undefined();
}

Value debug(JSContext &context, const Value &thisVal, const Value *args,
            size_t count) {
  std::stringstream stream;
  logArgs(stream, context, args, count, 0);
  printLog(stream, foundation::LOG_DEBUG_);
  return Value::undefined();
}

Value error(JSContext &context, const Value &thisVal, const Value *args,
            size_t count) {
  std::stringstream stream;
  logArgs(stream, context, args, count, 0);
  printLog(stream, foundation::LOG_ERROR);
  return Value::undefined();
}

Value _assert(JSContext &context, const Value &thisVal, const Value *args,
              size_t count) {
  if (count == 0) {
    KRAKEN_LOG(ERROR) << "Assertion failed: console.assert";
    return Value::undefined();
  }

  auto &&expression = args[0];

  std::stringstream stream;
  if ((expression.isBool() && expression.getBool() == false) ||
      expression.isUndefined() || expression.isNull() ||
      (expression.isNumber() && expression.asNumber() == 0) ||
      (expression.isString() &&
       expression.asString(context).utf8(context).empty())) {
    stream << "Assertion failed:";

    if (count > 1) {
      logArgs(stream, context, args, count, 1);
      KRAKEN_LOG(WARN) << stream.str();
    } else {
      KRAKEN_LOG(WARN) << "console.assert";
    }
  }

  return Value::undefined();
}

} // namespace

////////////////

void bindConsole(std::unique_ptr<JSContext> &context) {
  auto console = JSA_CREATE_OBJECT(*context);
  JSA_BINDING_FUNCTION(*context, console, "log", 1, log);
  JSA_BINDING_FUNCTION(*context, console, "info", 1, info);
  JSA_BINDING_FUNCTION(*context, console, "warn", 1, warn);
  JSA_BINDING_FUNCTION(*context, console, "debug", 1, debug);
  JSA_BINDING_FUNCTION(*context, console, "error", 1, error);
  JSA_BINDING_FUNCTION(*context, console, "assert", 0, _assert);
  context->global().setProperty(*context, "console", console);
}

} // namespace binding
} // namespace kraken
