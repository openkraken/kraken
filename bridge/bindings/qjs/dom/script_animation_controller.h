/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_
#define BRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_

#include "bindings/qjs/garbage_collected.h"
#include "frame_request_callback_collection.h"

namespace webf::binding::qjs {

class ScriptAnimationController : public GarbageCollected<ScriptAnimationController> {
 public:
  static JSClassID classId;

  ScriptAnimationController* initialize(JSContext* ctx, JSClassID* classId) override;

  // Animation frame callbacks are used for requestAnimationFrame().
  uint32_t registerFrameCallback(FrameCallback* frameCallback);
  void cancelFrameCallback(uint32_t callbackId);

  [[nodiscard]] FORCE_INLINE const char* getHumanReadableName() const override { return "ScriptAnimationController"; }

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

 private:
  FrameRequestCallbackCollection m_frameRequestCallbackCollection;
};

}  // namespace webf::binding::qjs

#endif  // BRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_
