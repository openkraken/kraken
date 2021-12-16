/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/inspector_session.h"
#include "inspector/impl/jsc_console_client_impl.h"
#include "inspector/impl/jsc_debugger_agent_impl.h"
#include "inspector/impl/jsc_heap_profiler_agent_impl.h"
#include "inspector/impl/jsc_log_agent_impl.h"
#include "inspector/impl/jsc_page_agent_impl.h"
#include "inspector/impl/jsc_runtime_agent_impl.h"
#include "inspector/protocol/debugger_dispatcher_contract.h"
#include "inspector/protocol/heap_profiler_dispatcher_contract.h"
#include "inspector/protocol/log_dispatcher_contract.h"
#include "inspector/protocol/page_dispatcher_contract.h"
#include "inspector/protocol/runtime_dispatcher_contract.h"

#include <kraken/include/kraken_foundation.h>

#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/InjectedScriptHost.h>

namespace kraken::debugger {

InspectorSession::InspectorSession(RPCSession *rpcSession, JSGlobalContextRef ctx, JSC::JSGlobalObject *globalObject,
                                           std::shared_ptr<ProtocolHandler> handler)
  : m_rpcSession(rpcSession), m_dispatcher(this), m_protocol_handler(handler),
    m_executionStopwatch(Stopwatch::create()) {
  m_executionStopwatch->start();
  m_debugger = std::make_unique<debugger::JSCDebuggerImpl>(rpcSession->sessionId(), globalObject);
  m_injectedScriptManager =
    std::make_unique<Inspector::InjectedScriptManager>(*this, Inspector::InjectedScriptHost::create());
  AgentContext context = {this->m_debugger.get(), this, this->m_injectedScriptManager.get(), this};

  m_debugger_agent.reset(new JSCDebuggerAgentImpl(this, context));
  DebuggerDispatcherContract::wire(&m_dispatcher, m_debugger_agent.get());

  m_runtime_agent.reset(new JSCRuntimeAgentImpl(this, context));
  RuntimeDispatcherContract::wire(&m_dispatcher, m_runtime_agent.get());

  m_page_agent.reset(new JSCPageAgentImpl(this, context));
  PageDispatcherContract::wire(&m_dispatcher, m_page_agent.get());

  m_log_agent.reset(new JSCLogAgentImpl(this, context));
  LogDispatcherContract::wire(&m_dispatcher, m_log_agent.get());

  m_console_client = new JSCConsoleClientImpl(m_log_agent.get());
  globalObject->setConsoleClient(m_console_client); // bind console client

  JSObjectRef globalObjectRef = JSContextGetGlobalObject(ctx);
  JSObjectSetPrivate(globalObjectRef, m_console_client);

  m_heap_profiler_agent.reset(new JSCHeapProfilerAgentImpl(this, context));
  HeapProfilerDispatcherContract::wire(&m_dispatcher, m_heap_profiler_agent.get());
}

InspectorSession::~InspectorSession() {
}

void InspectorSession::onSessionClosed(int, const std::string &) {
  if (m_debugger->globalObject()) {
    m_debugger->globalObject()->setConsoleClient(nullptr);
  }

  m_debugger_agent->disable(true);
  m_runtime_agent->disable();

  m_injectedScriptManager->disconnect();
}

void InspectorSession::sendProtocolResponse(uint64_t callId, debugger::Response message) {
  if (m_rpcSession && callId == message.id) {
    m_rpcSession->sendResponse(std::move(message));
  }
}

void InspectorSession::sendProtocolNotification(debugger::Event message) {
  if (m_rpcSession) {
    m_rpcSession->sendEvent(std::move(message));
  }
}

void InspectorSession::sendProtocolError(debugger::Error message) {
  if (m_rpcSession) {
    m_rpcSession->sendError(std::move(message));
  }
}

void InspectorSession::fallThrough(uint64_t callId, const std::string &method, JSONObject message) {
  KRAKEN_LOG(ERROR) << "[fallThrough] can not handle request: " << callId << "," << method;
}

void InspectorSession::dispatchProtocolMessage(Request message) {
  JSC::JSGlobalObject *globalObject = m_debugger->globalObject();
  JSC::VM &vm = globalObject->globalExec()->vm();
  JSC::JSLockHolder locker(vm);
  m_dispatcher.dispatch(message.id, message.method, std::move(message.params));
}

//////////////////////Inspector::InspectorEnvironment///////////////////////////////

bool InspectorSession::developerExtrasEnabled() const {
  return true;
}

bool InspectorSession::canAccessInspectedScriptState(JSC::ExecState *) const {
  return true;
}

Inspector::InspectorFunctionCallHandler InspectorSession::functionCallHandler() const {
  return JSC::call;
}

Inspector::InspectorEvaluateHandler InspectorSession::evaluateHandler() const {
  return JSC::evaluate;
}

void InspectorSession::frontendInitialized() {}

Ref<WTF::Stopwatch> InspectorSession::executionStopwatch() {
  return m_executionStopwatch.copyRef();
}

Inspector::ScriptDebugServer &InspectorSession::scriptDebugServer() {
  return *this->m_debugger;
}

JSC::VM &InspectorSession::vm() {
  return this->m_debugger->vm();
}

} // namespace kraken
