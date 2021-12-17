/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/protocol/break_location.h"
#include "inspector/protocol/debug_dispatcher_impl.h"
#include "inspector/protocol/exception_details.h"
#include "inspector/protocol/location.h"
#include "inspector/protocol/remote_object.h"
#include "inspector/protocol/search_match.h"
#include "inspector/protocol/stacktrace.h"
#include "inspector/protocol/stacktrace_id.h"

// #include "foundation/make_copyable.h"

namespace kraken {
namespace debugger {

bool DebugDispatcherImpl::canDispatch(const std::string &method) {
  return m_dispatchMap.find(method) != m_dispatchMap.end();
}

void DebugDispatcherImpl::dispatch(uint64_t callId, const std::string &method, debugger::JSONObject message) {
  std::unordered_map<std::string, CallHandler>::iterator it = m_dispatchMap.find(method);
  if (it == m_dispatchMap.end()) {
    return;
  }
  ErrorSupport errors;
  (it->second)(callId, method, std::move(message), &errors);
}

/**
 *
 * Continues execution until specific location is reached.
 *
 * @params location: Location to continue to.
 * @params targetCallFrames
 *
 * */
void DebugDispatcherImpl::continueToLocation(uint64_t callId, const std::string &method,
                                             debugger::JSONObject message, debugger::ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  errors->setName("location");

  std::unique_ptr<Location> in_location = nullptr;
  if (message.HasMember("location") && message["location"].IsObject()) {
    rapidjson::Value _loc = message["location"].GetObject();
    in_location = Location::fromValue(&_loc, errors);
  } else {
    errors->addError("location not found");
  }

  Maybe<std::string> in_targetCallFrames;
  if (message.HasMember("targetCallFrames")) {
    errors->setName("targetCallFrames");
    if (message["targetCallFrames"].IsString()) {
      in_targetCallFrames = message["targetCallFrames"].GetString();
    } else {
      errors->addError("targetCallFrames should be string");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->continueToLocation(std::move(in_location), std::move(in_targetCallFrames));
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

/**
 *
 * Disables debugger for given page.
 *
 * */
void DebugDispatcherImpl::disable(uint64_t callId, const std::string &method, JSONObject message,
                                  ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->disable();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

/*
 *
 * Enables debugger for the given page. Clients should not assume that the debugging has been
 * enabled until the result for this command is received.
 *
 *
 * @params
 *   - maxScriptsCacheSize: The maximum size in bytes of collected scripts (not referenced by other heap objects)
 *                          the debugger can hold. Puts no limit if parameter is omitted
 *
 * **/
void DebugDispatcherImpl::enable(uint64_t callId, const std::string &method, JSONObject message,
                                 ErrorSupport *) {
  double maxScriptsCacheSize = -1;
  if (message.HasMember("maxScriptsCacheSize")) {
    maxScriptsCacheSize = message["maxScriptsCacheSize"].GetDouble();
  }

  std::string out_debuggerId;
  auto weak = this->weakPtr();

  DispatchResponse response = m_backend->enable(maxScriptsCacheSize, &out_debuggerId);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  debugger::JSONObject result;
  result.SetObject();
  if (response.status() == DispatchResponse::kSuccess) {
    debugger::JSONObject debugId;
    debugId.SetString(out_debuggerId.c_str(), m_json_doc.GetAllocator());
    result.AddMember("debuggerId", debugId, m_json_doc.GetAllocator());
  }
  if (weak->get()) {
    weak->get()->sendResponse(callId, response, std::move(result));
  }
}

/**
 * Evaluates expression on a given call frame
 *
 * @param callFrameId: Call frame identifier to evaluate on.
 * @param expression: Expression to evaluate.
 * @param objectGroup: String object group name to put result into (allows rapid releasing resulting object handles
 * using `releaseObjectGroup`).
 * @param includeCommandLineAPI: Specifies whether command line API should be available to the evaluated expression,
 * defaults to false.
 * @param silent: In silent mode exceptions thrown during evaluation are not reported and do not pause execution.
 * Overrides `setPauseOnException` state.
 * @param returnByValue: Whether the result is expected to be a JSON object that should be sent by value.
 * @param generatePreview: Whether preview should be generated for the result.
 * @param throwOnSideEffect: Whether to throw an exception if side effect cannot be ruled out during evaluation.
 * @param timeout: Terminate execution after timing out (number of milliseconds).
 *
 * @return
 *      - result: Object wrapper for the evaluation result.
 *      - exceptionDetails: Exception details.
 *
 * */
void DebugDispatcherImpl::evaluateOnCallFrame(uint64_t callId, const std::string &method, JSONObject message,
                                              ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_callFrameId;
  if (message.HasMember("callFrameId") && message["callFrameId"].IsString()) {
    in_callFrameId = message["callFrameId"].GetString();
  } else {
    errors->setName("callFrameId");
    errors->addError("callFrameId not found");
  }

  std::string in_expression;
  if (message.HasMember("expression") && message["expression"].IsString()) {
    in_expression = message["expression"].GetString();
  } else {
    errors->setName("expression");
    errors->addError("expression not found");
  }

  Maybe<std::string> in_objectGroup;
  if (message.HasMember("objectGroup")) {
    if (message["objectGroup"].IsString()) {
      in_objectGroup = message["objectGroup"].GetString();
    } else {
      errors->setName("objectGroup");
      errors->addError("objectGroup should be string");
    }
  }

  Maybe<bool> in_includeCommandLineAPI;
  if (message.HasMember("includeCommandLineAPI")) {
    if (message["includeCommandLineAPI"].IsBool()) {
      in_includeCommandLineAPI = message["includeCommandLineAPI"].GetBool();
    } else {
      errors->setName("includeCommandLineAPI");
      errors->addError("includeCommandLineAPI should be bool");
    }
  }

  Maybe<bool> in_silent;
  if (message.HasMember("silent")) {
    if (message["silent"].IsBool()) {
      in_silent = message["silent"].GetBool();
    } else {
      errors->setName("silent");
      errors->addError("silent should be bool");
    }
  }

  Maybe<bool> in_returnByValue;
  if (message.HasMember("returnByValue")) {
    if (message["returnByValue"].IsBool()) {
      in_returnByValue = message["returnByValue"].GetBool();
    } else {
      errors->setName("returnByValue");
      errors->addError("returnByValue should be bool");
    }
  }

  Maybe<bool> in_generatePreview;
  if (message.HasMember("generatePreview")) {
    if (message["generatePreview"].IsBool()) {
      in_generatePreview = message["generatePreview"].GetBool();
    } else {
      errors->setName("generatePreview");
      errors->addError("generatePreview should be bool");
    }
  }

  Maybe<bool> in_throwOnSideEffect;
  if (message.HasMember("throwOnSideEffect")) {
    if (message["throwOnSideEffect"].IsBool()) {
      in_throwOnSideEffect = message["throwOnSideEffect"].GetBool();
    } else {
      errors->setName("throwOnSideEffect");
      errors->addError("throwOnSideEffect should be bool");
    }
  }

  Maybe<double> in_timeout;
  if (message.HasMember("timeout")) {
    if (message["timeout"].IsDouble()) {
      in_timeout = message["timeout"].GetDouble();
    } else {
      errors->setName("timeout");
      errors->addError("timeout should be double");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }
  // Declare output parameters.
  std::unique_ptr<RemoteObject> out_result;
  Maybe<ExceptionDetails> out_exceptionDetails;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->evaluateOnCallFrame(
    in_callFrameId, in_expression, std::move(in_objectGroup), std::move(in_includeCommandLineAPI), std::move(in_silent),
    std::move(in_returnByValue), std::move(in_generatePreview), std::move(in_throwOnSideEffect), std::move(in_timeout),
    &out_result, &out_exceptionDetails);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }

  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();
  if (response.status() == DispatchResponse::kSuccess) {
    result.AddMember("result", out_result->toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
    if (out_exceptionDetails.isJust())
      result.AddMember("exceptionDetails", out_exceptionDetails.fromJust()->toValue(m_json_doc.GetAllocator()),
                       m_json_doc.GetAllocator());
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

/**
 *
 * Returns possible locations for breakpoint. scriptId in start and end range locations should be the same.
 *
 * @param start: Start of range to search possible breakpoint locations in.
 * @param end: End of range to search possible breakpoint locations in (excluding).
 *             When not specified, end of scripts is used as end of range.
 *
 * @param restrictToFunction: Only consider locations which are in the same (non-nested) function as start.
 *
 * @return locations: List of the possible breakpoint locations.
 *
 * */
void DebugDispatcherImpl::getPossibleBreakpoints(uint64_t callId, const std::string &method,
                                                 JSONObject message, ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::unique_ptr<Location> in_start = nullptr;
  if (message.HasMember("start") && message["start"].IsObject()) {
    rapidjson::Value _start = message["start"].GetObject();
    in_start = Location::fromValue(&_start, errors);
  } else {
    errors->setName("start");
    errors->addError("start not found");
  }

  Maybe<Location> in_end;
  if (message.HasMember("end")) {
    errors->setName("end");
    if (message["end"].IsObject()) {
      rapidjson::Value _end = message["end"].GetObject();
      in_end = Location::fromValue(&_end, errors);
    } else {
      errors->addError("end should be object");
    }
  }

  Maybe<bool> in_restrictToFunction;
  if (message.HasMember("restrictToFunction")) {
    errors->setName("restrictToFunction");
    if (message["restrictToFunction"].IsBool()) {
      in_restrictToFunction = message["restrictToFunction"].GetBool();
    } else {
      errors->addError("restrictToFunction should be bool");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }
  // Declare output parameters.
  std::unique_ptr<std::vector<std::unique_ptr<BreakLocation>>> out_locations;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->getPossibleBreakpoints(std::move(in_start), std::move(in_end),
                                                                std::move(in_restrictToFunction), &out_locations);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();
  if (response.status() == DispatchResponse::kSuccess) {
    rapidjson::Value location_array = rapidjson::Value(rapidjson::kArrayType);
    if (out_locations != nullptr) {
      for (auto &val : *out_locations) {
        location_array.PushBack(val->toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
      }
      result.AddMember("locations", location_array, m_json_doc.GetAllocator());
    }
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

/**
 *
 * Returns source for the script with given id.
 *
 * @params scriptId: Id of the script to get source for.
 * @return scriptSource: Script source.
 *
 * */
void DebugDispatcherImpl::getScriptSource(uint64_t callId, const std::string &method, JSONObject message,
                                          ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_scriptId;
  if (message.HasMember("scriptId") && message["scriptId"].IsString()) {
    in_scriptId = message["scriptId"].GetString();
  } else {
    errors->setName("scriptId");
    errors->addError("scriptId not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }
  // Declare output parameters.
  std::string out_scriptSource;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->getScriptSource(in_scriptId, &out_scriptSource);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();
  if (response.status() == DispatchResponse::kSuccess) {
    rapidjson::Value _source(out_scriptSource.c_str(), out_scriptSource.length(), m_json_doc.GetAllocator());
    result.AddMember("scriptSource", _source, m_json_doc.GetAllocator());
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

/**
 *
 * Returns stack trace with given `stackTraceId`. [experimental]
 *
 * @params stackTraceId
 * @return stackTrace
 *
 * */
void DebugDispatcherImpl::getStackTrace(uint64_t callId, const std::string &method, JSONObject message,
                                        ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  errors->setName("stackTraceId");
  std::unique_ptr<StackTraceId> in_stackTraceId = nullptr;
  if (message.HasMember("stackTraceId") && message["stackTraceId"].IsObject()) {
    rapidjson::Value _stack_trace_id = message["stackTraceId"].GetObject();
    in_stackTraceId = StackTraceId::fromValue(&_stack_trace_id, errors);
  } else {
    errors->setName("stackTraceId");
    errors->addError("stackTraceId not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }
  // Declare output parameters.
  std::unique_ptr<StackTrace> out_stackTrace;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->getStackTrace(std::move(in_stackTraceId), &out_stackTrace);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }

  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();

  if (response.status() == DispatchResponse::kSuccess) {
    result.AddMember("stackTrace", out_stackTrace->toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

/**
 *
 * Stops on the next JavaScript statement.
 *
 * */
void DebugDispatcherImpl::pause(uint64_t callId, const std::string &method, JSONObject message,
                                ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->pause();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::pauseOnAsyncCall(uint64_t callId, const std::string &method, JSONObject message,
                                           ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  std::unique_ptr<StackTraceId> in_parentStackTraceId = nullptr;
  if (message.HasMember("parentStackTraceId") && message["parentStackTraceId"].IsObject()) {
    rapidjson::Value _parentStackTraceId = message["parentStackTraceId"].GetObject();
    in_parentStackTraceId = StackTraceId::fromValue(&_parentStackTraceId, errors);
  } else {
    errors->setName("parentStackTraceId");
    errors->addError("parentStackTraceId not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->pauseOnAsyncCall(std::move(in_parentStackTraceId));
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

/**
 *
 * Removes JavaScript breakpoint.
 *
 * @param breakpointId
 * */
void DebugDispatcherImpl::removeBreakpoint(uint64_t callId, const std::string &method, JSONObject message,
                                           ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_breakpointId = "";
  if (message.HasMember("breakpointId") && message["breakpointId"].IsString()) {
    in_breakpointId = message["breakpointId"].GetString();
  } else {
    errors->setName("breakpointId");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->removeBreakpoint(in_breakpointId);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

/**
 * Restarts particular call frame from the beginning.
 *
 * @param callFrameId Call frame identifier to evaluate on.
 *
 * @return
 *      - callFrames: New stack trace.
 *      - asyncStackTrace: Async stack trace, if any.
 *      - asyncStackTraceId: Async stack trace, if any.
 * */
void DebugDispatcherImpl::restartFrame(uint64_t callId, const std::string &method, JSONObject message,
                                       ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_callFrameId;
  if (message.HasMember("callFrameId") && message["callFrameId"].IsString()) {
    in_callFrameId = message["callFrameId"].GetString();
  } else {
    errors->setName("callFrameId");
    errors->addError("callFrameId not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  // Declare output parameters.
  std::unique_ptr<std::vector<CallFrame>> out_callFrames;
  Maybe<StackTrace> out_asyncStackTrace;
  Maybe<StackTraceId> out_asyncStackTraceId;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response =
    m_backend->restartFrame(in_callFrameId, &out_callFrames, &out_asyncStackTrace, &out_asyncStackTraceId);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }

  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();
  if (response.status() == DispatchResponse::kSuccess) {
    if (out_callFrames != nullptr) {
      rapidjson::Value _callFrames_arr(rapidjson::kArrayType);
      _callFrames_arr.SetArray();
      for (const auto &frame : *out_callFrames) {
        _callFrames_arr.PushBack(frame.toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
      }
      result.AddMember("callFrames", _callFrames_arr, m_json_doc.GetAllocator());
    }
    if (out_asyncStackTrace.isJust()) {
      result.AddMember("asyncStackTrace", out_asyncStackTrace.fromJust()->toValue(m_json_doc.GetAllocator()),
                       m_json_doc.GetAllocator());
    }
    if (out_asyncStackTraceId.isJust()) {
      result.AddMember("asyncStackTraceId", out_asyncStackTraceId.fromJust()->toValue(m_json_doc.GetAllocator()),
                       m_json_doc.GetAllocator());
    }
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

void DebugDispatcherImpl::resume(uint64_t callId, const std::string &method, JSONObject message,
                                 ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->resume();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

/**
 *
 * Searches for given string in script content.
 *
 * @param scriptId: Id of the script to search in.
 * @param query: String to search for.
 * @param caseSensitive: If true, search is case sensitive.
 * @param isRegex: If true, treats string parameter as regex.
 *
 * @return
 *      - result: List of search matches.
 *
 * */
void DebugDispatcherImpl::searchInContent(uint64_t callId, const std::string &method, JSONObject message,
                                          ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_scriptId;
  if (message.HasMember("scriptId") && message["scriptId"].IsString()) {
    in_scriptId = message["scriptId"].GetString();
  } else {
    errors->setName("scriptId");
    errors->addError("scriptId not found");
  }

  std::string in_query;
  if (message.HasMember("query") && message["query"].IsString()) {
    in_query = message["query"].GetString();
  } else {
    errors->setName("query");
    errors->addError("query not found");
  }

  Maybe<bool> in_caseSensitive;
  if (message.HasMember("caseSensitive")) {
    errors->setName("caseSensitive");
    if (message["caseSensitive"].IsBool()) {
      in_caseSensitive = message["caseSensitive"].GetBool();
    } else {
      errors->addError("caseSensitive should be bool");
    }
  }

  Maybe<bool> in_isRegex;
  if (message.HasMember("isRegex")) {
    errors->setName("isRegex");
    if (message["isRegex"].IsBool()) {
      in_isRegex = message["isRegex"].GetBool();
    } else {
      errors->addError("isRegex should be bool");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }
  // Declare output parameters.
  std::unique_ptr<std::vector<SearchMatch>> out_result;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response =
    m_backend->searchInContent(in_scriptId, in_query, std::move(in_caseSensitive), std::move(in_isRegex), &out_result);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();
  if (response.status() == DispatchResponse::kSuccess && out_result != nullptr) {
    rapidjson::Value _arr(rapidjson::kArrayType);
    _arr.SetArray();
    for (const auto &match : *out_result) {
      _arr.PushBack(match.toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
    }
    result.AddMember("result", _arr, m_json_doc.GetAllocator());
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

void DebugDispatcherImpl::setAsyncCallStackDepth(uint64_t callId, const std::string &method,
                                                 JSONObject message, ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  int in_maxDepth = 0;
  if (message.HasMember("maxDepth") && message["maxDepth"].IsInt()) {
    in_maxDepth = message["maxDepth"].GetInt();
  } else {
    errors->setName("maxDepth");
    errors->addError("maxDepth not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->setAsyncCallStackDepth(in_maxDepth);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::setBlackboxPatterns(uint64_t callId, const std::string &method, JSONObject message,
                                              ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  std::unique_ptr<std::vector<std::string>> in_patterns = std::make_unique<std::vector<std::string>>();
  if (message.HasMember("patterns") && message["patterns"].IsArray()) {
    auto _patterns = message["patterns"].GetArray();
    for (auto &v : _patterns) {
      if (v.IsString()) {
        in_patterns->push_back(v.GetString());
      }
    }
  } else {
    errors->setName("patterns");
    errors->addError("patterns not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->setBlackboxPatterns(std::move(in_patterns));
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::setBlackboxedRanges(uint64_t callId, const std::string &method, JSONObject message,
                                              ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_scriptId;
  if (message.HasMember("scriptId") && message["scriptId"].IsString()) {
    in_scriptId = message["scriptId"].GetString();
  } else {
    errors->setName("scriptId");
    errors->addError("scriptId not found");
  }

  auto in_positions = std::make_unique<std::vector<std::unique_ptr<ScriptPosition>>>();
  if (message.HasMember("positions") && message["positions"].IsArray()) {
    auto _positions = message["positions"].GetArray();
    for (auto &pos : _positions) {
      if (pos.IsObject()) {
        in_positions->push_back(ScriptPosition::fromValue(&pos, errors));
      }
    }
  } else {
    errors->setName("positions");
    errors->addError("positions not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->setBlackboxedRanges(in_scriptId, std::move(in_positions));
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::setBreakpoint(uint64_t callId, const std::string &method, JSONObject message,
                                        ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::unique_ptr<Location> in_location = nullptr;
  if (message.HasMember("location") && message["location"].IsObject()) {
    rapidjson::Value _location = message["location"].GetObject();
    in_location = Location::fromValue(&_location, errors);
  } else {
    errors->setName("location");
    errors->addError("location not found");
  }

  Maybe<std::string> in_condition;
  if (message.HasMember("condition")) {
    if (message["condition"].IsString()) {
      in_condition = message["condition"].GetString();
    } else {
      errors->setName("condition");
      errors->addError("condition should be string");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }
  // Declare output parameters.
  std::string out_breakpointId;
  std::unique_ptr<Location> out_actualLocation;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response =
    m_backend->setBreakpoint(std::move(in_location), std::move(in_condition), &out_breakpointId, &out_actualLocation);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }

  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();

  if (response.status() == DispatchResponse::kSuccess) {
    result.AddMember("breakpointId", out_breakpointId, m_json_doc.GetAllocator());
    result.AddMember("actualLocation", out_actualLocation.get()->toValue(m_json_doc.GetAllocator()),
                     m_json_doc.GetAllocator());
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

/**
 * Sets JavaScript breakpoint at given location specified either by URL or URL regex.
 * Once this command is issued, all existing parsed scripts will have breakpoints resolved and returned in
 * `locations` property. Further matching script parsing will result in subsequent `breakpointResolved` events issued.
 * This logical breakpoint will survive page reloads.
 *
 *
 * @param lineNumber: Line number to set breakpoint at.
 * @param url: URL of the resources to set breakpoint on.
 * @param urlRegex: Regex pattern for the URLs of the resources to set breakpoints on. Either `url` or `urlRegex` must
 * be specified.
 * @param scriptHash: Script hash of the resources to set breakpoint on.
 * @param columnNumber: Offset in the line to set breakpoint at.
 * @param condition: Expression to use as a breakpoint condition. When specified, debugger will only stop on the
 * breakpoint if this expression evaluates to true.
 *
 * */
void DebugDispatcherImpl::setBreakpointByUrl(uint64_t callId, const std::string &method, JSONObject message,
                                             ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  int in_lineNumber = 0;
  if (message.HasMember("lineNumber") && message["lineNumber"].IsInt()) {
    in_lineNumber = message["lineNumber"].GetInt();
  } else {
    errors->setName("lineNumber");
    errors->addError("lineNumber not found");
  }

  Maybe<std::string> in_url;
  if (message.HasMember("url")) {
    errors->setName("url");
    if (message["url"].IsString()) {
      in_url = message["url"].GetString();
    } else {
      errors->addError("url should be string");
    }
  }

  Maybe<std::string> in_urlRegex;
  if (message.HasMember("urlRegex")) {
    errors->setName("urlRegex");
    if (message["urlRegex"].IsString()) {
      in_urlRegex = message["urlRegex"].GetString();
    } else {
      errors->addError("urlRegex should be string");
    }
  }

  Maybe<std::string> in_scriptHash;
  if (message.HasMember("scriptHash")) {
    errors->setName("scriptHash");
    if (message["scriptHash"].IsString()) {
      in_scriptHash = message["scriptHash"].GetString();
    } else {
      errors->addError("scriptHash should be string");
    }
  }

  Maybe<int> in_columnNumber;
  if (message.HasMember("columnNumber")) {
    errors->setName("columnNumber");
    if (message["columnNumber"].IsInt()) {
      in_columnNumber = message["columnNumber"].GetInt();
    } else {
      errors->addError("columnNumber should be string");
    }
  }

  Maybe<std::string> in_condition;
  if (message.HasMember("condition")) {
    errors->setName("condition");
    if (message["condition"].IsString()) {
      in_condition = message["condition"].GetString();
    } else {
      errors->addError("condition should be string");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  // Declare output parameters.
  std::string out_breakpointId;
  std::unique_ptr<std::vector<std::unique_ptr<Location>>> out_locations;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->setBreakpointByUrl(in_lineNumber, std::move(in_url), std::move(in_urlRegex),
                                                            std::move(in_scriptHash), std::move(in_columnNumber),
                                                            std::move(in_condition), &out_breakpointId, &out_locations);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();
  if (response.status() == DispatchResponse::kSuccess) {
    result.AddMember("breakpointId", out_breakpointId, m_json_doc.GetAllocator());

    if (out_locations != nullptr) {
      rapidjson::Value _location_array(rapidjson::kArrayType);
      _location_array.SetArray();
      for (const auto &loc : *out_locations) {
        _location_array.PushBack(loc->toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
      }
      result.AddMember("locations", _location_array, m_json_doc.GetAllocator());
    }
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

void DebugDispatcherImpl::setBreakpointOnFunctionCall(uint64_t callId, const std::string &method,
                                                      JSONObject message, ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  std::string in_objectId = "";
  if (message.HasMember("objectId") && message["objectId"].IsString()) {
    in_objectId = message["objectId"].GetString();
  } else {
    errors->setName("objectId");
    errors->addError("objectId not found");
  }

  Maybe<std::string> in_condition;
  if (message.HasMember("condition")) {
    errors->setName("condition");
    if (message["condition"].IsString()) {
      in_condition = message["condition"].GetString();
    } else {
      errors->addError("condition should be string");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }
  // Declare output parameters.
  std::string out_breakpointId;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response =
    m_backend->setBreakpointOnFunctionCall(in_objectId, std::move(in_condition), &out_breakpointId);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }

  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();
  if (response.status() == DispatchResponse::kSuccess) {
    result.AddMember("breakpointId", out_breakpointId, m_json_doc.GetAllocator());
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

void DebugDispatcherImpl::setBreakpointsActive(uint64_t callId, const std::string &method, JSONObject message,
                                               ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  bool in_active = false;
  if (message.HasMember("active") && message["active"].IsBool()) {
    in_active = message["active"].GetBool();
  } else {
    errors->setName("active");
    errors->addError("active not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->setBreakpointsActive(in_active);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::setPauseOnExceptions(uint64_t callId, const std::string &method, JSONObject message,
                                               ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  std::string in_state;
  if (message.HasMember("state") && message["state"].IsString()) {
    in_state = message["state"].GetString();
  } else {
    errors->setName("state");
    errors->addError("state not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->setPauseOnExceptions(in_state);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::setReturnValue(uint64_t callId, const std::string &method, JSONObject message,
                                         ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::unique_ptr<CallArgument> in_newValue;
  if (message.HasMember("newValue") && message["newValue"].IsObject()) {
    rapidjson::Value _call_argument = message["newValue"].GetObject();
    in_newValue = CallArgument::fromValue(&_call_argument, errors);
  } else {
    errors->setName("newValue");
    errors->addError("newValue not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->setReturnValue(std::move(in_newValue));
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::setScriptSource(uint64_t callId, const std::string &method, JSONObject message,
                                          ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_scriptId;
  if (message.HasMember("scriptId") && message["scriptId"].IsString()) {
    in_scriptId = message["scriptId"].GetString();
  } else {
    errors->setName("scriptId");
    errors->addError("scriptId not found");
  }

  std::string in_scriptSource;
  if (message.HasMember("scriptSource") && message["scriptSource"].IsString()) {
    in_scriptSource = message["scriptSource"].GetString();
  } else {
    errors->setName("scriptSource");
    errors->addError("scriptSource not found");
  }

  Maybe<bool> in_dryRun;
  if (message.HasMember("dryRun")) {
    errors->setName("dryRun");
    if (message["dryRun"].IsBool()) {
      in_dryRun = message["dryRun"].GetBool();
    } else {
      errors->addError("dryRun should be bool");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  // Declare output parameters.
  Maybe<std::vector<CallFrame>> out_callFrames;
  Maybe<bool> out_stackChanged;
  Maybe<StackTrace> out_asyncStackTrace;
  Maybe<StackTraceId> out_asyncStackTraceId;
  Maybe<ExceptionDetails> out_exceptionDetails;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response =
    m_backend->setScriptSource(in_scriptId, in_scriptSource, std::move(in_dryRun), &out_callFrames, &out_stackChanged,
                               &out_asyncStackTrace, &out_asyncStackTraceId, &out_exceptionDetails);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();
  if (response.status() == DispatchResponse::kSuccess) {
    if (out_callFrames.isJust()) {
      rapidjson::Value _arr(rapidjson::kArrayType);
      _arr.SetArray();

      for (const auto &frame : *(out_callFrames.fromJust())) {
        _arr.PushBack(frame.toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
      }
      result.AddMember("callFrames", _arr, m_json_doc.GetAllocator());
    }
    if (out_stackChanged.isJust()) {
      result.AddMember("stackChanged", out_stackChanged.fromJust(), m_json_doc.GetAllocator());
    }
    if (out_asyncStackTrace.isJust()) {
      result.AddMember("asyncStackTrace", out_asyncStackTrace.fromJust()->toValue(m_json_doc.GetAllocator()),
                       m_json_doc.GetAllocator());
    }
    if (out_asyncStackTraceId.isJust()) {
      result.AddMember("asyncStackTraceId", out_asyncStackTraceId.fromJust()->toValue(m_json_doc.GetAllocator()),
                       m_json_doc.GetAllocator());
    }
    if (out_exceptionDetails.isJust()) {
      result.AddMember("exceptionDetails", out_exceptionDetails.fromJust()->toValue(m_json_doc.GetAllocator()),
                       m_json_doc.GetAllocator());
    }
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

void DebugDispatcherImpl::setSkipAllPauses(uint64_t callId, const std::string &method, JSONObject message,
                                           ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  bool in_skip = false;
  if (message.HasMember("skip") && message["skip"].IsBool()) {
    in_skip = message["skip"].GetBool();
  } else {
    errors->setName("skip");
    errors->addError("skip not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->setSkipAllPauses(in_skip);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::setVariableValue(uint64_t callId, const std::string &method, JSONObject message,
                                           ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  int in_scopeNumber = 0;
  if (message.HasMember("scopeNumber") && message["scopeNumber"].IsInt()) {
    in_scopeNumber = message["scopeNumber"].GetInt();
  } else {
    errors->setName("scopeNumber");
    errors->addError("scopeNumber not found");
  }

  std::string in_variableName;
  if (message.HasMember("variableName") && message["variableName"].IsString()) {
    in_variableName = message["variableName"].GetString();
  } else {
    errors->setName("variableName");
    errors->addError("variableName not found");
  }

  errors->setName("newValue");
  std::unique_ptr<CallArgument> in_newValue;
  if (message.HasMember("newValue") && message["newValue"].IsObject()) {
    rapidjson::Value _newValue = message["newValue"].GetObject();
    in_newValue = CallArgument::fromValue(&_newValue, errors);
  } else {
    errors->setName("newValue");
    errors->addError("newValue not found");
  }

  std::string in_callFrameId;
  if (message.HasMember("callFrameId") && message["callFrameId"].IsString()) {
    in_callFrameId = message["callFrameId"].GetString();
  } else {
    errors->setName("callFrameId");
    errors->addError("callFrameId not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response =
    m_backend->setVariableValue(in_scopeNumber, in_variableName, std::move(in_newValue), in_callFrameId);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::stepInto(uint64_t callId, const std::string &method, JSONObject message,
                                   ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  Maybe<bool> in_breakOnAsyncCall;
  if (message.HasMember("breakOnAsyncCall")) {
    if (message["breakOnAsyncCall"].IsBool()) {
      in_breakOnAsyncCall = message["breakOnAsyncCall"].GetBool();
    } else {
      errors->setName("breakOnAsyncCall");
      errors->addError("breakOnAsyncCall should be bool");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->stepInto(std::move(in_breakOnAsyncCall));
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::stepOut(uint64_t callId, const std::string &method, JSONObject message,
                                  ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->stepOut();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void DebugDispatcherImpl::stepOver(uint64_t callId, const std::string &method, JSONObject message,
                                   ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->stepOver();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

} // namespace debugger
} // namespace kraken
