//
// Created by rowandjj on 2019/3/28.
//

#ifndef KRAKEN_JSON_RPC_PROTOCOL_SERVER_H
#define KRAKEN_JSON_RPC_PROTOCOL_SERVER_H

#include <map>
#include "devtools/service/rpc/session.h"

namespace kraken{
    namespace Debugger {
        namespace jsonRpc {

            using SessionList = std::map<size_t /*token*/, std::shared_ptr<RPCSession>>;
            class ProtocolServer {
            public:
                ProtocolServer(const std::string& ipAddress);
                virtual ~ProtocolServer(){}
                bool start(int port);
                void stop();

                virtual std::shared_ptr<RPCSession> createSession(std::shared_ptr<kraken::foundation::WebSocketSession> handle,
                                                                  size_t token_num,
                                                                  RPCSessionCloseObservable observable) = 0;

                virtual void onSessionCreated(int port, std::shared_ptr<RPCSession> session) = 0;

                const std::string& getIpAddress() const {
                    return this->m_ip_address;
                }

                const SessionList& getSessionList() const {
                    return m_session_list;
                };

            private:
                std::unique_ptr<kraken::foundation::WebSocketServer> _m_server;
                SessionList m_session_list;
                size_t _token;
                std::string m_ip_address;
            };
        }
    }
}

#endif //KRAKEN_JSON_RPC_PROTOCOL_SERVER_H
