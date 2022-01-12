/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_BOM_DOM_TIMER_COORDINATOR_H_
#define KRAKENBRIDGE_BINDINGS_QJS_BOM_DOM_TIMER_COORDINATOR_H_

#include <quickjs/quickjs.h>
#include <unordered_map>
#include <vector>

namespace kraken::binding::qjs {

class ExecutionContext;
class DOMTimer;

// Maintains a set of DOMTimers for a given page
// DOMTimerCoordinator assigns IDs to timers; these IDs are
// the ones returned to web authors from setTimeout or setInterval. It
// also tracks recursive creation or iterative scheduling of timers,
// which is used as a signal for throttling repetitive timers.
class DOMTimerCoordinator {
 public:
  // Creates and installs a new timer. Returns the assigned ID.
  void installNewTimer(ExecutionContext* context, int32_t timerId, DOMTimer* timer);

  // Removes and disposes the timer with the specified ID, if any. This may
  // destroy the timer.
  void* removeTimeoutById(int32_t timerId);
  DOMTimer* getTimerById(int32_t timerId);

  void trace(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

 private:
  std::unordered_map<int, DOMTimer*> m_activeTimers;
  std::vector<DOMTimer*> m_abandonedTimers;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_BINDINGS_QJS_BOM_DOM_TIMER_COORDINATOR_H_
