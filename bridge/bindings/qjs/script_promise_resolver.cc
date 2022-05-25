/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_promise_resolver.h"
#include "core/executing_context.h"
#include "pending_promises.h"

namespace kraken {

std::shared_ptr<ScriptPromiseResolver> ScriptPromiseResolver::Create(ExecutingContext* context) {
  return std::make_shared<ScriptPromiseResolver>(context);
}

ScriptPromiseResolver::ScriptPromiseResolver(ExecutingContext* context) : context_(context) {
  JSValue resolving_funcs[2];
  promise_ = JS_NewPromiseCapability(context->ctx(), resolving_funcs);
  resolve_func_ = resolving_funcs[0];
  reject_func_ = resolving_funcs[1];

  context->GetPendingPromises()->TrackPendingPromises(ScriptPromise(context_->ctx(), promise_));
}

ScriptPromiseResolver::~ScriptPromiseResolver() {
  JS_FreeValue(context_->ctx(), promise_);
  JS_FreeValue(context_->ctx(), resolve_func_);
  JS_FreeValue(context_->ctx(), reject_func_);
}

ScriptPromise ScriptPromiseResolver::Promise() {
  return ScriptPromise(context_->ctx(), promise_);
}

void ScriptPromiseResolver::ResolveOrRejectImmediately(JSValue value) {
  {
    if (state_ == kResolving) {
      JSValue arguments[] = {value};
      JSValue return_value = JS_Call(context_->ctx(), resolve_func_, JS_NULL, 1, arguments);
      if (JS_IsException(return_value)) {
        context_->HandleException(&return_value);
      }
      JS_FreeValue(context_->ctx(), return_value);
    } else {
      assert(state_ == kRejecting);
      JSValue arguments[] = {value};
      JSValue return_value = JS_Call(context_->ctx(), reject_func_, JS_NULL, 1, arguments);
      if (JS_IsException(return_value)) {
        context_->HandleException(&return_value);
      }
      JS_FreeValue(context_->ctx(), return_value);
    }
  }
  context_->DrainPendingPromiseJobs();
}

}  // namespace kraken
