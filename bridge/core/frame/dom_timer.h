/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOM_TIMER_H
#define KRAKENBRIDGE_DOM_TIMER_H

#include "bindings/qjs/garbage_collected.h"
#include "dom_timer_coordinator.h"

namespace kraken {

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

}  // namespace kraken

#endif  // KRAKENBRIDGE_DOM_TIMER_H
