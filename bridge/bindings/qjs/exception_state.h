/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EXCEPTION_STATE_H
#define KRAKENBRIDGE_EXCEPTION_STATE_H

#include <quickjs/quickjs.h>
#include <string>
#include "foundation/macros.h"

#define ASSERT_NO_EXCEPTION() ExceptionState().ReturnThis()

namespace kraken {

enum ErrorType { TypeError, InternalError, RangeError, ReferenceError, SyntaxError };

// ExceptionState is a scope-like class and provides a way to store an exception.
class ExceptionState {
  // ExceptionState should only allocate at stack.
  KRAKEN_DISALLOW_NEW();

 public:
  void ThrowException(JSContext* ctx, ErrorType type, const std::string& message);
  void ThrowException(JSContext* ctx, JSValue exception);
  bool HasException();

  ExceptionState& ReturnThis();

  JSValue ToQuickJS();

 private:
  JSValue exception_{JS_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_EXCEPTION_STATE_H
