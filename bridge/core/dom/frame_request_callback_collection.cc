/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "frame_request_callback_collection.h"

namespace kraken {

FrameCallback::FrameCallback(JSContext* ctx, JSValue callback) : callback_(callback), ScriptWrappable(ctx) {}

void FrameCallback::Fire(double highResTimeStamp) {
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx()));
  if (!JS_IsFunction(ctx(), callback_))
    return;

  /* 'callback' might be destroyed when calling itself (if it frees the
    handler), so must take extra care */
  JS_DupValue(ctx(), callback_);

  JSValue arguments[] = {JS_NewFloat64(ctx(), highResTimeStamp)};

  JSValue returnValue = JS_Call(ctx(), callback_, JS_UNDEFINED, 1, arguments);

  context->drainPendingPromiseJobs();
  JS_FreeValue(ctx(), callback_);

  if (JS_IsException(returnValue)) {
    context->handleException(&returnValue);
  }

  JS_FreeValue(ctx(), returnValue);
}

void FrameCallback::Trace(GCVisitor* visitor) const {
  visitor->Trace(callback_);
}

void FrameCallback::Dispose() const {
  JS_FreeValueRT(JS_GetRuntime(ctx()), callback_);
}

void FrameRequestCallbackCollection::RegisterFrameCallback(uint32_t callbackId, FrameCallback* frameCallback) {
  frameCallbacks_[callbackId] = frameCallback;
}

void FrameRequestCallbackCollection::CancelFrameCallback(uint32_t callbackId) {
  if (frameCallbacks_.count(callbackId) == 0)
    return;
  FrameCallback* callback = frameCallbacks_[callbackId];

  // Push this timer to abandoned list to mark this timer is deprecated.
  abandonedCallbacks_.emplace_back(callback);

  frameCallbacks_.erase(callbackId);
}

void FrameRequestCallbackCollection::Trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  for (auto& callback : frameCallbacks_) {
    JS_MarkValue(rt, callback.second->ToQuickJS(), mark_func);
  }

  // Recycle all abandoned callbacks.
  if (!abandonedCallbacks_.empty()) {
    for (auto& callback : abandonedCallbacks_) {
      JS_MarkValue(rt, callback->ToQuickJS(), mark_func);
    }
    // All abandoned timers should be freed at the sweep stage.
    abandonedCallbacks_.clear();
  }
}

}  // namespace kraken
