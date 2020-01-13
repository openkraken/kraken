//
// Created by rowandjj on 2019/4/1.
//

#include "devtools/chrome_protocol_server.h"
#include "devtools/chrome_rpc_session.h"

namespace kraken{
    namespace Debugger {
        std::shared_ptr<jsonRpc::RPCSession> Debugger::ChromeProtocolServer::createSession(
                std::shared_ptr<kraken::foundation::WebSocketSession> handle, size_t token_num,
                jsonRpc::RPCSessionCloseObservable observable) {
            return std::make_shared<ChromeRpcSession>(handle, token_num, observable, globalObject, m_protocol_handler);
        }

        void Debugger::ChromeProtocolServer::onSessionCreated(
                int port, std::shared_ptr<jsonRpc::RPCSession> session) {
            KRAKEN_LOG(VERBOSE) << "[chrome protocol server] session created...<" << getIpAddress() << ":" << port<<">";
        }
    }
}
