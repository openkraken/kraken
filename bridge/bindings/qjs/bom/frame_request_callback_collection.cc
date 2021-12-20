/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "frame_request_callback_collection.h"

namespace kraken::binding::qjs {

JSClassID FrameCallback::frameCallbackClassId{0};
FrameCallback::FrameCallback(JSContext* ctx, JSValue callback) : m_callback(JS_DupValue(ctx, callback)), GarbageCollected<FrameCallback>(ctx) {}

void FrameCallback::fire(double highResTimeStamp) {
  /* 'callback' might be destroyed when calling itself (if it frees the
      handler), so must take extra care */
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(m_ctx));
  if (!JS_IsFunction(m_ctx, m_callback))
    return;

  JS_DupValue(m_ctx, m_callback);

  JSValue arguments[] = {JS_NewFloat64(m_ctx, highResTimeStamp)};

  JSValue returnValue = JS_Call(m_ctx, m_callback, JS_UNDEFINED, 1, arguments);
  JS_FreeValue(m_ctx, m_callback);

  if (JS_IsException(returnValue)) {
    context->handleException(&returnValue);
  }

  JS_FreeValue(m_ctx, returnValue);
}

}  // namespace kraken::binding::qjs
