//
// Created by rowandjj on 2019/4/24.
//

#ifndef KRAKEN_DEBUGGER_LOG_DISPATCHER_CONTRACT_H
#define KRAKEN_DEBUGGER_LOG_DISPATCHER_CONTRACT_H

#include "devtools/protocol/uber_dispatcher.h"
#include "devtools/protocol/log_backend.h"

namespace kraken{
    namespace Debugger {
        class LogDispatcherContract {
        public:
            static void wire(UberDispatcher *, LogBackend *);

        private:
            LogDispatcherContract() {}
        };
    }
}

#endif //KRAKEN_DEBUGGER_LOG_DISPATCHER_CONTRACT_H
