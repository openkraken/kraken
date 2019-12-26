//
// Created by rowandjj on 2019/4/23.
//

#include "jsc_page_agent_impl.h"
#include "devtools/inspector_session_impl.h"

namespace kraken{
    namespace Debugger {

        JSCPageAgentImpl::JSCPageAgentImpl(kraken::Debugger::InspectorSessionImpl *session,
                                           kraken::Debugger::AgentContext &context)
                :m_session(session) {}

        JSCPageAgentImpl::~JSCPageAgentImpl() {}

        DispatchResponse JSCPageAgentImpl::enable() {
            m_enabled = true;
            return DispatchResponse::OK();
        }

        DispatchResponse JSCPageAgentImpl::disable() {
            m_enabled = false;
            return DispatchResponse::OK();
        }

        DispatchResponse JSCPageAgentImpl::reload(kraken::Debugger::Maybe<bool> in_ignoreCache,
                                                  kraken::Debugger::Maybe<std::string> in_scriptToEvaluateOnLoad) {
            KRAKEN_LOG(VERBOSE) << "handle reload...";
            if(m_session && m_session->protocolHandler()) {
                m_session->protocolHandler()->handlePageReload();
                return DispatchResponse::OK();
            } else {
                return DispatchResponse::Error("session destroyed or protocol handler destroyed");
            }
        }
    }
}