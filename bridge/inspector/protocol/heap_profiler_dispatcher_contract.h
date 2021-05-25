/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_HEAP_PROFILER_DISPATCHER_CONTRACT_H
#define KRAKEN_DEBUGGER_HEAP_PROFILER_DISPATCHER_CONTRACT_H

#include "inspector/protocol/heap_profiler_backend.h"
#include "inspector/protocol/uber_dispatcher.h"

namespace kraken {
namespace debugger {
class HeapProfilerDispatcherContract {

public:
  static void wire(UberDispatcher *, HeapProfilerBackend *);

private:
  HeapProfilerDispatcherContract() {}
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_HEAP_PROFILER_DISPATCHER_CONTRACT_H
