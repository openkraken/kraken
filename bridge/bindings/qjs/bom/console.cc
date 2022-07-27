/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "console.h"
#include "foundation/logging.h"

namespace webf::binding::qjs {

JSValue print(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  std::stringstream stream;
  JSValue log = argv[0];
  if (JS_IsString(log)) {
    const char* buffer = JS_ToCString(ctx, log);
    stream << buffer;
    JS_FreeCString(ctx, buffer);
  } else {
    return JS_ThrowTypeError(ctx, "Failed to execute 'print': log must be string.");
  }

  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  const char* logLevel = "info";
  JSValue level = argv[1];
  if (JS_IsString(level)) {
    logLevel = JS_ToCString(ctx, level);
    JS_FreeCString(ctx, logLevel);
  }

  foundation::printLog(context->getContextId(), stream, logLevel, nullptr);
  return JS_UNDEFINED;
}

void bindConsole(ExecutionContext* context) {
  QJS_GLOBAL_BINDING_FUNCTION(context, print, "__webf_print__", 2);
}

}  // namespace webf::binding::qjs
