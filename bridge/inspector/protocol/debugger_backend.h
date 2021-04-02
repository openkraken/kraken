/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_DEBUGGERBACKEND_H
#define KRAKEN_DEBUGGER_DEBUGGERBACKEND_H

#include <memory>
#include <string>
#include <vector>

#include "inspector/protocol/break_location.h"
#include "inspector/protocol/call_argument.h"
#include "inspector/protocol/call_frame.h"
#include "inspector/protocol/dispatch_response.h"
#include "inspector/protocol/exception_details.h"
#include "inspector/protocol/location.h"
#include "inspector/protocol/maybe.h"
#include "inspector/protocol/remote_object.h"
#include "inspector/protocol/script_position.h"
#include "inspector/protocol/search_match.h"
#include "inspector/protocol/stacktrace.h"
#include "inspector/protocol/stacktrace_id.h"

namespace JSC {
class VM;
}

namespace kraken {
namespace debugger {

class DebuggerBackend {
public:
  virtual ~DebuggerBackend() {}

  virtual DispatchResponse continueToLocation(std::unique_ptr<Location> in_location,
                                              Maybe<std::string> in_targetCallFrames) = 0;

  virtual DispatchResponse disable() = 0;
  virtual DispatchResponse enable(Maybe<double> in_maxScriptsCacheSize, std::string *out_debuggerId) = 0;
  virtual DispatchResponse evaluateOnCallFrame(const std::string &in_callFrameId, const std::string &in_expression,
                                               Maybe<std::string> in_objectGroup, Maybe<bool> in_includeCommandLineAPI,
                                               Maybe<bool> in_silent, Maybe<bool> in_returnByValue,
                                               Maybe<bool> in_generatePreview, Maybe<bool> in_throwOnSideEffect,
                                               Maybe<double> in_timeout, std::unique_ptr<RemoteObject> *out_result,
                                               Maybe<ExceptionDetails> *out_exceptionDetails) = 0;

  virtual DispatchResponse
  getPossibleBreakpoints(std::unique_ptr<Location> in_start, Maybe<Location> in_end, Maybe<bool> in_restrictToFunction,
                         std::unique_ptr<std::vector<std::unique_ptr<BreakLocation>>> *out_locations) = 0;

  virtual DispatchResponse getScriptSource(const std::string &in_scriptId, std::string *out_scriptSource) = 0;
  virtual DispatchResponse getStackTrace(std::unique_ptr<StackTraceId> in_stackTraceId,
                                         std::unique_ptr<StackTrace> *out_stackTrace) = 0;
  virtual DispatchResponse pause() = 0;
  virtual DispatchResponse pauseOnAsyncCall(std::unique_ptr<StackTraceId> in_parentStackTraceId) = 0;
  virtual DispatchResponse removeBreakpoint(const std::string &in_breakpointId) = 0;
  virtual DispatchResponse restartFrame(const std::string &in_callFrameId,
                                        std::unique_ptr<std::vector<CallFrame>> *out_callFrames,
                                        Maybe<StackTrace> *out_asyncStackTrace,
                                        Maybe<StackTraceId> *out_asyncStackTraceId) = 0;
  virtual DispatchResponse resume() = 0;
  virtual DispatchResponse searchInContent(const std::string &in_scriptId, const std::string &in_query,
                                           Maybe<bool> in_caseSensitive, Maybe<bool> in_isRegex,
                                           std::unique_ptr<std::vector<SearchMatch>> *out_result) = 0;
  virtual DispatchResponse setAsyncCallStackDepth(int in_maxDepth) = 0;
  virtual DispatchResponse setBlackboxPatterns(std::unique_ptr<std::vector<std::string>> in_patterns) = 0;
  virtual DispatchResponse
  setBlackboxedRanges(const std::string &in_scriptId,
                      std::unique_ptr<std::vector<std::unique_ptr<ScriptPosition>>> in_positions) = 0;
  virtual DispatchResponse setBreakpoint(std::unique_ptr<Location> in_location, Maybe<std::string> in_condition,
                                         std::string *out_breakpointId,
                                         std::unique_ptr<Location> *out_actualLocation) = 0;
  virtual DispatchResponse
  setBreakpointByUrl(int in_lineNumber, Maybe<std::string> in_url, Maybe<std::string> in_urlRegex,
                     Maybe<std::string> in_scriptHash, Maybe<int> in_columnNumber, Maybe<std::string> in_condition,
                     std::string *out_breakpointId,
                     std::unique_ptr<std::vector<std::unique_ptr<Location>>> *out_locations) = 0;
  virtual DispatchResponse setBreakpointOnFunctionCall(const std::string &in_objectId, Maybe<std::string> in_condition,
                                                       std::string *out_breakpointId) = 0;
  virtual DispatchResponse setBreakpointsActive(bool in_active) = 0;
  virtual DispatchResponse setPauseOnExceptions(const std::string &in_state) = 0;
  virtual DispatchResponse setReturnValue(std::unique_ptr<CallArgument> in_newValue) = 0;
  virtual DispatchResponse setScriptSource(const std::string &in_scriptId, const std::string &in_scriptSource,
                                           Maybe<bool> in_dryRun, Maybe<std::vector<CallFrame>> *out_callFrames,
                                           Maybe<bool> *out_stackChanged, Maybe<StackTrace> *out_asyncStackTrace,
                                           Maybe<StackTraceId> *out_asyncStackTraceId,
                                           Maybe<ExceptionDetails> *out_exceptionDetails) = 0;
  virtual DispatchResponse setSkipAllPauses(bool in_skip) = 0;
  virtual DispatchResponse setVariableValue(int in_scopeNumber, const std::string &in_variableName,
                                            std::unique_ptr<CallArgument> in_newValue,
                                            const std::string &in_callFrameId) = 0;
  virtual DispatchResponse stepInto(Maybe<bool> in_breakOnAsyncCall) = 0;
  virtual DispatchResponse stepOut() = 0;
  virtual DispatchResponse stepOver() = 0;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_DEBUGGERBACKEND_H
