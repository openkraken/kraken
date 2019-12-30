//
// Created by rowandjj on 2019-06-11.
//

#ifndef KRAKEN_DEBUGGER_HEAP_PROFILER_DISPATCHER_CONTRACT_H
#define KRAKEN_DEBUGGER_HEAP_PROFILER_DISPATCHER_CONTRACT_H

#include "devtools/protocol/uber_dispatcher.h"
#include "devtools/protocol/heap_profiler_backend.h"

namespace kraken{
    namespace Debugger {
        class HeapProfilerDispatcherContract {

        public:
            static void wire(UberDispatcher*, HeapProfilerBackend*);

        private:
            HeapProfilerDispatcherContract() { }
        };
    }
}


#endif //KRAKEN_DEBUGGER_HEAP_PROFILER_DISPATCHER_CONTRACT_H
