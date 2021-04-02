/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_RUNTIME_BACKEND_H
#define KRAKEN_DEBUGGER_RUNTIME_BACKEND_H

#include "inspector/protocol/call_argument.h"
#include "inspector/protocol/dispatch_response.h"
#include "inspector/protocol/exception_details.h"
#include "inspector/protocol/internal_property_descriptor.h"
#include "inspector/protocol/maybe.h"
#include "inspector/protocol/private_property_descriptor.h"
#include "inspector/protocol/property_descriptor.h"
#include "inspector/protocol/remote_object.h"

#include <string>
#include <vector>

namespace kraken {
namespace debugger {
class RuntimeBackend {
public:
  virtual ~RuntimeBackend() {}

  class AwaitPromiseCallback {
  public:
    virtual void sendSuccess(std::unique_ptr<RemoteObject> result, Maybe<ExceptionDetails> exceptionDetails) = 0;
    virtual void sendFailure(const DispatchResponse &) = 0;
    virtual void fallThrough() = 0;
    virtual ~AwaitPromiseCallback() {}
  };
  virtual void awaitPromise(const std::string &in_promiseObjectId, Maybe<bool> in_returnByValue,
                            Maybe<bool> in_generatePreview, std::unique_ptr<AwaitPromiseCallback> callback) = 0;

  class CallFunctionOnCallback {
  public:
    virtual void sendSuccess(std::unique_ptr<RemoteObject> result, Maybe<ExceptionDetails> exceptionDetails) = 0;
    virtual void sendFailure(const DispatchResponse &) = 0;
    virtual void fallThrough() = 0;
    virtual ~CallFunctionOnCallback() {}
  };

  virtual void callFunctionOn(const std::string &in_functionDeclaration, Maybe<std::string> in_objectId,
                              Maybe<std::vector<std::unique_ptr<CallArgument>>> in_arguments, Maybe<bool> in_silent,
                              Maybe<bool> in_returnByValue, Maybe<bool> in_generatePreview, Maybe<bool> in_userGesture,
                              Maybe<bool> in_awaitPromise, Maybe<int> in_executionContextId,
                              Maybe<std::string> in_objectGroup, std::unique_ptr<CallFunctionOnCallback> callback) = 0;

  virtual DispatchResponse compileScript(const std::string &in_expression, const std::string &in_sourceURL,
                                         bool in_persistScript, Maybe<int> in_executionContextId,
                                         Maybe<std::string> *out_scriptId,
                                         Maybe<ExceptionDetails> *out_exceptionDetails) = 0;

  virtual DispatchResponse disable() = 0;

  virtual DispatchResponse discardConsoleEntries() = 0;

  virtual DispatchResponse enable() = 0;

  class EvaluateCallback {
  public:
    virtual void sendSuccess(std::unique_ptr<RemoteObject> result, Maybe<ExceptionDetails> exceptionDetails) = 0;
    virtual void sendFailure(const DispatchResponse &) = 0;
    virtual void fallThrough() = 0;
    virtual ~EvaluateCallback() {}
  };

  virtual void evaluate(const std::string &in_expression, Maybe<std::string> in_objectGroup,
                        Maybe<bool> in_includeCommandLineAPI, Maybe<bool> in_silent, Maybe<int> in_contextId,
                        Maybe<bool> in_returnByValue, Maybe<bool> in_generatePreview, Maybe<bool> in_userGesture,
                        Maybe<bool> in_awaitPromise, Maybe<bool> in_throwOnSideEffect, Maybe<double> in_timeout,
                        std::unique_ptr<EvaluateCallback> callback) = 0;

  virtual DispatchResponse getIsolateId(std::string *out_id) = 0;

  virtual DispatchResponse getHeapUsage(double *out_usedSize, double *out_totalSize) = 0;

  virtual DispatchResponse
  getProperties(const std::string &in_objectId, Maybe<bool> in_ownProperties, Maybe<bool> in_accessorPropertiesOnly,
                Maybe<bool> in_generatePreview,
                std::unique_ptr<std::vector<std::unique_ptr<PropertyDescriptor>>> *out_result,
                Maybe<std::vector<std::unique_ptr<InternalPropertyDescriptor>>> *out_internalProperties,
                Maybe<std::vector<std::unique_ptr<PrivatePropertyDescriptor>>> *out_privateProperties,
                Maybe<ExceptionDetails> *out_exceptionDetails) = 0;

  virtual DispatchResponse globalLexicalScopeNames(Maybe<int> in_executionContextId,
                                                   std::unique_ptr<std::vector<std::string>> *out_names) = 0;

  virtual DispatchResponse queryObjects(const std::string &in_prototypeObjectId, Maybe<std::string> in_objectGroup,
                                        std::unique_ptr<RemoteObject> *out_objects) = 0;

  virtual DispatchResponse releaseObject(const std::string &in_objectId) = 0;

  virtual DispatchResponse releaseObjectGroup(const std::string &in_objectGroup) = 0;

  virtual DispatchResponse runIfWaitingForDebugger() = 0;

  class RunScriptCallback {
  public:
    virtual void sendSuccess(std::unique_ptr<RemoteObject> result, Maybe<ExceptionDetails> exceptionDetails) = 0;

    virtual void sendFailure(const DispatchResponse &) = 0;

    virtual void fallThrough() = 0;

    virtual ~RunScriptCallback() {}
  };

  virtual void runScript(const std::string &in_scriptId, Maybe<int> in_executionContextId,
                         Maybe<std::string> in_objectGroup, Maybe<bool> in_silent, Maybe<bool> in_includeCommandLineAPI,
                         Maybe<bool> in_returnByValue, Maybe<bool> in_generatePreview, Maybe<bool> in_awaitPromise,
                         std::unique_ptr<RunScriptCallback> callback) = 0;

  virtual DispatchResponse setCustomObjectFormatterEnabled(bool in_enabled) = 0;

  virtual DispatchResponse setMaxCallStackSizeToCapture(int in_size) = 0;

  class TerminateExecutionCallback {
  public:
    virtual void sendSuccess() = 0;
    virtual void sendFailure(const DispatchResponse &) = 0;
    virtual void fallThrough() = 0;
    virtual ~TerminateExecutionCallback() {}
  };

  virtual void terminateExecution(std::unique_ptr<TerminateExecutionCallback> callback) = 0;

  virtual DispatchResponse addBinding(const std::string &in_name, Maybe<int> in_executionContextId) = 0;

  virtual DispatchResponse removeBinding(const std::string &in_name) = 0;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_RUNTIME_BACKEND_H
