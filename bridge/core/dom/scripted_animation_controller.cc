/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "scripted_animation_controller.h"
#include "frame_request_callback_collection.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken {

// void ScriptAnimationController::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
//  auto* controller = static_cast<ScriptAnimationController*>(JS_GetOpaque(val, ScriptAnimationController::classId));
//  controller->frame_request_callback_collection_.trace(rt, JS_UNDEFINED, mark_func);
//}

static void handleRAFTransientCallback(void* ptr, int32_t contextId, double highResTimeStamp, const char* errmsg) {
  auto* frameCallback = static_cast<FrameCallback*>(ptr);
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(frameCallback->ctx()));

  if (!context->isValid())
    return;

  if (errmsg != nullptr) {
    JSValue exception = JS_ThrowTypeError(frameCallback->ctx(), "%s", errmsg);
    context->handleException(&exception);
    return;
  }

  // Trigger callbacks.
  frameCallback->fire(highResTimeStamp);

  context->drainPendingPromiseJobs();
}

uint32_t ScriptAnimationController::RegisterFrameCallback(const std::shared_ptr<FrameCallback>& callback) {
  //  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(m_ctx));

  uint32_t requestId =
      getDartMethod()->requestAnimationFrame(frameCallback, context->getContextId(), handleRAFTransientCallback);

  // Register frame callback to collection.
  frame_request_callback_collection_.registerFrameCallback(requestId, frameCallback);

  return requestId;
}
void ScriptAnimationController::CancelFrameCallback(uint32_t callbackId) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(m_ctx));

  getDartMethod()->cancelAnimationFrame(context->getContextId(), callbackId);

  frame_request_callback_collection_.cancelFrameCallback(callbackId);
}

void ScriptAnimationController::Trace(GCVisitor* visitor) const {}

}  // namespace kraken
