/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_
#define KRAKENBRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_

#include "bindings/qjs/garbage_collected.h"
#include "frame_request_callback_collection.h"

namespace kraken::binding::qjs {

class ScriptAnimationController : public GarbageCollected<ScriptAnimationController> {
 public:
  static JSClassID classId;

  ScriptAnimationController* initialize(JSContext* ctx, JSClassID* classId) override;

  // Animation frame callbacks are used for requestAnimationFrame().
  uint32_t registerFrameCallback(FrameCallback* frameCallback);
  void cancelFrameCallback(uint32_t callbackId);

  [[nodiscard]] FORCE_INLINE const char* getHumanReadableName() const override { return "ScriptAnimationController"; }

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;

 private:
  FrameRequestCallbackCollection m_frameRequestCallbackCollection;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_
