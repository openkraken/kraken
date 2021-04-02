/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_UBER_DISPATCHER_H
#define KRAKEN_DEBUGGER_UBER_DISPATCHER_H

#include "inspector/protocol/dispatcher_base.h"

#include <unordered_map>

namespace kraken::debugger {
class UberDispatcher {
private:
  KRAKEN_DISALLOW_COPY(UberDispatcher);

public:
  explicit UberDispatcher(debugger::FrontendChannel *);

  void registerBackend(const std::string &name, std::unique_ptr<debugger::DispatcherBase>);

  void setupRedirects(const std::unordered_map<std::string, std::string> &);

  bool canDispatch(const std::string &method);

  void dispatch(uint64_t callId, const std::string &method,
                debugger::JSONObject message /*params. move only*/);

  FrontendChannel *channel() {
    return m_frontendChannel;
  }

  virtual ~UberDispatcher();

private:
  debugger::DispatcherBase *findDispatcher(const std::string &method);
  debugger::FrontendChannel *m_frontendChannel;
  std::unordered_map<std::string, std::string> m_redirects;
  using DispatcherPointer = std::unique_ptr<debugger::DispatcherBase>;
  std::unordered_map<std::string, DispatcherPointer> m_dispatchers;
};
} // namespace kraken

#endif // KRAKEN_DEBUGGER_UBER_DISPATCHER_H
