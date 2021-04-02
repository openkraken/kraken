/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_LOG_DISPATCHER_CONTRACT_H
#define KRAKEN_DEBUGGER_LOG_DISPATCHER_CONTRACT_H

#include "inspector/protocol/log_backend.h"
#include "inspector/protocol/uber_dispatcher.h"

namespace kraken {
namespace debugger {
class LogDispatcherContract {
public:
  static void wire(UberDispatcher *, LogBackend *);

private:
  LogDispatcherContract() {}
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_LOG_DISPATCHER_CONTRACT_H
