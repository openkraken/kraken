/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_RPC_SESSION_H
#define KRAKENBRIDGE_RPC_SESSION_H

#include <JavaScriptCore/JSGlobalObject.h>

#include "inspector/service/rpc/object_serializer.h"
#include "inspector/service/rpc/protocol.h"
#include "protocol_handler.h"
#include "dart_methods.h"
#include "inspector/inspector_session.h"
#include <functional>

namespace kraken::debugger {

class InspectorSession;

class DartRPC {
public:
  void send(int32_t contextId, const std::string &msg);
  void setOnMessageCallback(int32_t contextId, void* rpcSession, InspectorMessageCallback callback);
private:
  struct RPCContext {
    int32_t contextId;
    std::string message;
  };
};

class RPCSession {
public:
  explicit RPCSession(size_t contextId, JSGlobalContextRef ctx, JSC::JSGlobalObject *globalObject, std::shared_ptr<ProtocolHandler> handler) : _contextId(contextId) {
    m_debug_session = std::make_shared<InspectorSession>(this, ctx, globalObject, handler);
    m_handler = std::make_shared<DartRPC>();
    InspectorMessageCallback callback = [](void *rpcSession, const char *message) -> void {
      auto session = reinterpret_cast_ptr<RPCSession *>(rpcSession);
      if (session->dispose()) {
        return;
      }
      session->_on_message(message);
    };
    this->m_handler->setOnMessageCallback(contextId, this, callback);
  }

  ~RPCSession() {
    m_disposed = true;
  }

  bool dispose() {
    return m_disposed;
  }

  void handleRequest(Request req);

  void sendRequest(Request req) {
    auto message = deserializeRequest(std::move(req));
    this->_send_text(message);
  };

  void sendResponse(Response resp) {
    auto message = deserializeResponse(std::move(resp));
    this->_send_text(message);
  };

  void sendError(Error err) {
    auto message = deserializeError(std::move(err));
    this->_send_text(message);
  };

  void sendEvent(Event event) {
    auto message = deserializeEvent(std::move(event));
    this->_send_text(message);
  };

  size_t sessionId() const {
    return _contextId;
  }

private:
  void _send_text(const std::string &message) {
    if (this->m_handler) {
      this->m_handler->send(_contextId, message);
    }
  }

  struct SessionContext {
    RPCSession *session;
    const std::string message;
  };

  void _on_message(const std::string &message);

private:
  std::shared_ptr<DartRPC> m_handler;
  std::shared_ptr<InspectorSession> m_debug_session;
  size_t _contextId;
  std::atomic<bool> m_disposed{false};
};

} // namespace kraken::debugger::jsonRpc

#endif // KRAKENBRIDGE_RPC_SESSION_H
