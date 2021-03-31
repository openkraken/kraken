/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JSON_RPC_SESSION_H
#define KRAKEN_JSON_RPC_SESSION_H

#include "inspector/service/rpc/object_serializer.h"
#include "inspector/service/rpc/protocol.h"
#include "foundation/logging.h"

#include <functional>
#include <memory>

namespace kraken::debugger::jsonRpc {
using RPCSessionCloseObservable = std::function<void(size_t)>;

class RPCSession {
public:
  RPCSession(size_t token_num,
             RPCSessionCloseObservable observable)
    : _token_num(token_num), _observable(observable) {
//    this->_m_handle->setOnMessageCallback(std::bind(&RPCSession::_on_message, this, std::placeholders::_1));
//    this->_m_handle->setOnCloseCallback(
//      std::bind(&RPCSession::_on_close, this, std::placeholders::_1, std::placeholders::_2));
  }

  virtual ~RPCSession() {
    KRAKEN_LOG(VERBOSE) << "--------- RPCSession Destroyed --------- ";
  }

  virtual void handleRequest(Request req) = 0;
  virtual void handleResponse(Response response) = 0;
  virtual void handleClose(int code, const std::string &reason) = 0;

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
//    if (this->_m_handle) {
//      this->_m_handle->close(code, reason);
//      KRAKEN_LOG(VERBOSE) << "[rpc] session " << _token_num << " closed";
//    }
  }

  size_t sessionId() const {
    return _token_num;
  }

private:
  void _send_text(const std::string &message) {
    //                    KRAKEN_LOG(VERBOSE) << "[rpc] session " << _token_num << " send message: " << message;
//    if (this->_m_handle) {
//      this->_m_handle->send(message);
//    }
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

  void _on_close(int code, const std::string &reason) {
    KRAKEN_LOG(VERBOSE) << "[rpc] session " << _token_num << " closed: " << code << " " << reason;
    handleClose(code, reason);
    if (_observable) {
      _observable(_token_num);
    }
  }

private:
  RPCSessionCloseObservable _observable;
  size_t _token_num;
};

} // namespace kraken

#endif // KRAKEN_JSON_RPC_SESSION_H
