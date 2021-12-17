/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_JSC_DEBUGGER_AGENT_IMPL_H
#define KRAKEN_DEBUGGER_JSC_DEBUGGER_AGENT_IMPL_H

#include <JavaScriptCore/AsyncStackTrace.h>
#include <JavaScriptCore/InjectedScript.h>
#include <JavaScriptCore/InjectedScriptManager.h>
#include <JavaScriptCore/InspectorFrontendDispatchers.h>
#include <JavaScriptCore/ScriptBreakpoint.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>
#include <JavaScriptCore/ScriptDebugListener.h>
#include <JavaScriptCore/InspectorProtocolObjects.h>
#include <JavaScriptCore/RegularExpression.h>
#include <JavaScriptCore/ScriptValue.h>
#include <JavaScriptCore/ContentSearchUtilities.h>

#include "inspector/impl/jsc_debugger_impl.h"
#include "inspector/protocol/debugger_backend.h"
#include "inspector/protocol/debugger_frontend.h"
#include "kraken_foundation.h"
#include <memory>

#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>

namespace kraken::debugger {

class InspectorSession;
class AgentContext;

class JSCDebuggerAgentImpl : public DebuggerBackend, public Inspector::ScriptDebugListener {
  WTF_MAKE_FAST_ALLOCATED;

private:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(JSCDebuggerAgentImpl);

public:
  JSCDebuggerAgentImpl(InspectorSession *session, debugger::AgentContext &context);
  ~JSCDebuggerAgentImpl() override;

  /* Inspector::ScriptDebugListener */

  void didParseSource(JSC::SourceID, const Inspector::ScriptDebugListener::Script &) override;

  void failedToParseSource(const WTF::String &url, const WTF::String &data, int firstLine, int errorLine,
                           const WTF::String &errorMessage) override;

  void didPause(JSC::ExecState &, JSC::JSValue callFrames, JSC::JSValue exception) override;

  void didContinue() override;

  void breakpointActionLog(JSC::ExecState &, const WTF::String &) override;

  void breakpointActionSound(int breakpointActionIdentifier) override;

  void breakpointActionProbe(JSC::ExecState &, const Inspector::ScriptBreakpointAction &, unsigned batchId,
                             unsigned sampleId, JSC::JSValue result) override;

  /*Backend Interface*/

  DispatchResponse continueToLocation(std::unique_ptr<Location> in_location,
                                      Maybe<std::string> in_targetCallFrames) override;
  DispatchResponse disable() override;
  DispatchResponse enable(Maybe<double> in_maxScriptsCacheSize, std::string *out_debuggerId) override;
  DispatchResponse evaluateOnCallFrame(const std::string &in_callFrameId, const std::string &in_expression,
                                       Maybe<std::string> in_objectGroup, Maybe<bool> in_includeCommandLineAPI,
                                       Maybe<bool> in_silent, Maybe<bool> in_returnByValue,
                                       Maybe<bool> in_generatePreview, Maybe<bool> in_throwOnSideEffect,
                                       Maybe<double> in_timeout, std::unique_ptr<RemoteObject> *out_result,
                                       Maybe<ExceptionDetails> *out_exceptionDetails) override;
  DispatchResponse
  getPossibleBreakpoints(std::unique_ptr<Location> in_start, Maybe<Location> in_end, Maybe<bool> in_restrictToFunction,
                         std::unique_ptr<std::vector<std::unique_ptr<BreakLocation>>> *out_locations) override;
  DispatchResponse getScriptSource(const std::string &in_scriptId, std::string *out_scriptSource) override;
  DispatchResponse getStackTrace(std::unique_ptr<StackTraceId> in_stackTraceId,
                                 std::unique_ptr<StackTrace> *out_stackTrace) override;

  DispatchResponse pause() override;
  DispatchResponse pauseOnAsyncCall(std::unique_ptr<StackTraceId> in_parentStackTraceId) override;
  DispatchResponse removeBreakpoint(const std::string &in_breakpointId) override;
  DispatchResponse restartFrame(const std::string &in_callFrameId,
                                std::unique_ptr<std::vector<CallFrame>> *out_callFrames,
                                Maybe<StackTrace> *out_asyncStackTrace,
                                Maybe<StackTraceId> *out_asyncStackTraceId) override;

