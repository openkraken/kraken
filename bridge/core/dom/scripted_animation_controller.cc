/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "scripted_animation_controller.h"
#include "frame_request_callback_collection.h"

namespace kraken {

static void handleRAFTransientCallback(void* ptr, int32_t contextId, double highResTimeStamp, const char* errmsg) {
  auto* frame_callback = static_cast<FrameCallback*>(ptr);
  auto* context = frame_callback->context();

  if (!context->IsValid())
    return;

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(frame_callback->context()->ctx(), "%s", errmsg);
    context->HandleException(&exception);
    return;
  }

  // Trigger callbacks.
  frame_callback->Fire(highResTimeStamp);
}

uint32_t ScriptAnimationController::RegisterFrameCallback(const std::shared_ptr<FrameCallback>& frame_callback, ExceptionState& exception_state) {
  auto* context = frame_callback->context();

  if (context->dartMethodPtr()->requestAnimationFrame == nullptr) {
    exception_state.ThrowException(context->ctx(), ErrorType::InternalError, "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) is not registered.");
    return -1;
  }

  uint32_t requestId = context->dartMethodPtr()->requestAnimationFrame(frame_callback.get(), context->contextId(),
                                                                       handleRAFTransientCallback);

  // Register frame callback to collection.
  frame_request_callback_collection_.RegisterFrameCallback(requestId, frame_callback);

  return requestId;
}

void ScriptAnimationController::CancelFrameCallback(ExecutingContext* context,
                                                    uint32_t callbackId,
                                                    ExceptionState& exception_state) {
  if (context->dartMethodPtr()->cancelAnimationFrame == nullptr) {
    exception_state.ThrowException(context->ctx(), ErrorType::InternalError, "Failed to execute 'cancelAnimationFrame': dart method (cancelAnimationFrame) is not registered.");
    return;
  }

  context->dartMethodPtr()->cancelAnimationFrame(context->contextId(), callbackId);
  frame_request_callback_collection_.CancelFrameCallback(callbackId);
}

void ScriptAnimationController::Trace(GCVisitor* visitor) const {
  frame_request_callback_collection_.Trace(visitor);
}

}  // namespace kraken
