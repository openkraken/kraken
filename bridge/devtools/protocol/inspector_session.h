/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_INSPECTOR_SESSION_H
#define KRAKEN_DEBUGGER_INSPECTOR_SESSION_H

#include <string>
#include <vector>

#include "devtools/protocol/domain.h"
#include "devtools/service/rpc/protocol.h"

namespace kraken {
namespace debugger {

class InspectorSession {
public:
  virtual ~InspectorSession() = default;

  // Dispatching protocol messages.
  //判断domain
  static bool canDispatchMethod(const std::string &method);

  virtual void dispatchProtocolMessage(jsonRpc::Request message) = 0;

  virtual std::vector<std::unique_ptr<Domain>> supportedDomains() = 0;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_INSPECTOR_SESSION_H
