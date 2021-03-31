/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "page_dispatcher_contract.h"
#include "inspector/protocol/page_dispatcher_impl.h"

namespace kraken {
namespace debugger {
void PageDispatcherContract::wire(kraken::debugger::UberDispatcher *uber, kraken::debugger::PageBackend *backend) {
  std::unique_ptr<PageDispatcherImpl> dispatcher(new PageDispatcherImpl(uber->channel(), backend));
  uber->setupRedirects(dispatcher->redirects());
  uber->registerBackend("Page", std::move(dispatcher));
}
} // namespace debugger
} // namespace kraken
