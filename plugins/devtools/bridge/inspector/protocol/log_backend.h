/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_LOG_BACKEND_H
#define KRAKEN_DEBUGGER_LOG_BACKEND_H

#include "inspector/protocol/dispatch_response.h"
#include "inspector/protocol/log_entry.h"

namespace kraken {
namespace debugger {
class LogBackend {
public:
  virtual ~LogBackend() {}

  virtual DispatchResponse clear() = 0;

  virtual DispatchResponse disable() = 0;

  virtual DispatchResponse enable() = 0;

  virtual void addMessageToConsole(std::unique_ptr<LogEntry> entry) = 0;
  //                virtual DispatchResponse
  //                startViolationsReport(std::unique_ptr<protocol::Array<protocol::Log::ViolationSetting>> in_config) =
  //                0; virtual DispatchResponse stopViolationsReport() = 0;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_LOG_BACKEND_H
