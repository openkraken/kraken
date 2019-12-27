//
// Created by rowandjj on 2019/4/23.
//

#ifndef KRAKEN_DEBUGGER_PAGE_DISPATCHER_CONTRACT_H
#define KRAKEN_DEBUGGER_PAGE_DISPATCHER_CONTRACT_H

#include "devtools/protocol/uber_dispatcher.h"
#include "devtools/protocol/page_backend.h"

namespace kraken{
    namespace Debugger {
        class PageDispatcherContract {
        public:
            static void wire(UberDispatcher*, PageBackend*);
        private:
            PageDispatcherContract() {}
        };
    }
}

#endif //KRAKEN_DEBUGGER_PAGE_DISPATCHER_CONTRACT_H
