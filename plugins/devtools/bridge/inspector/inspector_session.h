/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_INSPECTOR_SESSION_IMPL_H
#define KRAKEN_DEBUGGER_INSPECTOR_SESSION_IMPL_H

#include "inspector/rpc_session.h"
#include "inspector/impl/jsc_console_client_impl.h"
#include "inspector/impl/jsc_debugger_impl.h"
#include "inspector/impl/jsc_debugger_agent_impl.h"
#include "inspector/impl/jsc_heap_profiler_agent_impl.h"
#include "inspector/impl/jsc_runtime_agent_impl.h"
#include "inspector/impl/jsc_log_agent_impl.h"
#include "inspector/impl/jsc_page_agent_impl.h"
#include "inspector/impl/jsc_runtime_agent_impl.h"
#include "inspector/protocol/frontend_channel.h"
#include "inspector/protocol/uber_dispatcher.h"
#include "inspector/protocol_handler.h"

#include <JavaScriptCore/InjectedScriptManager.h>
#include <JavaScriptCore/InspectorEnvironment.h>
#include <JavaScriptCore/Debugger.h>
#include <JavaScriptCore/Breakpoint.h>
#include <JavaScriptCore/DebuggerCallFrame.h>
#include <JavaScriptCore/DebuggerEvalEnabler.h>
#include <JavaScriptCore/DebuggerParseData.h>
#include <JavaScriptCore/DebuggerPrimitives.h>
#include <JavaScriptCore/DebuggerScope.h>
#include <JavaScriptCore/ScriptObject.h>
#include <JavaScriptCore/ErrorHandlingScope.h>
#include <JavaScriptCore/ScriptDebugServer.h>
#include <JavaScriptCore/ScriptDebugListener.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>
#include <JavaScriptCore/ContentSearchUtilities.h>
#include <JavaScriptCore/SourceProvider.h>
#include <JavaScriptCore/RegularExpression.h>
#include <JavaScriptCore/ArrayBuffer.h>
#include <JavaScriptCore/ArrayPrototype.h>
#include <JavaScriptCore/BuiltinNames.h>
#include <JavaScriptCore/ButterflyInlines.h>
#include <JavaScriptCore/CatchScope.h>
#include <JavaScriptCore/CodeBlock.h>
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/ConfigFile.h>
#include <JavaScriptCore/Disassembler.h>
#include <JavaScriptCore/Exception.h>
#include <JavaScriptCore/ExceptionHelpers.h>
#include <JavaScriptCore/InitializeThreading.h>
#include <JavaScriptCore/JSArray.h>
#include <JavaScriptCore/JSArrayBuffer.h>
#include <JavaScriptCore/JSCInlines.h>
#include <JavaScriptCore/JSFunction.h>
#include <JavaScriptCore/JSInternalPromise.h>
#include <JavaScriptCore/JSInternalPromiseDeferred.h>
#include <JavaScriptCore/JSLock.h>
#include <JavaScriptCore/JSNativeStdFunction.h>
#include <JavaScriptCore/JSONObject.h>
#include <JavaScriptCore/JSSourceCode.h>
#include <JavaScriptCore/JSString.h>
#include <JavaScriptCore/JSTypedArrays.h>
#include <JavaScriptCore/ObjectConstructor.h>
#include <JavaScriptCore/ParserError.h>
#include <JavaScriptCore/SamplingProfiler.h>
#include <JavaScriptCore/ProfilerDatabase.h>
#include <JavaScriptCore/StackVisitor.h>
#include <JavaScriptCore/StructureInlines.h>
#include <JavaScriptCore/StructureRareDataInlines.h>
#include <JavaScriptCore/SuperSampler.h>
#include <JavaScriptCore/TestRunnerUtils.h>
#include <JavaScriptCore/TypedArrayInlines.h>
#include <JavaScriptCore/WasmFaultSignalHandler.h>
#include <JavaScriptCore/WasmMemory.h>
#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/JSFloat64Array.h>
#include <JavaScriptCore/JSFloat32Array.h>
#include <wtf/CommaPrinter.h>
#include <wtf/MainThread.h>
#include <wtf/NeverDestroyed.h>
#include <wtf/StringPrintStream.h>
#include <wtf/WallTime.h>
#include <wtf/text/StringBuilder.h>
#include <wtf/text/WTFString.h>
#include <wtf/Vector.h>
#include <wtf/Forward.h>
#include <wtf/Noncopyable.h>
#include <wtf/HashMap.h>
#include <wtf/HashSet.h>
#include <wtf/Assertions.h>

namespace kraken::debugger {
//class JSCPageAgentImpl;
//class JSCLogAgentImpl;
//class JSCConsoleClientImpl;
class JSCHeapProfilerAgentImpl;
class RPCSession;

struct AgentContext {
  debugger::JSCDebuggerImpl *debugger;
  Inspector::InspectorEnvironment *environment;
  Inspector::InjectedScriptManager *injectedScriptManager;
  FrontendChannel *channel;
};

class InspectorSession : public FrontendChannel, public Inspector::InspectorEnvironment {
public:
  InspectorSession() = delete;
  explicit InspectorSession(RPCSession *rpcSession, JSGlobalContextRef ctx, JSC::JSGlobalObject *globalObject,
                       std::shared_ptr<ProtocolHandler> handler);

  ~InspectorSession();

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

  bool isDebuggerPaused() {
    return m_debugger->isPaused();
  }

  RPCSession *rpcSession() { return m_rpcSession; }

  /*****  FrontendChannel  *******/
  void sendProtocolResponse(uint64_t callId, Response message) override;

  void sendProtocolNotification(Event message) override;

  void sendProtocolError(Error message) override;

  void fallThrough(uint64_t callId, const std::string &method, JSONObject message) override;

  void dispatchProtocolMessage(Request message);

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
  RPCSession *m_rpcSession;
  UberDispatcher m_dispatcher;
  std::unique_ptr<debugger::JSCDebuggerImpl> m_debugger;
  std::unique_ptr<JSCDebuggerAgentImpl> m_debugger_agent;
  std::unique_ptr<JSCRuntimeAgentImpl> m_runtime_agent;
  std::unique_ptr<JSCPageAgentImpl> m_page_agent;
  std::unique_ptr<JSCLogAgentImpl> m_log_agent;
  JSCConsoleClientImpl *m_console_client{nullptr};
  std::unique_ptr<JSCHeapProfilerAgentImpl> m_heap_profiler_agent;

  std::shared_ptr<ProtocolHandler> m_protocol_handler;
  std::unique_ptr<Inspector::InjectedScriptManager> m_injectedScriptManager;

  Ref<WTF::Stopwatch> m_executionStopwatch;
};
} // namespace kraken::debugger

#endif // KRAKEN_DEBUGGER_INSPECTOR_SESSION_IMPL_H
