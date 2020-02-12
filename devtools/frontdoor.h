//
// Created by rowandjj on 2019/4/4.
//

#ifndef KRAKEN_DEBUGGER_FRONTDOOR_H
#define KRAKEN_DEBUGGER_FRONTDOOR_H

#include "devtools/chrome_protocol_server.h"
#include "devtools/chrome_rpc_session.h"
#include "foundation/logging.h"
#include "devtools/protocol_handler.h"
#include <memory>
#include <map>

namespace kraken{
    namespace Debugger {
        class FrontDoor final{
        public:
            static std::unique_ptr<kraken::Debugger::FrontDoor> newInstance(JSC::JSGlobalObject* globalObject,
                                                                          std::shared_ptr<ProtocolHandler> handler,
                                                                          std::string ipAddress);

            ~FrontDoor()= default;
            void setup();
            void setup(int port);
            void notifyPageDiscovered(const std::string& url, const std::string &source);
            void terminate();
            FrontDoor(JSC::JSGlobalObject* globalObject, std::shared_ptr<ProtocolHandler> handler, std::string ipAddress)
                    :m_ip_address(std::move(ipAddress)) {
                m_server = std::make_unique<Debugger::ChromeProtocolServer>(globalObject, handler, m_ip_address);
            }
        private:
            std::unique_ptr<Debugger::ChromeProtocolServer> m_server;
            std::string m_ip_address;

            int m_port{9222};

            using PageMap = std::map<std::string/*page url*/, std::string/*unique id*/>;
            PageMap m_page_map;
        };



    }
}

#endif //KRAKEN_DEBUGGER_FRONTDOOR_H