  DispatchResponse resume() override;
  DispatchResponse searchInContent(const std::string &in_scriptId, const std::string &in_query,
                                   Maybe<bool> in_caseSensitive, Maybe<bool> in_isRegex,
                                   std::unique_ptr<std::vector<SearchMatch>> *out_result) override;

  DispatchResponse setAsyncCallStackDepth(int in_maxDepth) override;
  DispatchResponse setBlackboxPatterns(std::unique_ptr<std::vector<std::string>> in_patterns) override;
  DispatchResponse
  setBlackboxedRanges(const std::string &in_scriptId,
                      std::unique_ptr<std::vector<std::unique_ptr<ScriptPosition>>> in_positions) override;
  DispatchResponse setBreakpoint(std::unique_ptr<Location> in_location, Maybe<std::string> in_condition,
                                 std::string *out_breakpointId, std::unique_ptr<Location> *out_actualLocation) override;

  DispatchResponse setBreakpointByUrl(int in_lineNumber, Maybe<std::string> in_url, Maybe<std::string> in_urlRegex,
                                      Maybe<std::string> in_scriptHash, Maybe<int> in_columnNumber,
                                      Maybe<std::string> in_condition, std::string *out_breakpointId,
                                      std::unique_ptr<std::vector<std::unique_ptr<Location>>> *out_locations) override;
  DispatchResponse setBreakpointOnFunctionCall(const std::string &in_objectId, Maybe<std::string> in_condition,
                                               std::string *out_breakpointId) override;

  DispatchResponse setBreakpointsActive(bool in_active) override;
  DispatchResponse setPauseOnExceptions(const std::string &in_state) override;
  DispatchResponse setReturnValue(std::unique_ptr<CallArgument> in_newValue) override;
  DispatchResponse setScriptSource(const std::string &in_scriptId, const std::string &in_scriptSource,
                                   Maybe<bool> in_dryRun, Maybe<std::vector<CallFrame>> *out_callFrames,
                                   Maybe<bool> *out_stackChanged, Maybe<StackTrace> *out_asyncStackTrace,
                                   Maybe<StackTraceId> *out_asyncStackTraceId,
                                   Maybe<ExceptionDetails> *out_exceptionDetails) override;
  DispatchResponse setSkipAllPauses(bool in_skip) override;
  DispatchResponse setVariableValue(int in_scopeNumber, const std::string &in_variableName,
                                    std::unique_ptr<CallArgument> in_newValue,
                                    const std::string &in_callFrameId) override;
  DispatchResponse stepInto(Maybe<bool> in_breakOnAsyncCall) override;
  DispatchResponse stepOut() override;
  DispatchResponse stepOver() override;

  void willRunMicrotask() override;
  void didRunMicrotask() override;

  /*own*/

  static const char *backtraceObjectGroup;

  bool isPaused() const;

  bool breakpointsActive() const;

  void setSuppressAllPauses(bool);

  void handleConsoleAssert(const String &message);

  void didScheduleAsyncCall(JSC::ExecState *, int asyncCallType, int callbackIdentifier, bool singleShot);
  void didCancelAsyncCall(int asyncCallType, int callbackIdentifier);
  void willDispatchAsyncCall(int asyncCallType, int callbackIdentifier);
  void didDispatchAsyncCall();

  void schedulePauseOnNextStatement(Inspector::DebuggerFrontendDispatcher::Reason breakReason,
                                    RefPtr<JSON::Object>&& data);
  void cancelPauseOnNextStatement();
  bool pauseOnNextStatementEnabled() const {
    return m_javaScriptPauseScheduled;
  }

  void breakProgram(Inspector::DebuggerFrontendDispatcher::Reason breakReason,
                    RefPtr<JSON::Object> &&data);
  void scriptExecutionBlockedByCSP(const String &directiveText);

  class Listener {
  public:
    virtual ~Listener() {}
    virtual void debuggerWasEnabled() = 0;
    virtual void debuggerWasDisabled() = 0;
  };
  void setListener(Listener *listener) {
    m_listener = listener;
  }

  virtual void enable();
  virtual void disable(bool skipRecompile);

protected:
  virtual String sourceMapURLForScript(const Script &);

