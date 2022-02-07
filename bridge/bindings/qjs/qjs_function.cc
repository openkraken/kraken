/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_function.h"
#include <algorithm>

namespace kraken {

bool QJSFunction::isFunction(JSContext* ctx) {
  return JS_IsFunction(ctx, m_function);
}

ScriptValue QJSFunction::invoke(JSContext* ctx, int32_t argc, ScriptValue* arguments) {
  // 'm_function' might be destroyed when calling itself (if it frees the handler), so must take extra care.
  JS_DupValue(ctx, m_function);

  JSValue argv[std::max(1, argc)];

  for(int i = 0; i < argc; i ++) {
    argv[0 + i] = arguments[i].toQuickJS();
  }

  JSValue returnValue = JS_Call(ctx, m_function, JS_UNDEFINED, argc, argv);

  // Free the previous duplicated function.
  JS_FreeValue(m_ctx, m_function);

  return ScriptValue(ctx, returnValue);
}

const char* QJSFunction::getHumanReadableName() const {
  return "QJSFunction";
}

void QJSFunction::trace(Visitor* visitor) const {
  visitor->trace(m_function);
}

void QJSFunction::dispose() const {
  JS_FreeValueRT(m_runtime, m_function);
}
}
