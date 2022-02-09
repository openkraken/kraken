/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EXCEPTION_STATE_H
#define KRAKENBRIDGE_EXCEPTION_STATE_H

#include <quickjs/quickjs.h>
#include "foundation/macros.h"

namespace kraken {

enum ErrorType { TypeError, InternalError, RangeError, ReferenceError, SyntaxError };

// ExceptionState is a scope-like class and provides a way to store an exception.
class ExceptionState {
  // ExceptionState should only allocate at stack.
  KRAKEN_DISALLOW_NEW();

 public:
  void throwException(JSContext* ctx, ErrorType type, const char* message);
  void throwException(JSContext* ctx, JSValue exception);
  bool hasException();
  JSValue toQuickJS();

 private:
  JSValue m_exception{JS_NULL};
  JSContext* m_ctx;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_EXCEPTION_STATE_H
