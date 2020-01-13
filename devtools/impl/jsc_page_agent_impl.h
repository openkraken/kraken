//
// Created by rowandjj on 2019/4/23.
//

#ifndef KRAKEN_DEBUGGER_JSC_PAGE_AGENT_IMPL_H
#define KRAKEN_DEBUGGER_JSC_PAGE_AGENT_IMPL_H

#include "devtools/protocol/page_backend.h"
#include "foundation/macros.h"

namespace kraken{
    namespace Debugger {

        class InspectorSessionImpl;
        class AgentContext;


        class JSCPageAgentImpl: public PageBackend {
        private:
            KRAKEN_DISALLOW_COPY_AND_ASSIGN(JSCPageAgentImpl);
        public:
            JSCPageAgentImpl(InspectorSessionImpl* session,
                                Debugger::AgentContext& context);
            ~JSCPageAgentImpl() override ;


            /***************** PageBackend *********************/
            DispatchResponse disable() override ;
            DispatchResponse enable() override;

            DispatchResponse reload(Maybe<bool> in_ignoreCache,
                                            Maybe<std::string> in_scriptToEvaluateOnLoad) override;
        private:

            bool m_enabled {false};

        private:
            InspectorSessionImpl* m_session;
        };
    }
}


#endif //KRAKEN_DEBUGGER_JSC_PAGE_AGENT_IMPL_H
