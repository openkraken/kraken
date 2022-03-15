/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_
#define KRAKENBRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_

#include "core/executing_context.h"
#include "bindings/qjs/script_wrappable.h"

namespace kraken {

// |FrameCallback| is an interface type which generalizes callbacks which are
// invoked when a script-based animation needs to be resampled.
class FrameCallback {
 public:
  FrameCallback(ExecutingContext* context, JSValue callback);

  void Fire(double highResTimeStamp);

  ExecutingContext* context() { return context_; };

  void Trace(GCVisitor* visitor) const;
  void Dispose() const;

 private:
  JSValue callback_{JS_NULL};
  int32_t callbackId_{-1};
  ExecutingContext* context_{nullptr};
};

class FrameRequestCallbackCollection final {
 public:
  void Trace(GCVisitor* visitor);
  void RegisterFrameCallback(uint32_t callbackId, FrameCallback* frameCallback);
  void CancelFrameCallback(uint32_t callbackId);

 private:
  std::unordered_map<uint32_t, FrameCallback*> frameCallbacks_;
  std::vector<FrameCallback*> abandonedCallbacks_;
};

}  // namespace kraken

class frame_request_callback_collection {};

#endif  // KRAKENBRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_
