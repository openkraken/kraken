/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "jsc_log_agent_impl.h"
#include "inspector/inspector_session.h"

namespace kraken::debugger {

JSCLogAgentImpl::JSCLogAgentImpl(kraken::debugger::InspectorSession *session,
                                 kraken::debugger::AgentContext &context)
  : m_session(session), m_frontend(context.channel) {}

JSCLogAgentImpl::~JSCLogAgentImpl() {}

DispatchResponse JSCLogAgentImpl::enable() {
  m_enabled = true;
  return DispatchResponse::OK();
}

DispatchResponse JSCLogAgentImpl::disable() {
  m_enabled = false;
  return DispatchResponse::OK();
}

void JSCLogAgentImpl::addMessageToConsole(std::unique_ptr<kraken::debugger::LogEntry> entry) {
  m_frontend.entryAdded(std::move(entry));
}

DispatchResponse JSCLogAgentImpl::clear() {
  return DispatchResponse::OK();
}

} // namespace kraken::debugger
