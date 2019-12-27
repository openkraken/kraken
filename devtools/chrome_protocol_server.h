//
// Created by rowandjj on 2019/4/1.
//

#ifndef KRAKEN_DEBUGGER_CHROME_PROTOCOL_SERVER_H
#define KRAKEN_DEBUGGER_CHROME_PROTOCOL_SERVER_H

#include "devtools/service/rpc/protocol_server.h"
#include "devtools/base/jsc/jsc_debugger_headers.h"
#include "devtools/protocol_handler.h"

namespace kraken{
    namespace Debugger {

        class ChromeProtocolServer:public jsonRpc::ProtocolServer{
        public:
            ChromeProtocolServer(JSC::JSGlobalObject* globalObject,
                                 std::shared_ptr<ProtocolHandler> handler,
                                 const std::string& ipAddress)
                    :jsonRpc::ProtocolServer(ipAddress),globalObject(globalObject),m_protocol_handler(handler) {
            }

            ~ChromeProtocolServer(){}

            std::shared_ptr<jsonRpc::RPCSession> createSession(std::shared_ptr<kraken::foundation::WebSocketSession> handle,
                                                               size_t token_num,
                                                               jsonRpc::RPCSessionCloseObservable observable) override ;

            void onSessionCreated(int port, std::shared_ptr<jsonRpc::RPCSession> session) override ;
        private:
            JSC::JSGlobalObject* globalObject;
            std::shared_ptr<ProtocolHandler> m_protocol_handler;
        };
    }
}


#endif //KRAKEN_DEBUGGER_CHROME_PROTOCOL_SERVER_H
