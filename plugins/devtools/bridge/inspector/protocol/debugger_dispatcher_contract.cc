/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/protocol/debugger_dispatcher_contract.h"
#include "inspector/protocol/debug_dispatcher_impl.h"

namespace kraken {
namespace debugger {
void DebuggerDispatcherContract::wire(debugger::UberDispatcher *uber, debugger::DebuggerBackend *backend) {
  std::unique_ptr<DebugDispatcherImpl> dispatcher(new DebugDispatcherImpl(uber->channel(), backend));
  uber->setupRedirects(dispatcher->redirects());
  uber->registerBackend("Debugger", std::move(dispatcher));
}
} // namespace debugger
} // namespace kraken
