//
// Created by rowandjj on 2019/4/1.
//

#include "chrome_rpc_session.h"

namespace kraken{
    namespace Debugger {
        void Debugger::ChromeRpcSession::handleRequest(jsonRpc::Request req) {
            if(m_debug_session != nullptr) {
                m_debug_session->dispatchProtocolMessage(std::move(req));
            }
            // TODO 设备发现
        }


        void Debugger::ChromeRpcSession::handleResponse(jsonRpc::Response response) {
            // TODO
        }

        void Debugger::ChromeRpcSession::handleClose(int code, const std::string &reason) {
            KRAKEN_LOG(VERBOSE) << "handle websocket close...";
            if(m_debug_session != nullptr) {
                m_debug_session->onSessionClosed(code, reason);
            }
        }
    }
}