/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "rpc_session.h"
#include "kraken_bridge.h"

namespace kraken::debugger {

void RPCSession::handleRequest(Request req) {
  if (m_debug_session != nullptr) {
    m_debug_session->dispatchProtocolMessage(std::move(req));
  }
}

void RPCSession::_on_message(const std::string &message) {
  rapidjson::Document doc;
  doc.Parse(message.c_str());
  if (doc.HasParseError() || !doc.IsObject()) {
    return;
  }
  if (doc.HasMember("method")) {
    std::string method = doc["method"].GetString();
    auto dotIndex = method.find('.');
    if (dotIndex == std::string::npos) {
      return;
    }
    std::string domain = method.substr(0, dotIndex);
    std::string subMethod = method.substr(dotIndex + 1);

    if (m_debug_session->isDebuggerPaused()) {
      if (domain == "Runtime" || (domain == "Debugger" && subMethod == "evaluateOnCallFrame")) {
        auto *ctx = new SessionContext{this, message};
        registerUITask(_contextId, [](void *ptr) {
          auto *ctx = reinterpret_cast<SessionContext *>(ptr);
          rapidjson::Document doc;
          doc.Parse(ctx->message.c_str());
          if (ctx->session->dispose()) return;
          ctx->session->handleRequest(serializeRequest(std::move(doc)));
        }, ctx);
      } else {
        this->handleRequest(serializeRequest(std::move(doc)));
      }
    } else {
      if ((domain == "Runtime")) {
        auto *ctx = new SessionContext{this, message};
        kraken::getInspectorDartMethod()->postTaskToUiThread(_contextId, reinterpret_cast<void *>(ctx), [](void *ptr) {
          auto *ctx = reinterpret_cast<SessionContext *>(ptr);
          rapidjson::Document doc;
          doc.Parse(ctx->message.c_str());
          if (ctx->session->dispose()) return;
          ctx->session->handleRequest(serializeRequest(std::move(doc)));
        });
      } else {
        this->handleRequest(serializeRequest(std::move(doc)));
      }
    }
  } else {
    KRAKEN_LOG(ERROR) << "[rpc] session " << _contextId << ":unknown JSON-RPC message -> " << message;
  }
}

void DartRPC::send(int32_t contextId, const std::string &msg) {
  if (std::this_thread::get_id() == getUIThreadId()) {
    auto ctx = new RPCContext{contextId, msg};
    kraken::getUIDartMethod()->postTaskToInspectorThread(contextId, reinterpret_cast<void*>(ctx), [](void *ptr) {
      auto ctx = reinterpret_cast<RPCContext *>(ptr);
      getInspectorDartMethod()->inspectorMessage(ctx->contextId, ctx->message.c_str());
      delete ctx;
    });
  } else {
    getInspectorDartMethod()->inspectorMessage(contextId, msg.c_str());
  }
}

void DartRPC::setOnMessageCallback(int32_t contextId, void *rpcSession, InspectorMessageCallback callback) {
  getInspectorDartMethod()->registerInspectorMessageCallback(contextId, rpcSession, callback);
}

}
