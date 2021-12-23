/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_RUNTIME_DISPATCHER_CONTRACT_H
#define KRAKEN_DEBUGGER_RUNTIME_DISPATCHER_CONTRACT_H

#include "inspector/protocol/runtime_backend.h"
#include "inspector/protocol/uber_dispatcher.h"

namespace kraken {
namespace debugger {
class RuntimeDispatcherContract {
public:
  static void wire(UberDispatcher *, RuntimeBackend *);

private:
  RuntimeDispatcherContract() {}
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_RUNTIME_DISPATCHER_CONTRACT_H
