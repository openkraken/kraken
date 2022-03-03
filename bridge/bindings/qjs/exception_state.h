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
  void ThrowException(JSContext* ctx, ErrorType type, const char* message);
  void ThrowException(JSContext* ctx, JSValue exception);
  bool HasException();
  JSValue ToQuickJS();

 private:
  JSValue exception_{JS_NULL};
  JSContext* ctx_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_EXCEPTION_STATE_H
