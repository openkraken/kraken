//
// Created by rowandjj on 2019/4/23.
//

#include "page_dispatcher_contract.h"
#include "devtools/protocol/page_dispatcher_impl.h"

namespace kraken{
    namespace Debugger {
        void PageDispatcherContract::wire(kraken::Debugger::UberDispatcher *uber,
                                          kraken::Debugger::PageBackend *backend) {
            std::unique_ptr<PageDispatcherImpl> dispatcher(new PageDispatcherImpl(uber->channel(), backend));
            uber->setupRedirects(dispatcher->redirects());
            uber->registerBackend("Page", std::move(dispatcher));
        }
    }
}