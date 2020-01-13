//
// Created by rowandjj on 2019/4/1.
//
//  维护 domain <----> Dispatcher 映射
//

#ifndef KRAKEN_DEBUGGER_UBER_DISPATCHER_H
#define KRAKEN_DEBUGGER_UBER_DISPATCHER_H

#include "devtools/protocol/dispatcher_base.h"

#include <unordered_map>

namespace kraken{
    namespace Debugger {
        class  UberDispatcher {
        private:
            KRAKEN_DISALLOW_COPY(UberDispatcher);
        public:
            explicit UberDispatcher(Debugger::FrontendChannel*);

            void registerBackend(const std::string& name, std::unique_ptr<Debugger::DispatcherBase>);

            void setupRedirects(const std::unordered_map<std::string, std::string>&);

            bool canDispatch(const std::string& method);

            void dispatch(uint64_t callId,
                          const std::string& method,
                          Debugger::jsonRpc::JSONObject message/*params. move only*/);

            FrontendChannel* channel() { return m_frontendChannel; }
            virtual ~UberDispatcher();

        private:
            Debugger::DispatcherBase* findDispatcher(const std::string& method);
            Debugger::FrontendChannel* m_frontendChannel;
            std::unordered_map<std::string, std::string> m_redirects;
            using DispatcherPointer = std::unique_ptr<Debugger::DispatcherBase>;
            std::unordered_map<std::string, DispatcherPointer> m_dispatchers;
        };
    }
}

#endif //KRAKEN_DEBUGGER_UBER_DISPATCHER_H
