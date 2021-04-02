/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_FRONTDOOR_H
#define KRAKEN_DEBUGGER_FRONTDOOR_H

#include "foundation/logging.h"
#include "inspector/inspector_session.h"
#include "inspector/protocol_handler.h"
#include "inspector/rpc_session.h"
#include <JavaScriptCore/JSGlobalObject.h>
#include <map>
#include <memory>

namespace kraken::debugger {
class FrontDoor final {
public:
  ~FrontDoor() = default;
  FrontDoor(JSC::JSGlobalObject *globalObject, const std::shared_ptr<ProtocolHandler> handler) {
    m_rpc_session = std::make_shared<RPCSession>(0, globalObject, handler);
  }

private:
  std::shared_ptr<RPCSession> m_rpc_session;
};

} // namespace kraken

#endif // KRAKEN_DEBUGGER_FRONTDOOR_H
