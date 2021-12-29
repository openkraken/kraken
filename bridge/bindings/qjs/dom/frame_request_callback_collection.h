/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_
#define KRAKENBRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_

#include "bindings/qjs/executing_context.h"

namespace kraken::binding::qjs {

// |FrameCallback| is an interface type which generalizes callbacks which are
// invoked when a script-based animation needs to be resampled.
class FrameCallback : public GarbageCollected<FrameCallback> {
 public:
  static JSClassID classId;

  FrameCallback(JSValue callback);

  void fire(double highResTimeStamp);

  [[nodiscard]] FORCE_INLINE const char* getHumanReadableName() const override { return "FrameCallback"; }

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

 private:
  JSValue m_callback{JS_NULL};
  int32_t m_callbackId{-1};
};

class FrameRequestCallbackCollection final {
 public:
  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func);
  void registerFrameCallback(uint32_t callbackId, FrameCallback* frameCallback);
  void cancelFrameCallback(uint32_t callbackId);

 private:
  std::unordered_map<uint32_t, FrameCallback*> m_frameCallbacks;
  std::vector<FrameCallback*> m_abandonedCallbacks;
};

}  // namespace kraken::binding::qjs

class frame_request_callback_collection {};

#endif  // KRAKENBRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_
