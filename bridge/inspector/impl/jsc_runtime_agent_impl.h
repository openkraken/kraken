/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_JSC_RUNTIME_AGENT_IMPL_H
#define KRAKEN_DEBUGGER_JSC_RUNTIME_AGENT_IMPL_H

#include "inspector/impl/jsc_debugger_impl.h"
#include "inspector/protocol/runtime_backend.h"
#include "inspector/protocol/runtime_frontend.h"
#include "kraken_foundation.h"
#include <JavaScriptCore/InjectedScriptManager.h>
#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

namespace kraken::debugger {
class InspectorSession;
class AgentContext;

class JSCRuntimeAgentImpl : public RuntimeBackend {
private:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(JSCRuntimeAgentImpl);

public:
  JSCRuntimeAgentImpl(InspectorSession *session, debugger::AgentContext &context);
  ~JSCRuntimeAgentImpl() override;

  /***************** RuntimeBackend *********************/
  void awaitPromise(const std::string &in_promiseObjectId, Maybe<bool> in_returnByValue, Maybe<bool> in_generatePreview,
                    std::unique_ptr<AwaitPromiseCallback> callback) override;

  void callFunctionOn(const std::string &in_functionDeclaration, Maybe<std::string> in_objectId,
                      Maybe<std::vector<std::unique_ptr<CallArgument>>> in_arguments, Maybe<bool> in_silent,
                      Maybe<bool> in_returnByValue, Maybe<bool> in_generatePreview, Maybe<bool> in_userGesture,
                      Maybe<bool> in_awaitPromise, Maybe<int> in_executionContextId, Maybe<std::string> in_objectGroup,
                      std::unique_ptr<CallFunctionOnCallback> callback) override;

  DispatchResponse compileScript(const std::string &in_expression, const std::string &in_sourceURL,
                                 bool in_persistScript, Maybe<int> in_executionContextId,
                                 Maybe<std::string> *out_scriptId,
                                 Maybe<ExceptionDetails> *out_exceptionDetails) override;

  DispatchResponse disable() override;

  DispatchResponse discardConsoleEntries() override;

  DispatchResponse enable() override;

  void evaluate(const std::string &in_expression, Maybe<std::string> in_objectGroup,
                Maybe<bool> in_includeCommandLineAPI, Maybe<bool> in_silent, Maybe<int> in_contextId,
                Maybe<bool> in_returnByValue, Maybe<bool> in_generatePreview, Maybe<bool> in_userGesture,
                Maybe<bool> in_awaitPromise, Maybe<bool> in_throwOnSideEffect, Maybe<double> in_timeout,
                std::unique_ptr<EvaluateCallback> callback) override;

  DispatchResponse getIsolateId(std::string *out_id) override;

  DispatchResponse getHeapUsage(double *out_usedSize, double *out_totalSize) override;

  DispatchResponse
  getProperties(const std::string &in_objectId, Maybe<bool> in_ownProperties, Maybe<bool> in_accessorPropertiesOnly,
                Maybe<bool> in_generatePreview,
                std::unique_ptr<std::vector<std::unique_ptr<PropertyDescriptor>>> *out_result,
                Maybe<std::vector<std::unique_ptr<InternalPropertyDescriptor>>> *out_internalProperties,
                Maybe<std::vector<std::unique_ptr<PrivatePropertyDescriptor>>> *out_privateProperties,
                Maybe<ExceptionDetails> *out_exceptionDetails) override;

  DispatchResponse globalLexicalScopeNames(Maybe<int> in_executionContextId,
                                           std::unique_ptr<std::vector<std::string>> *out_names) override;

  DispatchResponse queryObjects(const std::string &in_prototypeObjectId, Maybe<std::string> in_objectGroup,
                                std::unique_ptr<RemoteObject> *out_objects) override;

  DispatchResponse releaseObject(const std::string &in_objectId) override;

  DispatchResponse releaseObjectGroup(const std::string &in_objectGroup) override;

  DispatchResponse runIfWaitingForDebugger() override;
  void runScript(const std::string &in_scriptId, Maybe<int> in_executionContextId, Maybe<std::string> in_objectGroup,
                 Maybe<bool> in_silent, Maybe<bool> in_includeCommandLineAPI, Maybe<bool> in_returnByValue,
                 Maybe<bool> in_generatePreview, Maybe<bool> in_awaitPromise,
                 std::unique_ptr<RunScriptCallback> callback) override;

  DispatchResponse setCustomObjectFormatterEnabled(bool in_enabled) override;

  DispatchResponse setMaxCallStackSizeToCapture(int in_size) override;

  void terminateExecution(std::unique_ptr<TerminateExecutionCallback> callback) override;

  DispatchResponse addBinding(const std::string &in_name, Maybe<int> in_executionContextId) override;

  DispatchResponse removeBinding(const std::string &in_name) override;

protected:
  virtual Inspector::InjectedScript injectedScriptForEval(WTF::String &, const int *executionContextId);

private:
  bool convertRemoteObject(const std::string &in_result, std::unique_ptr<RemoteObject> *out_result,
                           Inspector::ErrorString &error);

  void setTypeProfilerEnabledState(bool);
  void setControlFlowProfilerEnabledState(bool);

  Inspector::InjectedScriptManager *m_injectedScriptManager;
  bool m_enabled{false};
  bool m_isTypeProfilingEnabled{false};
  bool m_isControlFlowProfilingEnabled{false};

private:
  InspectorSession *m_session;
  RuntimeFrontend m_frontend;
  debugger::JSCDebuggerImpl *m_debugger;
  rapidjson::Document m_doc;
};
} // namespace kraken::debugger

#endif // KRAKEN_DEBUGGER_JSC_RUNTIME_AGENT_IMPL_H
