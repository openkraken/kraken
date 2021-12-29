/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "log_dispatcher_contract.h"
#include "inspector/protocol/log_dispatcher_impl.h"
namespace kraken {
namespace debugger {
void LogDispatcherContract::wire(kraken::debugger::UberDispatcher *uber, kraken::debugger::LogBackend *backend) {
  std::unique_ptr<LogDispatcherImpl> dispatcher(new LogDispatcherImpl(uber->channel(), backend));
  uber->setupRedirects(dispatcher->redirects());
  uber->registerBackend("Log", std::move(dispatcher));
}
} // namespace debugger
} // namespace kraken
