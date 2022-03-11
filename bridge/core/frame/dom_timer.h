/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOM_TIMER_H
#define KRAKENBRIDGE_DOM_TIMER_H

#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/qjs_function.h"
#include "dom_timer_coordinator.h"

namespace kraken {

class DOMTimer : public GarbageCollected<DOMTimer> {
 public:
  DOMTimer(ExecutingContext* context, QJSFunction* callback);

  // Trigger timer callback.
  void Fire();

  int32_t timerId() const { return timerId_; };
  void setTimerId(int32_t timerId);

  ExecutingContext* context() { return context_; }

  [[nodiscard]] FORCE_INLINE const char* GetHumanReadableName() const override { return "DOMTimer"; }

  void Trace(GCVisitor* visitor) const override;
  void Dispose() const override;

 private:
  ExecutingContext* context_{nullptr};
  int32_t timerId_{-1};
  int32_t isInterval_{false};
  QJSFunction* callback_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_DOM_TIMER_H
