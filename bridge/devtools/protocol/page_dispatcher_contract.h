/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_PAGE_DISPATCHER_CONTRACT_H
#define KRAKEN_DEBUGGER_PAGE_DISPATCHER_CONTRACT_H

#include "devtools/protocol/page_backend.h"
#include "devtools/protocol/uber_dispatcher.h"

namespace kraken {
namespace debugger {
class PageDispatcherContract {
public:
  static void wire(UberDispatcher *, PageBackend *);

private:
  PageDispatcherContract() {}
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_PAGE_DISPATCHER_CONTRACT_H
