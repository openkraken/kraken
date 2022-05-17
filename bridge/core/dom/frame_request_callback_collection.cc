/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "frame_request_callback_collection.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace kraken {

std::shared_ptr<FrameCallback> FrameCallback::Create(ExecutingContext* context,
                                                     const std::shared_ptr<QJSFunction>& callback) {
  return std::make_shared<FrameCallback>(context, callback);
}

FrameCallback::FrameCallback(ExecutingContext* context, const std::shared_ptr<QJSFunction>& callback)
    : context_(context), callback_(callback) {}

void FrameCallback::Fire(double highResTimeStamp) {
  if (callback_ == nullptr)
    return;

  JSContext* ctx = context_->ctx();

  ScriptValue arguments[] = {ScriptValue(ctx, highResTimeStamp)};

  ScriptValue return_value = callback_->Invoke(ctx, ScriptValue::Empty(ctx), 1, arguments);

  context_->DrainPendingPromiseJobs();
  if (return_value.IsException()) {
    context_->HandleException(&return_value);
  }
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
