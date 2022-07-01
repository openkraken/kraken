/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOM_TIMER_H
#define KRAKENBRIDGE_DOM_TIMER_H

#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/script_wrappable.h"
#include "dom_timer_coordinator.h"

namespace kraken {

class DOMTimer {
 public:
  enum TimerStatus { kPending, kExecuting, kFinished };

  static std::shared_ptr<DOMTimer> create(ExecutingContext* context, const std::shared_ptr<QJSFunction>& callback);
  DOMTimer(ExecutingContext* context, std::shared_ptr<QJSFunction> callback);

  // Trigger timer callback.
  void Fire();

  [[nodiscard]] int32_t timerId() const { return timerId_; };
  void setTimerId(int32_t timerId);

  void SetStatus(TimerStatus status) { status_ = status; }
  [[nodiscard]] TimerStatus status() const { return status_; }

  ExecutingContext* context() { return context_; }

 private:
  ExecutingContext* context_{nullptr};
  int32_t timerId_{-1};
  int32_t isInterval_{false};
  TimerStatus status_;
  std::shared_ptr<QJSFunction> callback_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_DOM_TIMER_H
