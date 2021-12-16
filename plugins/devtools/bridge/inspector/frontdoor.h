/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_FRONTDOOR_H
#define KRAKEN_DEBUGGER_FRONTDOOR_H

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
  FrontDoor(int32_t contextId, JSGlobalContextRef ctx, JSC::JSGlobalObject *globalObject, const std::shared_ptr<ProtocolHandler> handler) {
    m_rpc_session = std::make_shared<RPCSession>(contextId, ctx, globalObject, handler);
  }

  static void handleConsoleMessage(void* ctx, const std::string &message, int logLevel) {
    JSObjectRef globalObjectRef = JSContextGetGlobalObject(reinterpret_cast<JSGlobalContextRef>(ctx));
    auto client = JSObjectGetPrivate(globalObjectRef);
    if (client && client != ((void *)0x1)) {
      auto client_impl = reinterpret_cast<kraken::debugger::JSCConsoleClientImpl *>(client);
      client_impl->sendMessageToConsole(static_cast<JSC::MessageLevel>(logLevel), message);
    }
  }

private:
  std::shared_ptr<RPCSession> m_rpc_session;
};

} // namespace kraken

#endif // KRAKEN_DEBUGGER_FRONTDOOR_H
