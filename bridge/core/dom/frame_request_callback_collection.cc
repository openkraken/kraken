/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "frame_request_callback_collection.h"

#include <utility>
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace kraken {

std::shared_ptr<FrameCallback> FrameCallback::Create(ExecutingContext* context,
                                                     const std::shared_ptr<QJSFunction>& callback) {
  return std::make_shared<FrameCallback>(context, callback);
}

FrameCallback::FrameCallback(ExecutingContext* context, std::shared_ptr<QJSFunction> callback)
    : context_(context), callback_(std::move(callback)) {}

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

void FrameCallback::Trace(GCVisitor* visitor) const {
  callback_->Trace(visitor);
}

void FrameRequestCallbackCollection::RegisterFrameCallback(uint32_t callback_id,
                                                           const std::shared_ptr<FrameCallback>& frame_callback) {
  frameCallbacks_[callback_id] = frame_callback;
}

void FrameRequestCallbackCollection::CancelFrameCallback(uint32_t callbackId) {
  if (frameCallbacks_.count(callbackId) == 0)
    return;
  frameCallbacks_.erase(callbackId);
}

void FrameRequestCallbackCollection::Trace(GCVisitor* visitor) const {
  for (auto& entry : frameCallbacks_) {
    entry.second->Trace(visitor);
  }
}

}  // namespace kraken
