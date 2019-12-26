//
// Created by rowandjj on 2019/4/1.
//

#ifndef KRAKEN_DEBUGGER_DEBUG_DISPATCHER_CONTRACT_H
#define KRAKEN_DEBUGGER_DEBUG_DISPATCHER_CONTRACT_H

#include "devtools/protocol/debugger_backend.h"
#include "devtools/protocol/uber_dispatcher.h"

namespace kraken{
    namespace Debugger{
        class DebuggerDispatcherContract {
        public:
            static void wire(UberDispatcher*, DebuggerBackend*);

        private:
            DebuggerDispatcherContract() { }
        };
    }
}

#endif //KRAKEN_DEBUGGER_DEBUG_DISPATCHER_CONTRACT_H
