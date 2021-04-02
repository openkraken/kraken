/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "heap_profiler_dispatcher_contract.h"
#include "inspector/protocol/heap_profiler_dispatcher_impl.h"

namespace kraken {
namespace debugger {
void HeapProfilerDispatcherContract::wire(kraken::debugger::UberDispatcher *uber,
                                          kraken::debugger::HeapProfilerBackend *backend) {
  std::unique_ptr<HeapProfilerDispatcherImpl> dispatcher(new HeapProfilerDispatcherImpl(uber->channel(), backend));
  uber->setupRedirects(dispatcher->redirects());
  uber->registerBackend("HeapProfiler", std::move(dispatcher));
}
} // namespace debugger
} // namespace kraken
