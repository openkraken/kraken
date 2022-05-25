/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_RESOLVER_H_
#define KRAKENBRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_RESOLVER_H_

#include "converter_impl.h"
#include "script_promise.h"
#include "to_quickjs.h"

namespace kraken {

class ScriptPromiseResolver {
 public:
  static std::shared_ptr<ScriptPromiseResolver> Create(ExecutingContext* context);
  ScriptPromiseResolver() = delete;
  ScriptPromiseResolver(ExecutingContext* context);
  ~ScriptPromiseResolver();

  // Return a promise object and wait to be resolve or reject.
  // Note that an empty ScriptPromise will be returned after resolve or
  // reject is called.
  ScriptPromise Promise();

  // Anything that can be passed to toQuickJS can be passed to this function.
  template <typename T>
  void Resolve(T value) {
    ResolveOrReject(value, kResolving);
  }

  // Anything that can be passed to toQuickJS can be passed to this function.
  template <typename T>
  void Reject(T value) {
    ResolveOrReject(value, kRejecting);
  }

 private:
  enum ResolutionState {
    kPending,
    kResolving,
    kRejecting,
    kDetached,
  };

  ExecutingContext* GetExecutionContext() const { return context_; }

  template <typename T>
  void ResolveOrReject(T value, ResolutionState new_state) {
    if (state_ != kPending || !context_->IsValid() || !context_)
      return;
    assert(new_state == kResolving || new_state == kRejecting);
    state_ = new_state;
    JSValue qjs_value = toQuickJS(context_->ctx(), value);
    ResolveOrRejectImmediately(qjs_value);
    JS_FreeValue(context_->ctx(), qjs_value);
  }

  void ResolveOrRejectImmediately(JSValue value);

  ResolutionState state_;
  ExecutingContext* context_{nullptr};
  JSValue promise_{JS_NULL};
  JSValue resolve_func_{JS_NULL};
  JSValue reject_func_{JS_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_SCRIPT_PROMISE_RESOLVER_H_
