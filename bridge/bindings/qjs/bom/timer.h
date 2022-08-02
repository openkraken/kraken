/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_TIMER_H
#define BRIDGE_TIMER_H

#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/garbage_collected.h"
#include "dom_timer_coordinator.h"

namespace webf::binding::qjs {

class DOMTimer : public GarbageCollected<DOMTimer> {
 public:
  static JSClassID classId;
  DOMTimer(JSValue callback);

  // Trigger timer callback.
  void fire();

  int32_t timerId();
  void setTimerId(int32_t timerId);

  [[nodiscard]] FORCE_INLINE const char* getHumanReadableName() const override { return "DOMTimer"; }

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

 private:
  int32_t m_timerId{-1};
  int32_t m_isInterval{false};
  JSValue m_callback;
};

void bindTimer(ExecutionContext* context);

}  // namespace webf::binding::qjs

#endif  // BRIDGE_TIMER_H
