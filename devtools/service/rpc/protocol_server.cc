//
// Created by rowandjj on 2019/3/28.
//

#include "protocol_server.h"

namespace kraken{
    namespace Debugger {
        namespace jsonRpc {
            ProtocolServer::ProtocolServer(const std::string& ipAddress):_token(0),m_ip_address(ipAddress) {
                this->_m_server = kraken::foundation::WebSocketServer::buildDefault();
            }

            bool ProtocolServer::start(int port) {
                bool result = this->_m_server->listen(port,[this, port](std::shared_ptr<kraken::foundation::WebSocketSession> session){
                    auto rpcSession = this->createSession(session, _token,[this](size_t token_num){
                        this->m_session_list.erase(token_num);
                        KRAKEN_LOG(VERBOSE) << "[rpc] remove session: token " << token_num;
                    });

                    this->m_session_list[_token] = rpcSession;
                    this->onSessionCreated(port, rpcSession);
                    KRAKEN_LOG(VERBOSE) << "[rpc] create session: token " <<  _token;
                    _token++;
                });
                return result;
            }

            void ProtocolServer::stop() {
                if(this->_m_server) {
                    this->_m_server->stopListening(true/*wait for all session closed*/);
                }
            }

        }
    }
}