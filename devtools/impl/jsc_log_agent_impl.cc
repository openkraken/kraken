//
// Created by rowandjj on 2019/4/24.
//

#include "devtools/inspector_session_impl.h"
#include "jsc_log_agent_impl.h"

namespace kraken{
    namespace Debugger {

        JSCLogAgentImpl::JSCLogAgentImpl(kraken::Debugger::InspectorSessionImpl *session,
                                           kraken::Debugger::AgentContext &context)
                :m_session(session),
                 m_frontend(context.channel) {}

        JSCLogAgentImpl::~JSCLogAgentImpl() {}

        DispatchResponse JSCLogAgentImpl::enable() {
            m_enabled = true;
            return DispatchResponse::OK();
        }

        DispatchResponse JSCLogAgentImpl::disable() {
            m_enabled = false;
            return DispatchResponse::OK();
        }

        void JSCLogAgentImpl::addMessageToConsole(
                std::unique_ptr<kraken::Debugger::LogEntry> entry) {
            m_frontend.entryAdded(std::move(entry));
        }

        DispatchResponse JSCLogAgentImpl::clear() {
            return DispatchResponse::OK();
        }

    }
}