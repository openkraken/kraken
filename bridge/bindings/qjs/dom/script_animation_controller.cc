/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_animation_controller.h"
#include "dart_methods.h"
#include "frame_request_callback_collection.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken::binding::qjs {

JSClassID ScriptAnimationController::classId{0};

void ScriptAnimationController::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  auto* controller = static_cast<ScriptAnimationController*>(JS_GetOpaque(val, ScriptAnimationController::classId));
  controller->m_frameRequestCallbackCollection.trace(rt, JS_UNDEFINED, mark_func);
}
void ScriptAnimationController::dispose() const {}

ScriptAnimationController* ScriptAnimationController::initialize(JSContext* ctx, JSClassID* classId) {
  return GarbageCollected::initialize(ctx, classId);
}

static void handleRAFTransientCallback(void* ptr, int32_t contextId, double highResTimeStamp, const char* errmsg) {
  auto* frameCallback = static_cast<FrameCallback*>(ptr);
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(frameCallback->ctx()));

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

uint32_t ScriptAnimationController::registerFrameCallback(FrameCallback* frameCallback) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(m_ctx));

  uint32_t requestId = getDartMethod()->requestAnimationFrame(frameCallback, context->getContextId(), handleRAFTransientCallback);

  // Register frame callback to collection.
  m_frameRequestCallbackCollection.registerFrameCallback(requestId, frameCallback);

  return requestId;
}
void ScriptAnimationController::cancelFrameCallback(uint32_t callbackId) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(m_ctx));

  getDartMethod()->cancelAnimationFrame(context->getContextId(), callbackId);

  m_frameRequestCallbackCollection.cancelFrameCallback(callbackId);
}

}  // namespace kraken::binding::qjs
