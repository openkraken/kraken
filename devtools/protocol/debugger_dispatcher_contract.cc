//
// Created by rowandjj on 2019/4/2.
//

#include "devtools/protocol/debugger_dispatcher_contract.h"
#include "devtools/protocol/debug_dispatcher_impl.h"

namespace kraken{
    namespace Debugger {
        void DebuggerDispatcherContract::wire(Debugger::UberDispatcher *uber, Debugger::DebuggerBackend *backend) {
            std::unique_ptr<DebugDispatcherImpl> dispatcher(new DebugDispatcherImpl(uber->channel(), backend));
            uber->setupRedirects(dispatcher->redirects());
            uber->registerBackend("Debugger", std::move(dispatcher));
        }
    }
}