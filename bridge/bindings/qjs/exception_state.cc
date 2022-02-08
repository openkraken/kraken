/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "exception_state.h"

namespace kraken {

void ExceptionState::throwException(JSContext* ctx, ErrorType type, const char* message) {
  switch(type) {
    case ErrorType::TypeError:
      m_exception = JS_ThrowTypeError(ctx, "%s", message);
      break;
    case InternalError :
      m_exception = JS_ThrowInternalError(ctx, "%s", message);
      break;
    case RangeError:
      m_exception = JS_ThrowRangeError(ctx, "%s", message);
      break;
    case ReferenceError:
      m_exception = JS_ThrowReferenceError(ctx, "%s", message);
      break;
    case SyntaxError:
      m_exception = JS_ThrowSyntaxError(ctx, "%s", message);
      break;
  }
}

void ExceptionState::throwException(JSContext* ctx, JSValue exception) {
  m_exception = JS_DupValue(ctx, exception);
}

bool ExceptionState::hasException() {
  return !JS_IsNull(m_exception);
}

JSValue ExceptionState::toQuickJS() {
  return m_exception;
}

}
