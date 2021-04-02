/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_FRONTEND_CHANNEL_H
#define KRAKEN_DEBUGGER_FRONTEND_CHANNEL_H

#include "inspector/service/rpc/protocol.h"

namespace kraken::debugger {
class FrontendChannel {
public:
  virtual ~FrontendChannel() {}

  // response
  virtual void sendProtocolResponse(uint64_t callId, Response message) = 0;

  // event
  virtual void sendProtocolNotification(Event message) = 0;

  // error
  virtual void sendProtocolError(Error message) = 0;

  // There's no other layer to handle the command.
  virtual void fallThrough(uint64_t callId, const std::string &method, JSONObject message) = 0;

  //        virtual void flushProtocolNotifications() = 0;
};
} // namespace kraken

#endif // KRAKEN_DEBUGGER_FRONTEND_CHANNEL_H
