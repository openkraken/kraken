//
// Created by rowandjj on 2019/4/24.
//

#ifndef KRAKEN_DEBUGGER_JSC_LOG_AGENT_IMPL_H
#define KRAKEN_DEBUGGER_JSC_LOG_AGENT_IMPL_H

#include "devtools/protocol/log_backend.h"
#include "devtools/protocol/log_frontend.h"
#include "foundation/macros.h"

namespace kraken{
    namespace Debugger {
        class InspectorSessionImpl;
        class AgentContext;

        class JSCLogAgentImpl: public LogBackend {
        private:
            KRAKEN_DISALLOW_COPY_AND_ASSIGN(JSCLogAgentImpl);
        public:
            JSCLogAgentImpl(InspectorSessionImpl* session,
                             Debugger::AgentContext& context);
            ~JSCLogAgentImpl() override ;


            /***************** LogBackend *********************/
            DispatchResponse disable() override;
            DispatchResponse enable() override;
            DispatchResponse clear() override;
            void addMessageToConsole(std::unique_ptr<LogEntry> entry) override;

        private:

            bool m_enabled {false};

        private:
            InspectorSessionImpl* m_session;
            LogFrontend m_frontend;
        };
    }
}


#endif //KRAKEN_DEBUGGER_JSC_LOG_AGENT_IMPL_H