  void didClearGlobalObject();

private:
  bool convertCallFrames(const std::string &in_callframes_str,
                         std::unique_ptr<std::vector<std::unique_ptr<kraken::debugger::CallFrame>>> *out_callframes);

  bool convertCallFrames(rapidjson::Value::Array *in_array, rapidjson::Document::AllocatorType &in_allocator,
                         std::unique_ptr<std::vector<std::unique_ptr<kraken::debugger::CallFrame>>> *out_callframes);

  bool convertStackTrace(const std::string &in_stackTrace_str, std::unique_ptr<debugger::StackTrace> *out_trace);

  bool convertRemoteObject(const std::string &in_result, std::unique_ptr<RemoteObject> *out_result,
                           Inspector::ErrorString &error);

  Ref<JSON::ArrayOf<Inspector::Protocol::Debugger::CallFrame>> currentCallFrames(const Inspector::InjectedScript &);

  void resolveBreakpoint(const Script &, JSC::Breakpoint &);
  void setBreakpoint(JSC::Breakpoint &, bool &existing);
  void didSetBreakpoint(const JSC::Breakpoint &, const String &, const Inspector::ScriptBreakpoint &);

  bool assertPaused(Inspector::ErrorString &);
  void clearDebuggerBreakpointState();
  void clearInspectorBreakpointState();
  void clearBreakDetails();
  void clearExceptionValue();
  void clearAsyncStackTraceData();

  enum class ShouldDispatchResumed { No, WhenIdle, WhenContinued };
  void registerIdleHandler();
  void willStepAndMayBecomeIdle();
  void didBecomeIdle();

  RefPtr<JSON::Object> buildBreakpointPauseReason(JSC::BreakpointID);
  RefPtr<JSON::Object> buildExceptionPauseReason(JSC::JSValue exception,
                                                               const Inspector::InjectedScript &);

  bool breakpointActionsFromProtocol(Inspector::ErrorString &, RefPtr<JSON::Array> &actions,
                                     Inspector::BreakpointActions *result);

  typedef std::pair<int, int> AsyncCallIdentifier;

  typedef HashMap<JSC::SourceID, Script> ScriptsMap;
  typedef HashMap<String, Vector<JSC::BreakpointID>> BreakpointIdentifierToDebugServerBreakpointIDsMap;
  typedef HashMap<String, RefPtr<JSON::Object>> BreakpointIdentifierToBreakpointMap;
  typedef HashMap<JSC::BreakpointID, String> DebugServerBreakpointIDToBreakpointIdentifier;

  Inspector::InjectedScriptManager *m_injectedScriptManager;
  Listener *m_listener{nullptr};
  JSC::ExecState *m_pausedScriptState{nullptr};
  JSC::Strong<JSC::Unknown> m_currentCallStack;
  ScriptsMap m_scripts;
  BreakpointIdentifierToDebugServerBreakpointIDsMap m_breakpointIdentifierToDebugServerBreakpointIDs;
  BreakpointIdentifierToBreakpointMap m_javaScriptBreakpoints;
  DebugServerBreakpointIDToBreakpointIdentifier m_debuggerBreakpointIdentifierToInspectorBreakpointIdentifier;
  JSC::BreakpointID m_continueToLocationBreakpointID;
  Inspector::DebuggerFrontendDispatcher::Reason m_breakReason;
  RefPtr<JSON::Object> m_breakAuxData;
  ShouldDispatchResumed m_conditionToDispatchResumed{ShouldDispatchResumed::No};
  bool m_enablePauseWhenIdle{false};
  HashMap<AsyncCallIdentifier, RefPtr<Inspector::AsyncStackTrace>> m_pendingAsyncCalls;
  WTF::Optional<AsyncCallIdentifier> m_currentAsyncCallIdentifier{WTF::nullopt};
  bool m_enabled{false};
  bool m_javaScriptPauseScheduled{false};
  bool m_hasExceptionValue{false};
  bool m_didPauseStopwatch{false};
  bool m_pauseOnAssertionFailures{false};
  bool m_registeredIdleCallback{false};
  int m_asyncStackTraceDepth{0};

private:
  InspectorSession *m_session;
  DebuggerFrontend m_frontend;
  debugger::JSCDebuggerImpl *m_debugger;

  rapidjson::Document m_doc;
  int m_debugger_id = {0};
};
} // namespace kraken

#endif
