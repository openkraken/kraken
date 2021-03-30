/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_FRONTEND_CHANNEL_H
#define KRAKEN_DEBUGGER_FRONTEND_CHANNEL_H

#include "devtools/service/rpc/protocol.h"

namespace kraken {
namespace debugger {
/*websocket通道*/
class FrontendChannel {
public:
  virtual ~FrontendChannel() {}

  // response
  virtual void sendProtocolResponse(uint64_t callId, jsonRpc::Response message) = 0;

  // event
  virtual void sendProtocolNotification(jsonRpc::Event message) = 0;

  // error
  virtual void sendProtocolError(jsonRpc::Error message) = 0;

  // There's no other layer to handle the command.
  virtual void fallThrough(uint64_t callId, const std::string &method, jsonRpc::JSONObject message) = 0;

  //        virtual void flushProtocolNotifications() = 0;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_FRONTEND_CHANNEL_H
