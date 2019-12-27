//
// Created by rowandjj on 2019-06-11.
//

#include "heap_profiler_dispatcher_contract.h"
#include "devtools/protocol/heap_profiler_dispatcher_impl.h"

namespace kraken{
    namespace Debugger {
        void HeapProfilerDispatcherContract::wire(kraken::Debugger::UberDispatcher *uber,
                                                  kraken::Debugger::HeapProfilerBackend *backend) {
            std::unique_ptr<HeapProfilerDispatcherImpl> dispatcher(new HeapProfilerDispatcherImpl(uber->channel(), backend));
            uber->setupRedirects(dispatcher->redirects());
            uber->registerBackend("HeapProfiler", std::move(dispatcher));
        }
    }
}