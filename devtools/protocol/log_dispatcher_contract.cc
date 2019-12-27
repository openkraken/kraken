//
// Created by rowandjj on 2019/4/24.
//

#include "log_dispatcher_contract.h"
#include "devtools/protocol/log_dispatcher_impl.h"
namespace kraken{
    namespace Debugger {
        void LogDispatcherContract::wire(kraken::Debugger::UberDispatcher *uber,
                                         kraken::Debugger::LogBackend *backend) {
            std::unique_ptr<LogDispatcherImpl> dispatcher(new LogDispatcherImpl(uber->channel(), backend));
            uber->setupRedirects(dispatcher->redirects());
            uber->registerBackend("Log", std::move(dispatcher));
        }
    }
}