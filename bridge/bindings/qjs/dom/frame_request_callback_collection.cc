/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "frame_request_callback_collection.h"

namespace kraken::binding::qjs {

JSClassID FrameCallback::classId{0};
FrameCallback::FrameCallback(JSValue callback) : m_callback(callback) {}

void FrameCallback::fire(double highResTimeStamp) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(m_ctx));
  if (!JS_IsFunction(m_ctx, m_callback))
    return;

  /* 'callback' might be destroyed when calling itself (if it frees the
    handler), so must take extra care */
  JS_DupValue(m_ctx, m_callback);

  JSValue arguments[] = {JS_NewFloat64(m_ctx, highResTimeStamp)};

  JSValue returnValue = JS_Call(m_ctx, m_callback, JS_UNDEFINED, 1, arguments);
  JS_FreeValue(m_ctx, m_callback);

  if (JS_IsException(returnValue)) {
    context->handleException(&returnValue);
  }

  JS_FreeValue(m_ctx, returnValue);
}

void FrameCallback::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  JS_MarkValue(rt, m_callback, mark_func);
}

void FrameRequestCallbackCollection::registerFrameCallback(uint32_t callbackId, FrameCallback* frameCallback) {
  m_frameCallbacks[callbackId] = frameCallback;
}

void FrameRequestCallbackCollection::cancelFrameCallback(uint32_t callbackId) {
  if (m_frameCallbacks.count(callbackId) == 0)
    return;
  FrameCallback* callback = m_frameCallbacks[callbackId];

  // Push this timer to abandoned list to mark this timer is deprecated.
  m_abandonedCallbacks.emplace_back(callback);

  m_frameCallbacks.erase(callbackId);
}

void FrameRequestCallbackCollection::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  for (auto& callback : m_frameCallbacks) {
    JS_MarkValue(rt, callback.second->toQuickJS(), mark_func);
  }

  // Recycle all abandoned callbacks.
  if (!m_abandonedCallbacks.empty()) {
    for (auto& callback : m_abandonedCallbacks) {
      JS_MarkValue(rt, callback->toQuickJS(), mark_func);
    }
    // All abandoned timers should be freed at the sweep stage.
    m_abandonedCallbacks.clear();
  }
}

}  // namespace kraken::binding::qjs
