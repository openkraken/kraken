/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/inspector_session_impl.h"
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

#include <JavaScriptCore/Completion.h>

namespace kraken::debugger {

InspectorSessionImpl::InspectorSessionImpl(void *rpcSession, JSC::JSGlobalObject *globalObject,
                                           std::shared_ptr<ProtocolHandler> handler)
  : m_rpcSession(rpcSession), m_dispatcher(this), m_protocol_handler(handler),
    m_executionStopwatch(Stopwatch::create()) {
  m_executionStopwatch->start();
  m_debugger = std::make_unique<debugger::JSCDebuggerImpl>(globalObject);
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

  m_console_client = std::make_unique<JSCConsoleClientImpl>(m_log_agent.get());
  globalObject->setConsoleClient(m_console_client.get()); // bind console client

  m_heap_profiler_agent.reset(new JSCHeapProfilerAgentImpl(this, context));
  HeapProfilerDispatcherContract::wire(&m_dispatcher, m_heap_profiler_agent.get());
}

InspectorSessionImpl::~InspectorSessionImpl() {
//  m_rpcSession = nullptr;
  KRAKEN_LOG(VERBOSE) << "InspectorSession Will Destroyed";
}

void InspectorSessionImpl::onSessionClosed(int, const std::string &) {
  //            JSC::JSLockHolder holder(vm());
  if (m_debugger->globalObject()) {
    m_debugger->globalObject()->setConsoleClient(nullptr);
  }

  m_debugger_agent->disable(true);
  m_runtime_agent->disable();

  m_injectedScriptManager->disconnect();
}

void InspectorSessionImpl::sendProtocolResponse(uint64_t callId, debugger::jsonRpc::Response message) {
//  if (m_rpcSession && callId == message.id) {
//    m_rpcSession->sendResponse(std::move(message));
//  }
}

void InspectorSessionImpl::sendProtocolNotification(debugger::jsonRpc::Event message) {
//  if (m_rpcSession) {
//    m_rpcSession->sendEvent(std::move(message));
//  }
}

void InspectorSessionImpl::sendProtocolError(debugger::jsonRpc::Error message) {
//  if (m_rpcSession) {
//    m_rpcSession->sendError(std::move(message));
//  }
}

void InspectorSessionImpl::fallThrough(uint64_t callId, const std::string &method, jsonRpc::JSONObject message) {
  KRAKEN_LOG(ERROR) << "[fallThrough] can not handle request: " << callId << "," << method;
}

//////////

bool InspectorSession::canDispatchMethod(const std::string &method) {
  // 可以处理domain为Debugger或者Runtime的指令
  return method.find("Debugger") != std::string::npos || method.find("Runtime") != std::string::npos ||
         method.find("Page") != std::string::npos || method.find("Log") != std::string::npos;
}

void InspectorSessionImpl::dispatchProtocolMessage(jsonRpc::Request message) {
  JSC::JSLockHolder holder(vm());
  m_dispatcher.dispatch(message.id, message.method, std::move(message.params));
}

std::vector<std::unique_ptr<Domain>> InspectorSessionImpl::supportedDomains() {
  std::vector<std::unique_ptr<Domain>> _result;
  _result.push_back(Domain::create().setVersion("1.0.0").setName("Debugger").build());
  _result.push_back(Domain::create().setVersion("1.0.0").setName("Runtime").build());
  _result.push_back(Domain::create().setVersion("1.0.0").setName("Page").build());
  _result.push_back(Domain::create().setVersion("1.0.0").setName("Log").build());
  return _result;
}

//////////////////////Inspector::InspectorEnvironment///////////////////////////////

bool InspectorSessionImpl::developerExtrasEnabled() const {
  return true;
}

bool InspectorSessionImpl::canAccessInspectedScriptState(JSC::ExecState *) const {
  return true;
}

Inspector::InspectorFunctionCallHandler InspectorSessionImpl::functionCallHandler() const {
  return JSC::call;
}

Inspector::InspectorEvaluateHandler InspectorSessionImpl::evaluateHandler() const {
  return JSC::evaluate;
}

void InspectorSessionImpl::frontendInitialized() {}

Ref<WTF::Stopwatch> InspectorSessionImpl::executionStopwatch() {
  return m_executionStopwatch.copyRef();
}

Inspector::ScriptDebugServer &InspectorSessionImpl::scriptDebugServer() {
  return *this->m_debugger;
}

JSC::VM &InspectorSessionImpl::vm() {
  return this->m_debugger->vm();
}

} // namespace kraken
