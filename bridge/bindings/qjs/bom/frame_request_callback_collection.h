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
  FrameCallback(JSContext* ctx, JSValue callback);

  void fire(double highResTimeStamp);

  static JSClassID frameCallbackClassId;

 private:
  JSValue m_callback{JS_NULL};
};

class FrameRequestCallbackCollection final {
 public:
 private:
};

}  // namespace kraken::binding::qjs

class frame_request_callback_collection {};

#endif  // KRAKENBRIDGE_BINDINGS_QJS_BOM_FRAME_REQUEST_CALLBACK_COLLECTION_H_
