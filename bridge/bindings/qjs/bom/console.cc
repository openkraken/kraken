/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "console.h"

namespace kraken::binding::qjs {

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

void bindConsole(std::unique_ptr<ExecutionContext>& context) {
  QJS_GLOBAL_BINDING_FUNCTION(context, print, "__kraken_print__", 2);
}

}  // namespace kraken::binding::qjs
