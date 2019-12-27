//
// Created by rowandjj on 2019/4/17.
//

#ifndef KRAKEN_DEBUGGER_RUNTIME_DISPATCHER_CONTRACT_H
#define KRAKEN_DEBUGGER_RUNTIME_DISPATCHER_CONTRACT_H

#include "devtools/protocol/uber_dispatcher.h"
#include "devtools/protocol/runtime_backend.h"

namespace kraken{
    namespace Debugger {
        class RuntimeDispatcherContract {
        public:
            static void wire(UberDispatcher*, RuntimeBackend*);
        private:
            RuntimeDispatcherContract(){}
        };
    }
}



#endif //KRAKEN_DEBUGGER_RUNTIME_DISPATCHER_CONTRACT_H
