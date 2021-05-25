/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_RPC_SESSION_H
#define KRAKENBRIDGE_RPC_SESSION_H

#include <JavaScriptCore/JSGlobalObject.h>

#include "foundation/logging.h"
#include "inspector/service/rpc/object_serializer.h"
#include "inspector/service/rpc/protocol.h"
#include "protocol_handler.h"
#include "inspector/inspector_session.h"
#include <functional>

namespace kraken::debugger {

class InspectorSession;

using OnMessageCallback = std::function<void(const std::string &message)>;

class WebSocketServer {
public:
  void send(std::string msg) {
    KRAKEN_LOG(VERBOSE) << "recevie message " << msg;
  };

  void close(int code, const std::string &reason) {
    KRAKEN_LOG(VERBOSE) << "close " << code << " reason " << reason;
  }

  void setOnMessageCallback(OnMessageCallback callback) {}
};

class RPCSession {
public:
  explicit RPCSession(size_t token_num, JSC::JSGlobalObject *globalObject, std::shared_ptr<ProtocolHandler> handler) : _token_num(token_num) {
    m_debug_session = std::make_unique<InspectorSession>(this, globalObject, handler);

    this->m_handler->setOnMessageCallback(std::bind(&RPCSession::_on_message, this, std::placeholders::_1));
  }

  ~RPCSession() {
    KRAKEN_LOG(VERBOSE) << "--------- RPCSession Destroyed --------- ";
  }

  void handleRequest(Request req);
  void handleResponse(Response response);

  void sendRequest(Request req) {
    auto message = deserializeRequest(std::move(req));
    KRAKEN_LOG(VERBOSE) << "[rpc] session " << _token_num << " send req: " << message;
    this->_send_text(message);
  };

  void sendResponse(Response resp) {
    auto message = deserializeResponse(std::move(resp));
    KRAKEN_LOG(VERBOSE) << "[rpc] session " << _token_num << " send resp: " << message;
    this->_send_text(message);
  };

  void sendError(Error err) {
    auto message = deserializeError(std::move(err));
    KRAKEN_LOG(VERBOSE) << "[rpc] session " << _token_num << " send err: " << message;
    this->_send_text(message);
  };

  void sendEvent(Event event) {
    auto message = deserializeEvent(std::move(event));
    KRAKEN_LOG(VERBOSE) << "[rpc] session " << _token_num << " send event: " << message;
    this->_send_text(message);
  };

  void closeSession(int code, const std::string &reason) {
    if (this->m_handler) {
      this->m_handler->close(code, reason);
      KRAKEN_LOG(VERBOSE) << "[rpc] session " << _token_num << " closed";
    }
  }

  size_t sessionId() const {
    return _token_num;
  }

private:
  void _send_text(const std::string &message) {
    if (this->m_handler) {
      this->m_handler->send(message);
    }
  }

  void _on_message(const std::string &message) {
    KRAKEN_LOG(VERBOSE) << "[rpc] session " << _token_num << " received message: " << message;
    rapidjson::Document doc;
    doc.Parse(message.c_str());
    if (doc.HasParseError() || !doc.IsObject()) {
      KRAKEN_LOG(ERROR) << "[rpc] session " << _token_num << ": json parse error";
      return;
    }
    if (doc.HasMember("method")) {
      this->handleRequest(serializeRequest(std::move(doc)));
    } else if (doc.HasMember("result")) {
      this->handleResponse(serializeResponse(std::move(doc)));
    } else {
      KRAKEN_LOG(ERROR) << "[rpc] session " << _token_num << ":unknown JSON-RPC message -> " << message;
    }
  }

private:
  std::shared_ptr<WebSocketServer> m_handler;
  std::shared_ptr<InspectorSession> m_debug_session;
  size_t _token_num;
};

} // namespace kraken::debugger::jsonRpc

#endif // KRAKENBRIDGE_RPC_SESSION_H
