/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "frame_request_callback_collection.h"

namespace kraken {

FrameCallback::FrameCallback(ExecutingContext* context, JSValue callback) : context_(context), callback_(callback) {}

void FrameCallback::Fire(double highResTimeStamp) {
  if (!JS_IsFunction(context_->ctx(), callback_))
    return;

  /* 'callback' might be destroyed when calling itself (if it frees the
    handler), so must take extra care */
  JS_DupValue(context_->ctx(), callback_);

  JSValue arguments[] = {JS_NewFloat64(context_->ctx(), highResTimeStamp)};

  JSValue returnValue = JS_Call(context_->ctx(), callback_, JS_UNDEFINED, 1, arguments);

  context_->DrainPendingPromiseJobs();
  JS_FreeValue(context_->ctx(), callback_);

  if (JS_IsException(returnValue)) {
    context_->HandleException(&returnValue);
  }

  JS_FreeValue(context_->ctx(), returnValue);
}

void FrameCallback::Trace(GCVisitor* visitor) const {
  visitor->Trace(callback_);
}

void FrameCallback::Dispose() const {
  JS_FreeValueRT(JS_GetRuntime(context_->ctx()), callback_);
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

void FrameRequestCallbackCollection::Trace(GCVisitor* visitor) {
  for (auto& callback : frameCallbacks_) {
    callback.second->Trace(visitor);
  }

  // Recycle all abandoned callbacks.
  if (!abandonedCallbacks_.empty()) {
    for (auto& callback : abandonedCallbacks_) {
      callback->Trace(visitor);
    }
    // All abandoned timers should be freed at the sweep stage.
    abandonedCallbacks_.clear();
  }
}

}  // namespace kraken
