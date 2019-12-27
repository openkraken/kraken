//
// Created by rowandjj on 2019/4/17.
//

#include "devtools/protocol/runtime_dispatcher_contract.h"
#include "devtools/protocol/runtime_dispatcher_impl.h"

namespace kraken{
    namespace Debugger {
        void RuntimeDispatcherContract::wire(kraken::Debugger::UberDispatcher *uber,
                                             kraken::Debugger::RuntimeBackend *backend) {
            std::unique_ptr<RuntimeDispatcherImpl> dispatcher(new RuntimeDispatcherImpl(uber->channel(), backend));
            uber->setupRedirects(dispatcher->redirects());
            uber->registerBackend("Runtime", std::move(dispatcher));
        }
    }
}