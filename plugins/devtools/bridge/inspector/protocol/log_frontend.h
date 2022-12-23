/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKEN_DEBUGGER_LOG_FRONTEND_H
#define KRAKEN_DEBUGGER_LOG_FRONTEND_H

#include "inspector/protocol/frontend_channel.h"
#include "inspector/protocol/log_entry.h"
#include <memory>

namespace kraken {
namespace debugger {
class LogFrontend {
public:
  explicit LogFrontend(FrontendChannel *frontendChannel) : m_frontendChannel(frontendChannel) {}

  void entryAdded(std::unique_ptr<LogEntry> entry);

private:
  FrontendChannel *m_frontendChannel;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_LOG_FRONTEND_H
