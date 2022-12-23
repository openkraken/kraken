/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
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
