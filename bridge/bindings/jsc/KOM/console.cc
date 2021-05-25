/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "console.h"
#include "foundation/logging.h"
#include <sstream>

#ifdef ENABLE_DEBUGGER
#include "JavaScriptCore/JSGlobalObject.h"
#include "JavaScriptCore/ConsoleTypes.h"
#endif

namespace kraken::binding::jsc {
namespace {

JSValueRef print(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                 const JSValueRef arguments[], JSValueRef *exception) {
  std::stringstream stream;
  const JSValueRef &log = arguments[0];
  if (JSValueIsString(ctx, log)) {
    JSStringRef str = JSValueToStringCopy(ctx, log, nullptr);
    int32_t length = JSStringGetMaximumUTF8CStringSize(str);
    char buffer[length];
    JSStringGetUTF8CString(str, buffer, length);
    JSStringRelease(str);
    stream << buffer;
  } else {
    KRAKEN_LOG(ERROR) << "Failed to execute 'print': log must be string.";
    return JSValueMakeUndefined(ctx);
  }

  std::string logLevel = "log";
  const JSValueRef &level = arguments[1];
  if (JSValueIsString(ctx, level)) {
    logLevel = std::move(JSStringToStdString(JSValueToStringCopy(ctx, level, nullptr)));
  }

  foundation::printLog(stream, logLevel, JSContextGetGlobalObject(ctx));

  return JSValueMakeUndefined(ctx);
}

} // namespace

////////////////

void bindConsole(std::unique_ptr<JSContext> &context) {
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_print__", print);
}

} // namespace kraken::binding::jsc
