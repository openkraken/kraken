#ifndef KRAKEN_DEBUGGER_INSPECTOR_SESSION_IMPL_H
#define KRAKEN_DEBUGGER_INSPECTOR_SESSION_IMPL_H

#include "inspector/impl/jsc_debugger_impl.h"
#include "inspector/protocol/frontend_channel.h"
#include "inspector/protocol/inspector_session.h"
#include "inspector/protocol/uber_dispatcher.h"
#include "inspector/protocol_handler.h"
#include "foundation/logging.h"
#include <JavaScriptCore/InjectedScriptManager.h>
#include <JavaScriptCore/InspectorEnvironment.h>

namespace kraken::debugger {
//class ChromeRpcSession;

class JSCDebuggerAgentImpl;
class JSCRuntimeAgentImpl;
class JSCPageAgentImpl;
class JSCLogAgentImpl;
class JSCConsoleClientImpl;
class JSCHeapProfilerAgentImpl;

struct AgentContext {
  debugger::JSCDebuggerImpl *debugger;
  Inspector::InspectorEnvironment *environment;
  Inspector::InjectedScriptManager *injectedScriptManager;
  FrontendChannel *channel;
};

class InspectorSessionImpl : public FrontendChannel, public InspectorSession, public Inspector::InspectorEnvironment {
public:
  InspectorSessionImpl(void *rpcSession, JSC::JSGlobalObject *globalObject,
                       std::shared_ptr<ProtocolHandler> handler);

  ~InspectorSessionImpl();

  void onSessionClosed(int, const std::string &);

  JSCDebuggerAgentImpl *debuggerAgent() {
    return m_debugger_agent.get();
  }

  ProtocolHandler *protocolHandler() {
    return m_protocol_handler.get();
  }

  JSCLogAgentImpl *logAgent() {
    return m_log_agent.get();
  }

  /*****  FrontendChannel  *******/
  void sendProtocolResponse(uint64_t callId, jsonRpc::Response message) override;

  void sendProtocolNotification(jsonRpc::Event message) override;

  void sendProtocolError(jsonRpc::Error message) override;

  void fallThrough(uint64_t callId, const std::string &method, jsonRpc::JSONObject message) override;

  /*****  InspectorSession  *******/

  void dispatchProtocolMessage(jsonRpc::Request message) override;

  std::vector<std::unique_ptr<Domain>> supportedDomains() override;

  /*****  InspectorEnvironment  *******/
  bool developerExtrasEnabled() const override;
  bool canAccessInspectedScriptState(JSC::ExecState *) const override;
  Inspector::InspectorFunctionCallHandler functionCallHandler() const override;
  Inspector::InspectorEvaluateHandler evaluateHandler() const override;
  void frontendInitialized() override;
  Ref<WTF::Stopwatch> executionStopwatch() override;
  Inspector::ScriptDebugServer &scriptDebugServer() override;
  JSC::VM &vm() override;

private:
  void *m_rpcSession;
  UberDispatcher m_dispatcher;
  std::unique_ptr<debugger::JSCDebuggerImpl> m_debugger;
  std::unique_ptr<JSCDebuggerAgentImpl> m_debugger_agent;
  std::unique_ptr<JSCRuntimeAgentImpl> m_runtime_agent;
  std::unique_ptr<JSCPageAgentImpl> m_page_agent;
  std::unique_ptr<JSCLogAgentImpl> m_log_agent;
  std::unique_ptr<JSCConsoleClientImpl> m_console_client;
  std::unique_ptr<JSCHeapProfilerAgentImpl> m_heap_profiler_agent;

  std::shared_ptr<ProtocolHandler> m_protocol_handler;
  std::unique_ptr<Inspector::InjectedScriptManager> m_injectedScriptManager;

  Ref<WTF::Stopwatch> m_executionStopwatch;
};
} // namespace kraken::debugger

#endif // KRAKEN_DEBUGGER_INSPECTOR_SESSION_IMPL_H
