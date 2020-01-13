//
// Created by rowandjj on 2019/4/1.
//

#ifndef KRAKEN_DEBUGGER_CHROME_RPC_SESSION_H
#define KRAKEN_DEBUGGER_CHROME_RPC_SESSION_H

#include "devtools/service/rpc/session.h"
#include "devtools/inspector_session_impl.h"
#include "devtools/base/jsc/jsc_debugger_headers.h"
#include "devtools/protocol_handler.h"

namespace kraken{
    namespace Debugger {
        class ChromeRpcSession: public jsonRpc::RPCSession {
        public:
            ChromeRpcSession(std::shared_ptr<kraken::foundation::WebSocketSession> handle,
                             size_t token_num,
                             jsonRpc::RPCSessionCloseObservable observable,
                             JSC::JSGlobalObject *globalObject,std::shared_ptr<ProtocolHandler> handler)
                    :jsonRpc::RPCSession(handle,token_num,observable){

                // TODO 获取websocket path，判断是什么类型。debug还是访问调试列表
                m_debug_session = std::make_unique<InspectorSessionImpl>(this,globalObject, handler);
            }
            ~ChromeRpcSession(){}

            void handleRequest(jsonRpc::Request req) override ;
            void handleResponse(jsonRpc::Response response) override;
            void handleClose(int code, const std::string &reason) override;

        private:
            std::unique_ptr<InspectorSessionImpl> m_debug_session;
        };
    }
}


#endif //KRAKEN_DEBUGGER_CHROME_RPC_SESSION_H
