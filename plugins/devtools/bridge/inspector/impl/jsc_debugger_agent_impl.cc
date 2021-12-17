/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/impl/jsc_debugger_agent_impl.h"
#include "inspector/inspector_session.h"
#include "inspector/protocol/location.h"
#include "inspector/protocol/maybe.h"

#include <wtf/JSONValues.h>

namespace kraken::debugger {
const char *JSCDebuggerAgentImpl::backtraceObjectGroup = "backtrace";

// Objects created and retained by evaluating breakpoint actions are put into object groups
// according to the breakpoint action identifier assigned by the frontend. A breakpoint may
// have several object groups, and objects from several backend breakpoint action instances may
// create objects in the same group.
static String objectGroupForBreakpointAction(const Inspector::ScriptBreakpointAction &action) {
  static NeverDestroyed<String> objectGroup(ASCIILiteral::fromLiteralUnsafe("breakpoint-action-"));
  return makeString(objectGroup.get(), String::number(action.identifier));
}

JSCDebuggerAgentImpl::JSCDebuggerAgentImpl(debugger::InspectorSession *session, debugger::AgentContext &context)
  : m_session(session),
    m_frontend(context.channel), m_debugger(context.debugger),
    m_injectedScriptManager(context.injectedScriptManager), m_continueToLocationBreakpointID(JSC::noBreakpointID)
{
  clearBreakDetails();
}

JSCDebuggerAgentImpl::~JSCDebuggerAgentImpl() {}

//////////////////////Inspector::ScriptDebugListener///////////////////////////////

static bool isWebKitInjectedScript(const String &sourceURL) {
  return sourceURL.startsWith("__InjectedScript_") && sourceURL.endsWith(".js");
}

static bool matches(const String &url, const String &pattern, bool isRegex) {
  if (isRegex) {
    JSC::Yarr::RegularExpression regex(pattern, JSC::Yarr::TextCaseSensitive);
    return regex.match(url) != -1;
  }
  return url == pattern;
}

static Ref<JSON::Object> buildObjectForBreakpointCookie(const String &url, int lineNumber,
                                                                      int columnNumber, const String &condition,
                                                                      RefPtr<JSON::Array> &actions, bool isRegex,
                                                                      bool autoContinue, unsigned ignoreCount) {
  Ref<JSON::Object> breakpointObject = JSON::Object::create();
  breakpointObject->setString("url"_s, url);
  breakpointObject->setInteger("lineNumber"_s, lineNumber);
  breakpointObject->setInteger("columnNumber"_s, columnNumber);
  breakpointObject->setString("condition"_s, condition);
  breakpointObject->setBoolean("isRegex"_s, isRegex);
  breakpointObject->setBoolean("autoContinue"_s, autoContinue);
  breakpointObject->setInteger("ignoreCount"_s, ignoreCount);

  if (actions) breakpointObject->setArray("actions"_s, actions);

  return breakpointObject;
}

void JSCDebuggerAgentImpl::didParseSource(JSC::SourceID sourceID,
                                          const Inspector::ScriptDebugListener::Script &script) {
  String scriptIDStr = String::number(sourceID);
  bool hasSourceURL = !script.sourceURL.isEmpty();
  String sourceURL = script.sourceURL;
  String sourceMappingURL = sourceMapURLForScript(script);

  const bool isModule = script.sourceProvider->sourceType() == JSC::SourceProviderSourceType::Module;
  const bool *isContentScript = script.isContentScript ? &script.isContentScript : nullptr;
  String *sourceURLParam = hasSourceURL ? &sourceURL : nullptr;
  String *sourceMapURLParam = sourceMappingURL.isEmpty() ? nullptr : &sourceMappingURL;

  int executionContextId = 1;

  m_frontend.scriptParsed(scriptIDStr.utf8().data(), script.url.utf8().data(), script.startLine, script.startColumn,
                          script.endLine, script.endColumn, executionContextId,
                          script.sourceProvider ? std::to_string(script.sourceProvider->hash()) : "unknown",
                          kraken::debugger::Maybe<rapidjson::Value>() /*executionContextAuxData*/,
                          kraken::debugger::Maybe<bool>() /*isLiveEdit*/,
                          sourceMapURLParam == nullptr
                            ? kraken::debugger::Maybe<std::string>()
                            : kraken::debugger::Maybe<std::string>((*sourceMapURLParam).utf8().data()) /*sourceMapURL*/,
                          kraken::debugger::Maybe<bool>(hasSourceURL), kraken::debugger::Maybe<bool>(isModule),
                          kraken::debugger::Maybe<int>(script.source.length()) /*length*/,
                          kraken::debugger::Maybe<kraken::debugger::StackTrace>() /*stackTrace*/
  );

  m_scripts.set(sourceID, script);

  if (hasSourceURL && isWebKitInjectedScript(sourceURL)) m_debugger->addToBlacklist(sourceID);

  String scriptURLForBreakpoints = hasSourceURL ? script.sourceURL : script.url;
  if (scriptURLForBreakpoints.isEmpty()) return;

  for (auto &entry : m_javaScriptBreakpoints) {
    RefPtr<JSON::Object> breakpointObject = entry.value;

    bool isRegex;
    String url;
    breakpointObject->getBoolean(ASCIILiteral::fromLiteralUnsafe("isRegex"), isRegex);
    breakpointObject->getString(ASCIILiteral::fromLiteralUnsafe("url"), url);
    if (!matches(scriptURLForBreakpoints, url, isRegex)) continue;

    Inspector::ScriptBreakpoint scriptBreakpoint;
    breakpointObject->getInteger(ASCIILiteral::fromLiteralUnsafe("lineNumber"), scriptBreakpoint.lineNumber);
    breakpointObject->getInteger(ASCIILiteral::fromLiteralUnsafe("columnNumber"), scriptBreakpoint.columnNumber);
    breakpointObject->getString(ASCIILiteral::fromLiteralUnsafe("condition"), scriptBreakpoint.condition);
    breakpointObject->getBoolean(ASCIILiteral::fromLiteralUnsafe("autoContinue"), scriptBreakpoint.autoContinue);
    breakpointObject->getInteger(ASCIILiteral::fromLiteralUnsafe("ignoreCount"), scriptBreakpoint.ignoreCount);
    Inspector::ErrorString errorString;
    RefPtr<JSON::Array> actions;
    breakpointObject->getArray(ASCIILiteral::fromLiteralUnsafe("actions"), actions);
    if (!breakpointActionsFromProtocol(errorString, actions, &scriptBreakpoint.actions)) {
      ASSERT_NOT_REACHED();
      continue;
    }

    JSC::Breakpoint breakpoint(sourceID, scriptBreakpoint.lineNumber, scriptBreakpoint.columnNumber,
                               scriptBreakpoint.condition, scriptBreakpoint.autoContinue, scriptBreakpoint.ignoreCount);
    resolveBreakpoint(script, breakpoint);
    if (!breakpoint.resolved) continue;

    bool existing;
    setBreakpoint(breakpoint, existing);
    if (existing) continue;

    String breakpointIdentifier = entry.key;
    didSetBreakpoint(breakpoint, breakpointIdentifier, scriptBreakpoint);

    auto location = Location::create()
                      .setScriptId(String::number(breakpoint.sourceID).utf8().data())
                      .setLineNumber(breakpoint.line)
                      .setColumnNumber(breakpoint.column)
                      .build();

    m_frontend.breakpointResolved(breakpointIdentifier.utf8().data(), std::move(location));
  }
}

void JSCDebuggerAgentImpl::failedToParseSource(const WTF::String &url, const WTF::String &data, int firstLine,
                                               int errorLine, const WTF::String &errorMessage) {
  KRAKEN_LOG(ERROR) << "failed to parse source." << errorMessage.utf8().data();
  m_frontend.scriptFailedToParse(url.utf8().data() /*scriptId*/, url.utf8().data() /*url*/, firstLine /*startLine*/,
                                 0 /*startColumn*/, errorLine /*endLine*/, 0 /*endColumn*/, 1 /*executionContextId*/,
                                 "unknown" /*hash*/
  );
}

bool JSCDebuggerAgentImpl::convertCallFrames(
  const std::string &in_callframes_str,
  std::unique_ptr<std::vector<std::unique_ptr<kraken::debugger::CallFrame>>> *out_callframes) {

  rapidjson::Document call_frames_obj;
  call_frames_obj.Parse(in_callframes_str.c_str());
  if (call_frames_obj.HasParseError() || !call_frames_obj.IsArray()) {
    KRAKEN_LOG(ERROR) << "callframes parsed error...";
    return false;
  }
  auto array = call_frames_obj.GetArray();
  convertCallFrames(&array, call_frames_obj.GetAllocator(), out_callframes);

  return true;
}

bool JSCDebuggerAgentImpl::convertCallFrames(
  rapidjson::Value::Array *in_callframes, rapidjson::Document::AllocatorType &in_allocator,
  std::unique_ptr<std::vector<std::unique_ptr<kraken::debugger::CallFrame>>> *out_callframes) {
  *out_callframes = std::make_unique<std::vector<std::unique_ptr<kraken::debugger::CallFrame>>>();
  for (auto &callframe : *in_callframes) {
    if (callframe.IsObject()) {
      if (callframe.HasMember("location") && callframe.HasMember("functionName")) {
        if (callframe["functionName"].GetStringLength() == 0) continue;
        WTF::String scriptId = callframe["location"]["scriptId"].GetString();
        auto iterator = m_scripts.find(scriptId.toIntPtr());
        if (iterator != m_scripts.end()) {
          auto script = iterator->value;
          WTF::String url = !script.sourceURL.isEmpty() ? script.sourceURL : script.url;
          callframe.AddMember("url", std::string(url.utf8().data()), in_allocator);
        }
      } else {
        callframe.AddMember("url", "(gart)", in_allocator);
      }

      if (callframe.HasMember("scopeChain") && callframe["scopeChain"].IsArray()) {
        for (auto &scope : callframe["scopeChain"].GetArray()) {
          // location -> startLocation
          auto loc_iterator = scope.FindMember("location");
          if (loc_iterator != scope.MemberEnd()) {
            loc_iterator->name.SetString("startLocation", in_allocator);
          }

          // nestedLexical -> local
          // globalLexicalEnvironment -> block
          auto type_iterator = scope.FindMember("type");
          if (type_iterator != scope.MemberEnd()) {
            const char *type = type_iterator->value.GetString();
            if (std::strcmp(type, "nestedLexical") == 0) {
              type_iterator->value.SetString("local", in_allocator);
            } else if (std::strcmp(type, "globalLexicalEnvironment") == 0) {
              type_iterator->value.SetString("block", in_allocator);
            }
          }
        }
      }

      ErrorSupport err;
      auto item = debugger::CallFrame::fromValue(&callframe, &err);
      if (err.hasErrors()) {
        KRAKEN_LOG(ERROR) << "callframe transformed error," << err.errors();
        continue;
      }
      (*out_callframes)->push_back(std::move(item));
    } else {
      return false;
    }
  }
  return true;
}

bool JSCDebuggerAgentImpl::convertStackTrace(const std::string &in_stackTrace_str,
                                             std::unique_ptr<debugger::StackTrace> *out_trace) {

  rapidjson::Document stackTrace_obj;
  stackTrace_obj.Parse(in_stackTrace_str.c_str());
  if (stackTrace_obj.HasParseError() || !stackTrace_obj.IsObject()) {
    KRAKEN_LOG(ERROR) << "stackTrace parsed error...";
    return false;
  }

  if (stackTrace_obj.HasMember("callFrames")) {
    rapidjson::Value::Array call_frames = stackTrace_obj["callFrames"].GetArray();
    std::unique_ptr<std::vector<std::unique_ptr<CallFrame>>> callFrames;
    convertCallFrames(&call_frames, stackTrace_obj.GetAllocator(), &callFrames);

    *out_trace = debugger::StackTrace::create().setCallFrames(std::move(callFrames)).build();
  } else {
    return false;
  }

  return true;
}

void JSCDebuggerAgentImpl::didPause(JSC::ExecState &scriptState, JSC::JSValue callFrames,
                                    JSC::JSValue exceptionOrCaughtValue) {
  m_pausedScriptState = &scriptState;
  m_currentCallStack = {scriptState.vm(), callFrames};

  Inspector::InjectedScript injectedScript = m_injectedScriptManager->injectedScriptFor(&scriptState);

  // If a high level pause pause reason is not already set, try to infer a reason from the debugger.
  JSC::BreakpointID debuggerBreakpointId = JSC::noBreakpointID;
  if (m_breakReason == Inspector::DebuggerFrontendDispatcher::Reason::Other) {
    switch (m_debugger->reasonForPause()) {
    case JSC::Debugger::PausedForBreakpoint: {
      debuggerBreakpointId = m_debugger->pausingBreakpointID();
      if (debuggerBreakpointId != m_continueToLocationBreakpointID) {
        m_breakReason = Inspector::DebuggerFrontendDispatcher::Reason::Breakpoint;
        m_breakAuxData = buildBreakpointPauseReason(debuggerBreakpointId);
      }
      break;
    }
    case JSC::Debugger::PausedForDebuggerStatement:
      m_breakReason = Inspector::DebuggerFrontendDispatcher::Reason::DebuggerStatement;
      m_breakAuxData = nullptr;
      break;
    case JSC::Debugger::PausedForException:
      m_breakReason = Inspector::DebuggerFrontendDispatcher::Reason::Exception;
      m_breakAuxData = buildExceptionPauseReason(exceptionOrCaughtValue, injectedScript);
      break;
    case JSC::Debugger::PausedAtStatement:
    case JSC::Debugger::PausedAtExpression:
    case JSC::Debugger::PausedBeforeReturn:
    case JSC::Debugger::PausedAtEndOfProgram:
      // Pause was just stepping. Nothing to report.
      break;
    case JSC::Debugger::NotPaused:
      ASSERT_NOT_REACHED();
      break;
    }
  }

  // Set $exception to the exception or caught value.
  if (exceptionOrCaughtValue && !injectedScript.hasNoValue()) {
    injectedScript.setExceptionValue(exceptionOrCaughtValue);
    m_hasExceptionValue = true;
  }

  m_conditionToDispatchResumed = ShouldDispatchResumed::No;
  m_enablePauseWhenIdle = false;

  RefPtr<Inspector::Protocol::Console::StackTrace> asyncStackTrace;
  if (m_currentAsyncCallIdentifier) {
    auto it = m_pendingAsyncCalls.find(m_currentAsyncCallIdentifier.value());
    if (it != m_pendingAsyncCalls.end()) asyncStackTrace = it->value->buildInspectorObject();
  }

  std::string reason = Inspector::Protocol::InspectorHelpers::getEnumConstantValue(m_breakReason).utf8().data();

  auto _callFrames = currentCallFrames(injectedScript);
  std::string callframes_str = _callFrames->toJSONString().utf8().data(); // jsc call frames
  std::unique_ptr<std::vector<std::unique_ptr<kraken::debugger::CallFrame>>> callFrames_v8;
  if (!convertCallFrames(callframes_str, &callFrames_v8)) {
    return;
  }

  std::unique_ptr<rapidjson::Value> data_v8 = nullptr;
  if (m_breakAuxData) {
    std::string aux_str = m_breakAuxData->toJSONString().utf8().data();

    rapidjson::Document aux_obj;
    aux_obj.Parse(aux_str.c_str());
    if (aux_obj.HasParseError() || !aux_obj.IsObject()) {
      KRAKEN_LOG(ERROR) << "aux data parsed error...";
      return;
    }
    data_v8 = std::make_unique<rapidjson::Value>(rapidjson::kObjectType);
    data_v8->CopyFrom(aux_obj, m_doc.GetAllocator());
  }

  std::unique_ptr<std::vector<std::string>> hitBreakpoints_v8 = nullptr;
  if (debuggerBreakpointId != JSC::noBreakpointID) {
    hitBreakpoints_v8 = std::make_unique<std::vector<std::string>>();
    hitBreakpoints_v8->push_back(WTF::String::number(debuggerBreakpointId).utf8().data());
  }

  std::unique_ptr<debugger::StackTrace> asyncStackTrace_v8 = nullptr;
  if (asyncStackTrace) {
    convertStackTrace(asyncStackTrace->toJSONString().utf8().data(), &asyncStackTrace_v8);
  }

  std::unique_ptr<debugger::StackTraceId> asyncStackTraceId_v8 = nullptr;     // TODO
  std::unique_ptr<debugger::StackTraceId> asyncCallStackTraceId_v8 = nullptr; // TODO

  m_frontend.paused(std::move(callFrames_v8), reason, std::move(data_v8), std::move(hitBreakpoints_v8),
                    std::move(asyncStackTrace_v8), std::move(asyncStackTraceId_v8),
                    std::move(asyncCallStackTraceId_v8));

  m_javaScriptPauseScheduled = false;

  if (m_continueToLocationBreakpointID != JSC::noBreakpointID) {
    m_debugger->removeBreakpoint(m_continueToLocationBreakpointID);
    m_continueToLocationBreakpointID = JSC::noBreakpointID;
  }

  RefPtr<Stopwatch> stopwatch = m_injectedScriptManager->inspectorEnvironment().executionStopwatch();
  if (stopwatch && stopwatch->isActive()) {
    stopwatch->stop();
    m_didPauseStopwatch = true;
  }
}

void JSCDebuggerAgentImpl::didContinue() {
  if (m_didPauseStopwatch) {
    m_didPauseStopwatch = false;
    m_injectedScriptManager->inspectorEnvironment().executionStopwatch()->start();
  }

  m_pausedScriptState = nullptr;
  m_currentCallStack = {};
  m_injectedScriptManager->releaseObjectGroup(JSCDebuggerAgentImpl::backtraceObjectGroup);
  clearBreakDetails();
  clearExceptionValue();

  if (m_conditionToDispatchResumed == ShouldDispatchResumed::WhenContinued) {
    m_frontend.resumed();
  }
}

void JSCDebuggerAgentImpl::breakpointActionLog(JSC::ExecState &state, const WTF::String &message) {
  KRAKEN_LOG(VERBOSE) << "breakpointActionLog: " << message.utf8().data();
}

void JSCDebuggerAgentImpl::breakpointActionSound(int breakpointActionIdentifier) {
}

void JSCDebuggerAgentImpl::breakpointActionProbe(JSC::ExecState &scriptState,
                                                 const Inspector::ScriptBreakpointAction &action, unsigned batchId,
                                                 unsigned sampleId, JSC::JSValue sample) {
  Inspector::InjectedScript injectedScript = m_injectedScriptManager->injectedScriptFor(&scriptState);
  auto payload = injectedScript.wrapObject(sample, objectGroupForBreakpointAction(action), true);
  auto result = Inspector::Protocol::Debugger::ProbeSample::create()
                  .setProbeId(action.identifier)
                  .setBatchId(batchId)
                  .setSampleId(sampleId)
                  .setTimestamp(m_injectedScriptManager->inspectorEnvironment().executionStopwatch()->elapsedTime().milliseconds())
                  .setPayload(WTFMove(payload))
                  .release();
}

/////////////////////Backend Interface////////////////////////////////

static bool parseLocation(Inspector::ErrorString &errorString, std::unique_ptr<Location> in_location,
                          JSC::SourceID &sourceID, unsigned &lineNumber, unsigned &columnNumber) {
  if (in_location == nullptr) {
    errorString = ASCIILiteral::fromLiteralUnsafe("location not exists.");
    return false;
  }
  String scriptIDStr = in_location->getScriptId().c_str();
  lineNumber = static_cast<unsigned>(in_location->getLineNumber());
  sourceID = scriptIDStr.toIntPtr();
  columnNumber = 0;
  if (in_location->hasColumnNumber()) {
    columnNumber = static_cast<unsigned>(in_location->getColumnNumber(0));
  }
  return true;
}

DispatchResponse JSCDebuggerAgentImpl::continueToLocation(std::unique_ptr<Location> in_location,
                                                          Maybe<std::string> in_targetCallFrames) {
  Inspector::ErrorString errorString;
  if (!assertPaused(errorString)) return DispatchResponse::Error(errorString.utf8().data());

  if (m_continueToLocationBreakpointID != JSC::noBreakpointID) {
    m_debugger->removeBreakpoint(m_continueToLocationBreakpointID);
    m_continueToLocationBreakpointID = JSC::noBreakpointID;
  }

  JSC::SourceID sourceID;
  unsigned lineNumber;
  unsigned columnNumber;

  if (!parseLocation(errorString, std::move(in_location), sourceID, lineNumber, columnNumber))
    return DispatchResponse::Error(errorString.utf8().data());

  auto scriptIterator = m_scripts.find(sourceID);
  if (scriptIterator == m_scripts.end()) {
    m_debugger->continueProgram();
    m_frontend.resumed();
    errorString = ASCIILiteral::fromLiteralUnsafe("No script for id: ") + String::number(sourceID);
    return DispatchResponse::Error(errorString.utf8().data());
  }

  String condition;
  bool autoContinue = false;
  unsigned ignoreCount = 0;
  JSC::Breakpoint breakpoint(sourceID, lineNumber, columnNumber, condition, autoContinue, ignoreCount);
  Script &script = scriptIterator->value;
  resolveBreakpoint(script, breakpoint);
  if (!breakpoint.resolved) {
    m_debugger->continueProgram();
    m_frontend.resumed();
    errorString = ASCIILiteral::fromLiteralUnsafe("Could not resolve breakpoint");
    return DispatchResponse::Error(errorString.utf8().data());
  }

  bool existing;
  setBreakpoint(breakpoint, existing);
  if (existing) {
    // There is an existing breakpoint at this location. Instead of
    // acting like a series of steps, just resume and we will either
    // hit this new breakpoint or not.
    m_debugger->continueProgram();
    m_frontend.resumed();
    return DispatchResponse::OK();
  }

  m_continueToLocationBreakpointID = breakpoint.id;

  // Treat this as a series of steps until reaching the new breakpoint.
  // So don't issue a resumed event unless we exit the VM without pausing.
  willStepAndMayBecomeIdle();
  m_debugger->continueProgram();

  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::disable() {
  disable(false);

  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::enable(Maybe<double> in_maxScriptsCacheSize, std::string *out_debuggerId) {
  enable();

  *out_debuggerId = "(KRAKEN_debugger_id_" + std::to_string(m_debugger_id++) + ")";

  return DispatchResponse::OK();
}

bool JSCDebuggerAgentImpl::convertRemoteObject(const std::string &in_result, std::unique_ptr<RemoteObject> *out_result,
                                               Inspector::ErrorString &error) {
  rapidjson::Document in_result_doc;
  in_result_doc.Parse(in_result.c_str());
  if (in_result_doc.HasParseError() || !in_result_doc.IsObject()) {
    KRAKEN_LOG(ERROR) << "remoteObject parsed error...";
    return false;
  }
  auto copy = rapidjson::Value(in_result_doc, m_doc.GetAllocator());
  ErrorSupport errorSupport;
  *out_result = debugger::RemoteObject::fromValue(&copy, &errorSupport);
  if (errorSupport.hasErrors()) {
    error = errorSupport.errors().c_str();
    return false;
  }
  return true;
}

DispatchResponse JSCDebuggerAgentImpl::evaluateOnCallFrame(
  const std::string &in_callFrameId, const std::string &in_expression, Maybe<std::string> in_objectGroup,
  Maybe<bool> in_includeCommandLineAPI, Maybe<bool> in_silent, Maybe<bool> in_returnByValue,
  Maybe<bool> in_generatePreview, Maybe<bool> in_throwOnSideEffect /*不支持*/, Maybe<double> in_timeout /*不支持*/,
  std::unique_ptr<RemoteObject> *out_result, Maybe<ExceptionDetails> *out_exceptionDetails) {

  Inspector::ErrorString errorString;
  if (!m_currentCallStack) {
    errorString = ASCIILiteral::fromLiteralUnsafe("Not paused");
    return DispatchResponse::Error(errorString.utf8().data());
  }

  Inspector::InjectedScript injectedScript = m_injectedScriptManager->injectedScriptForObjectId(in_callFrameId.c_str());
  if (injectedScript.hasNoValue()) {
    errorString = ASCIILiteral::fromLiteralUnsafe("Could not find InjectedScript for callFrameId");
    return DispatchResponse::Error(errorString.utf8().data());
  }

  JSC::Debugger::PauseOnExceptionsState previousPauseOnExceptionsState = m_debugger->pauseOnExceptionsState();
  if (in_silent.fromMaybe(false)) {
    if (previousPauseOnExceptionsState != JSC::Debugger::DontPauseOnExceptions)
      m_debugger->setPauseOnExceptionsState(JSC::Debugger::DontPauseOnExceptions);
  }

  bool saveResult = false;                              // TODO V8不支持
  WTF::Optional<bool> wasThrown;       // TODO V8不支持
  WTF::Optional<int> savedResultIndex; // TODO V8不支持

  RefPtr<Inspector::Protocol::Runtime::RemoteObject> result;
  injectedScript.evaluateOnCallFrame(errorString, m_currentCallStack.get(), in_callFrameId.c_str(), in_expression.c_str(),
                                     in_objectGroup.fromMaybe("").c_str(), in_includeCommandLineAPI.fromMaybe(false),
                                     in_returnByValue.fromMaybe(false), in_generatePreview.fromMaybe(false), saveResult,
                                     result, wasThrown, savedResultIndex);
  std::string raw_result = result->toJSONString().utf8().data();
  if (!convertRemoteObject(raw_result, out_result, errorString)) {
    return DispatchResponse::Error(errorString.utf8().data());
  }

  if (in_silent.fromMaybe(false)) {
    if (m_debugger->pauseOnExceptionsState() != previousPauseOnExceptionsState)
      m_debugger->setPauseOnExceptionsState(previousPauseOnExceptionsState);
  }

  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::getPossibleBreakpoints(
  std::unique_ptr<Location> in_start, Maybe<Location> in_end, Maybe<bool> in_restrictToFunction,
  std::unique_ptr<std::vector<std::unique_ptr<BreakLocation>>> *out_locations) {

  std::string scriptId = in_start->getScriptId();
  if (in_start->getLineNumber() < 0 || in_start->getColumnNumber(0) < 0) {
    return DispatchResponse::Error("start.lineNumber and start.columnNumber should be >= 0");
  }

  if (in_end.isJust()) {
    if (in_end.fromJust()->getScriptId() != scriptId)
      return DispatchResponse::Error("Locations should contain the same scriptId");
    int line = in_end.fromJust()->getLineNumber();
    int column = in_end.fromJust()->getColumnNumber(0);
    if (line < 0 || column < 0) return DispatchResponse::Error("end.lineNumber and end.columnNumber should be >= 0");
  }

  JSC::SourceID sourceID = static_cast<JSC::SourceID>(std::stoi(scriptId));

  auto it = m_scripts.find(sourceID);
  if (it == m_scripts.end()) {
    return DispatchResponse::Error("No script for id: " + scriptId);
  }

  *out_locations = std::make_unique<std::vector<std::unique_ptr<BreakLocation>>>();

  for (auto &entry : m_javaScriptBreakpoints) {
    RefPtr<JSON::Object> breakpointObject = entry.value;

    Inspector::ScriptBreakpoint scriptBreakpoint;
    breakpointObject->getInteger(ASCIILiteral::fromLiteralUnsafe("lineNumber"), scriptBreakpoint.lineNumber);

    breakpointObject->getInteger(ASCIILiteral::fromLiteralUnsafe("columnNumber"), scriptBreakpoint.columnNumber);

    if (scriptBreakpoint.lineNumber < in_start->getLineNumber()) {
      continue;
    }
    if (in_start->hasColumnNumber() && scriptBreakpoint.columnNumber < in_start->getColumnNumber(0)) {
      continue;
    }

    if (in_end.isJust()) {
      if (scriptBreakpoint.lineNumber > in_end.fromJust()->getLineNumber()) {
        continue;
      }
      if (in_end.fromJust()->hasColumnNumber() &&
          scriptBreakpoint.columnNumber > in_end.fromJust()->getColumnNumber(0)) {
        continue;
      }
    }

    auto location = BreakLocation::create()
                      .setScriptId(scriptId)
                      .setLineNumber(scriptBreakpoint.lineNumber)
                      .setColumnNumber(scriptBreakpoint.columnNumber)
                      .build();

    (*out_locations)->push_back(std::move(location));
  }

  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::getScriptSource(const std::string &in_scriptId, std::string *out_scriptSource) {
  JSC::SourceID sourceID = static_cast<JSC::SourceID>(std::stoi(in_scriptId));
  ScriptsMap::iterator it = m_scripts.find(sourceID);
  if (it != m_scripts.end()) {
    *out_scriptSource = it->value.source.utf8().data();
  } else {
    return DispatchResponse::Error("No script for id: " + in_scriptId);
  }
  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::getStackTrace(std::unique_ptr<StackTraceId> in_stackTraceId,
                                                     std::unique_ptr<StackTrace> *out_stackTrace) {
  return DispatchResponse::Error("not implement");
}

DispatchResponse JSCDebuggerAgentImpl::pause() {
  schedulePauseOnNextStatement(Inspector::DebuggerFrontendDispatcher::Reason::PauseOnNextStatement, nullptr);
  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::pauseOnAsyncCall(std::unique_ptr<StackTraceId> in_parentStackTraceId) {
  return DispatchResponse::Error("not implement");
}

DispatchResponse JSCDebuggerAgentImpl::removeBreakpoint(const std::string &in_breakpointId) {
  WTF::String breakpointIdentifier = in_breakpointId.c_str();
  m_javaScriptBreakpoints.remove(breakpointIdentifier);

  for (JSC::BreakpointID breakpointID : m_breakpointIdentifierToDebugServerBreakpointIDs.take(breakpointIdentifier)) {
    m_debuggerBreakpointIdentifierToInspectorBreakpointIdentifier.remove(breakpointID);

    const Inspector::BreakpointActions &breakpointActions = m_debugger->getActionsForBreakpoint(breakpointID);
    for (auto &action : breakpointActions)
      m_injectedScriptManager->releaseObjectGroup(objectGroupForBreakpointAction(action));

    JSC::JSLockHolder locker(m_debugger->vm());
    m_debugger->removeBreakpointActions(breakpointID);
    m_debugger->removeBreakpoint(breakpointID);
  }

  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::restartFrame(const std::string &in_callFrameId,
                                                    std::unique_ptr<std::vector<CallFrame>> *out_callFrames,
                                                    Maybe<StackTrace> *out_asyncStackTrace,
                                                    Maybe<StackTraceId> *out_asyncStackTraceId) {
  return DispatchResponse::Error("not implement");
}

DispatchResponse JSCDebuggerAgentImpl::resume() {
  Inspector::ErrorString errorString;
  if (!m_pausedScriptState && !m_javaScriptPauseScheduled) {
    errorString = ASCIILiteral::fromLiteralUnsafe("Was not paused or waiting to pause");
    return DispatchResponse::Error(errorString.utf8().data());
  }

  cancelPauseOnNextStatement();
  m_debugger->continueProgram();
  m_conditionToDispatchResumed = ShouldDispatchResumed::WhenContinued;
  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::searchInContent(const std::string &in_scriptId, const std::string &in_query,
                                                       Maybe<bool> in_caseSensitive, Maybe<bool> in_isRegex,
                                                       std::unique_ptr<std::vector<SearchMatch>> *out_result) {
  Inspector::ErrorString error;
  JSC::SourceID sourceID = WTF::String(in_scriptId.c_str()).toIntPtr();
  auto it = m_scripts.find(sourceID);
  if (it == m_scripts.end()) {
    error = ASCIILiteral::fromLiteralUnsafe("No script for id: ") + WTF::String(in_scriptId.c_str());
    return DispatchResponse::Error(error.utf8().data());
  }

  auto result = Inspector::ContentSearchUtilities::searchInTextByLines(
    it->value.source, in_query.c_str(), in_caseSensitive.fromMaybe(false), in_isRegex.fromMaybe(false));

  const char *result_str = result->toJSONString().utf8().data();

  // TODO 转换
  *out_result = std::make_unique<std::vector<SearchMatch>>();

  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::setAsyncCallStackDepth(int in_maxDepth) {
  if (m_asyncStackTraceDepth == in_maxDepth) return DispatchResponse::OK();

  if (in_maxDepth < 0) {
    return DispatchResponse::Error("depth must be a positive number.");
  }
  m_asyncStackTraceDepth = in_maxDepth;
  if (!m_asyncStackTraceDepth) {
    clearAsyncStackTraceData();
  }

  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::setBlackboxPatterns(std::unique_ptr<std::vector<std::string>> in_patterns) {
  return DispatchResponse::Error("not implement");
}

DispatchResponse
JSCDebuggerAgentImpl::setBlackboxedRanges(const std::string &in_scriptId,
                                          std::unique_ptr<std::vector<std::unique_ptr<ScriptPosition>>> in_positions) {
  return DispatchResponse::Error("not implement");
}

DispatchResponse JSCDebuggerAgentImpl::setBreakpoint(std::unique_ptr<Location> in_location,
                                                     Maybe<std::string> in_condition, std::string *out_breakpointId,
                                                     std::unique_ptr<Location> *out_actualLocation) {

  Inspector::ErrorString errorString;
  JSC::SourceID sourceID;
  unsigned lineNumber;
  unsigned columnNumber;
  if (!parseLocation(errorString, std::move(in_location), sourceID, lineNumber, columnNumber))
    return DispatchResponse::Error(errorString.utf8().data());

  String condition = in_condition.fromMaybe("").c_str();
  bool autoContinue = false;   // TODO 不支持
  unsigned ignoreCount = 0;    // TODO 不支持
  RefPtr<JSON::Array> actions; // TODO 不支持

  Inspector::BreakpointActions breakpointActions;
  if (!breakpointActionsFromProtocol(errorString, actions, &breakpointActions))
    return DispatchResponse::Error(errorString.utf8().data());

  auto scriptIterator = m_scripts.find(sourceID);
  if (scriptIterator == m_scripts.end()) {
    errorString = ASCIILiteral::fromLiteralUnsafe("No script for id: ") + String::number(sourceID);
    return DispatchResponse::Error(errorString.utf8().data());
  }

  Script &script = scriptIterator->value;
  JSC::Breakpoint breakpoint(sourceID, lineNumber, columnNumber, condition, autoContinue, ignoreCount);
  resolveBreakpoint(script, breakpoint);
  if (!breakpoint.resolved) {
    errorString = ASCIILiteral::fromLiteralUnsafe("Could not resolve breakpoint");
    return DispatchResponse::Error(errorString.utf8().data());
  }

  bool existing;
  setBreakpoint(breakpoint, existing);
  if (existing) {
    errorString = ASCIILiteral::fromLiteralUnsafe("Breakpoint at specified location already exists");
    return DispatchResponse::Error(errorString.utf8().data());
  }

  String breakpointIdentifier =
    String::number(sourceID) + ':' + String::number(breakpoint.line) + ':' + String::number(breakpoint.column);
  Inspector::ScriptBreakpoint scriptBreakpoint(breakpoint.line, breakpoint.column, condition, breakpointActions,
                                               autoContinue, ignoreCount);
  didSetBreakpoint(breakpoint, breakpointIdentifier, scriptBreakpoint);

  *out_actualLocation = Location::create()
                          .setScriptId(String::number(breakpoint.sourceID).utf8().data())
                          .setLineNumber(breakpoint.line)
                          .setColumnNumber(breakpoint.column)
                          .build();

  *out_breakpointId = breakpointIdentifier.utf8().data();
  return DispatchResponse::OK();
}

DispatchResponse
JSCDebuggerAgentImpl::setBreakpointByUrl(int in_lineNumber, Maybe<std::string> in_url, Maybe<std::string> in_urlRegex,
                                         Maybe<std::string> in_scriptHash, Maybe<int> in_columnNumber,
                                         Maybe<std::string> in_condition, std::string *out_breakpointId,
                                         std::unique_ptr<std::vector<std::unique_ptr<Location>>> *out_locations) {
  *out_locations = std::make_unique<std::vector<std::unique_ptr<Location>>>();

  if (!in_url.isJust() && !in_urlRegex.isJust()) {
    return DispatchResponse::Error("Either url or urlRegex must be specified.");
  }

  String url = in_url.isJust() ? in_url.fromJust().c_str() : in_urlRegex.fromJust().c_str();
  int columnNumber = in_columnNumber.isJust() ? in_columnNumber.fromJust() : 0;
  bool isRegex = in_urlRegex.isJust();

  String breakpointIdentifier =
    (isRegex ? "/" + url + "/" : url) + ':' + String::number(in_lineNumber) + ':' + String::number(columnNumber);
  if (m_javaScriptBreakpoints.contains(breakpointIdentifier)) {
    return DispatchResponse::Error("Breakpoint at specified location already exists.");
  }

  String condition = emptyString();
  if (in_condition.isJust()) {
    condition = in_condition.fromJust().c_str();
  }
  bool autoContinue = false;
  unsigned ignoreCount = 0;

  // type: Different kinds of breakpoint actions. ["log", "evaluate", "sound", "probe"]
  // data: Data associated with this breakpoint type
  // id:   A frontend-assigned identifier for this breakpoint action.
  RefPtr<JSON::Array> actions = JSON::Array::create();
  auto inspectorObj = JSON::Object::create();
  inspectorObj->setString("type", "evaluate");
  actions->pushObject(std::move(inspectorObj));

  Inspector::BreakpointActions breakpointActions;
  Inspector::ErrorString errorString;
  if (!breakpointActionsFromProtocol(errorString, actions, &breakpointActions)) {
    return DispatchResponse::Error(errorString.utf8().data());
  }

  m_javaScriptBreakpoints.set(breakpointIdentifier,
                              buildObjectForBreakpointCookie(url, in_lineNumber, columnNumber, condition, actions,
                                                             isRegex, autoContinue, ignoreCount));

  for (auto &entry : m_scripts) {
    Script &script = entry.value;
    String scriptURLForBreakpoints = !script.sourceURL.isEmpty() ? script.sourceURL : script.url;
    if (!matches(scriptURLForBreakpoints, url, isRegex)) continue;

    JSC::SourceID sourceID = entry.key;
    JSC::Breakpoint breakpoint(sourceID, in_lineNumber, columnNumber, condition, autoContinue, ignoreCount);
    resolveBreakpoint(script, breakpoint);
    if (!breakpoint.resolved) continue;

    bool existing;
    setBreakpoint(breakpoint, existing);
    if (existing) continue;

    Inspector::ScriptBreakpoint scriptBreakpoint(breakpoint.line, breakpoint.column, condition, breakpointActions,
                                                 autoContinue, ignoreCount);
    didSetBreakpoint(breakpoint, breakpointIdentifier, scriptBreakpoint);

    (*out_locations)
      ->push_back(Location::create()
                    .setScriptId(String::number(breakpoint.sourceID).utf8().data())
                    .setLineNumber(breakpoint.line)
                    .setColumnNumber(breakpoint.column)
                    .build());
  }

  *out_breakpointId = breakpointIdentifier.utf8().data();

  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::setBreakpointOnFunctionCall(const std::string &in_objectId,
                                                                   Maybe<std::string> in_condition,
                                                                   std::string *out_breakpointId) {
  return DispatchResponse::Error("not implement");
}

DispatchResponse JSCDebuggerAgentImpl::setBreakpointsActive(bool in_active) {
  if (in_active) {
    m_debugger->activateBreakpoints();
  } else {
    m_debugger->deactivateBreakpoints();
  }
  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::setPauseOnExceptions(const std::string &in_state) {
  JSC::Debugger::PauseOnExceptionsState pauseState;
  if (in_state == "none")
    pauseState = JSC::Debugger::DontPauseOnExceptions;
  else if (in_state == "all")
    pauseState = JSC::Debugger::PauseOnAllExceptions;
  else if (in_state == "uncaught")
    pauseState = JSC::Debugger::PauseOnUncaughtExceptions;
  else {
    return DispatchResponse::Error("Unknown pause on exceptions mode: " + in_state);
  }

  m_debugger->setPauseOnExceptionsState(pauseState);
  if (m_debugger->pauseOnExceptionsState() != pauseState) {
    return DispatchResponse::Error("Internal error. Could not change pause on exceptions state");
  }

  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::setReturnValue(std::unique_ptr<CallArgument> in_newValue) {
  return DispatchResponse::Error("not implement");
}

DispatchResponse JSCDebuggerAgentImpl::setScriptSource(
  const std::string &in_scriptId, const std::string &in_scriptSource, Maybe<bool> in_dryRun,
  Maybe<std::vector<CallFrame>> *out_callFrames, Maybe<bool> *out_stackChanged, Maybe<StackTrace> *out_asyncStackTrace,
  Maybe<StackTraceId> *out_asyncStackTraceId, Maybe<ExceptionDetails> *out_exceptionDetails) {
  return DispatchResponse::Error("not implement");
}

DispatchResponse JSCDebuggerAgentImpl::setSkipAllPauses(bool in_skip) {
  if (in_skip) {
    setBreakpointsActive(false);
    setPauseOnExceptions("none");
  } else { // not skip
    setBreakpointsActive(true);
    setPauseOnExceptions("all");
  }
  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::setVariableValue(int in_scopeNumber, const std::string &in_variableName,
                                                        std::unique_ptr<CallArgument> in_newValue,
                                                        const std::string &in_callFrameId) {
  return DispatchResponse::Error("not implement");
}

DispatchResponse JSCDebuggerAgentImpl::stepInto(Maybe<bool> in_breakOnAsyncCall) {
  Inspector::ErrorString errorString;
  if (!assertPaused(errorString)) return DispatchResponse::Error(errorString.utf8().data());

  willStepAndMayBecomeIdle();
  m_debugger->stepIntoStatement();
  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::stepOut() {
  Inspector::ErrorString errorString;
  if (!assertPaused(errorString)) return DispatchResponse::Error(errorString.utf8().data());

  willStepAndMayBecomeIdle();
  m_debugger->stepOutOfFunction();
  return DispatchResponse::OK();
}

DispatchResponse JSCDebuggerAgentImpl::stepOver() {
  Inspector::ErrorString errorString;
  if (!assertPaused(errorString)) return DispatchResponse::Error(errorString.utf8().data());
  ;

  willStepAndMayBecomeIdle();
  m_debugger->stepOverStatement();
  return DispatchResponse::OK();
}

///////////////////// Own Public////////////////////////////////

bool JSCDebuggerAgentImpl::isPaused() const {
  return m_debugger->isPaused();
}

bool JSCDebuggerAgentImpl::breakpointsActive() const {
  return m_debugger->breakpointsActive();
}

void JSCDebuggerAgentImpl::setSuppressAllPauses(bool suppress) {
  m_debugger->setSuppressAllPauses(suppress);
}

static RefPtr<JSON::Object> buildAssertPauseReason(const String &message) {
  auto reason = Inspector::Protocol::Debugger::AssertPauseReason::create().release();
  if (!message.isNull()) reason->setMessage(message);
  return reason->openAccessors();
}

void JSCDebuggerAgentImpl::handleConsoleAssert(const String &message) {
  if (!m_debugger->breakpointsActive()) return;

  if (m_pauseOnAssertionFailures)
    breakProgram(Inspector::DebuggerFrontendDispatcher::Reason::Assert, buildAssertPauseReason(message));
}

void JSCDebuggerAgentImpl::didScheduleAsyncCall(JSC::ExecState *exec, int asyncCallType, int callbackIdentifier,
                                                bool singleShot) {
  if (!m_asyncStackTraceDepth) return;

  if (!m_debugger->breakpointsActive()) return;

  Ref<Inspector::ScriptCallStack> callStack = Inspector::createScriptCallStack(exec, m_asyncStackTraceDepth);
  ASSERT(callStack->size());
  if (!callStack->size()) return;

  RefPtr<Inspector::AsyncStackTrace> parentStackTrace;
  if (m_currentAsyncCallIdentifier) {
    auto it = m_pendingAsyncCalls.find(m_currentAsyncCallIdentifier.value());
    ASSERT(it != m_pendingAsyncCalls.end());
    parentStackTrace = it->value;
  }

  auto identifier = std::make_pair(asyncCallType, callbackIdentifier);
  auto asyncStackTrace = Inspector::AsyncStackTrace::create(WTFMove(callStack), singleShot, WTFMove(parentStackTrace));

  m_pendingAsyncCalls.set(identifier, WTFMove(asyncStackTrace));
}

void JSCDebuggerAgentImpl::didCancelAsyncCall(int asyncCallType, int callbackIdentifier) {
  if (!m_asyncStackTraceDepth) return;

  auto identifier = std::make_pair(asyncCallType, callbackIdentifier);
  auto it = m_pendingAsyncCalls.find(identifier);
  if (it == m_pendingAsyncCalls.end()) return;

  auto &asyncStackTrace = it->value;
  asyncStackTrace->didCancelAsyncCall();

  if (m_currentAsyncCallIdentifier && m_currentAsyncCallIdentifier.value() == identifier) return;

  m_pendingAsyncCalls.remove(identifier);
}

void JSCDebuggerAgentImpl::willDispatchAsyncCall(int asyncCallType, int callbackIdentifier) {
  if (!m_asyncStackTraceDepth) return;

  if (m_currentAsyncCallIdentifier) return;

  // A call can be scheduled before the Inspector is opened, or while async stack
  // traces are disabled. If no call data exists, do nothing.
  auto identifier = std::make_pair(asyncCallType, callbackIdentifier);
  auto it = m_pendingAsyncCalls.find(identifier);
  if (it == m_pendingAsyncCalls.end()) return;

  auto &asyncStackTrace = it->value;
  asyncStackTrace->willDispatchAsyncCall(m_asyncStackTraceDepth);

  m_currentAsyncCallIdentifier = identifier;
}

void JSCDebuggerAgentImpl::didDispatchAsyncCall() {
  if (!m_asyncStackTraceDepth) return;

  if (!m_currentAsyncCallIdentifier) return;

  auto identifier = m_currentAsyncCallIdentifier.value();
  auto it = m_pendingAsyncCalls.find(identifier);
  ASSERT(it != m_pendingAsyncCalls.end());

  auto &asyncStackTrace = it->value;
  asyncStackTrace->didDispatchAsyncCall();

  m_currentAsyncCallIdentifier = WTF::nullopt;

  if (!asyncStackTrace->isPending()) m_pendingAsyncCalls.remove(identifier);
}

void JSCDebuggerAgentImpl::schedulePauseOnNextStatement(Inspector::DebuggerFrontendDispatcher::Reason breakReason,
                                                        RefPtr<JSON::Object> &&data) {
  if (m_javaScriptPauseScheduled) return;

  m_javaScriptPauseScheduled = true;

  m_breakReason = breakReason;
  m_breakAuxData = WTFMove(data);

  JSC::JSLockHolder locker(m_debugger->vm());
  m_debugger->setPauseOnNextStatement(true);
}

void JSCDebuggerAgentImpl::cancelPauseOnNextStatement() {
  if (!m_javaScriptPauseScheduled) return;

  m_javaScriptPauseScheduled = false;

  clearBreakDetails();
  m_debugger->setPauseOnNextStatement(false);
  m_enablePauseWhenIdle = false;
}

void JSCDebuggerAgentImpl::breakProgram(Inspector::DebuggerFrontendDispatcher::Reason breakReason,
                                        RefPtr<JSON::Object> &&data) {
  m_breakReason = breakReason;
  m_breakAuxData = WTFMove(data);
  m_debugger->breakProgram();
}

static RefPtr<JSON::Object> buildCSPViolationPauseReason(const String &directiveText) {
  auto reason = Inspector::Protocol::Debugger::CSPViolationPauseReason::create().setDirective(directiveText).release();
  return reason->openAccessors();
}

void JSCDebuggerAgentImpl::scriptExecutionBlockedByCSP(const String &directiveText) {
  if (m_debugger->pauseOnExceptionsState() != JSC::Debugger::DontPauseOnExceptions)
    breakProgram(Inspector::DebuggerFrontendDispatcher::Reason::CSPViolation,
                 buildCSPViolationPauseReason(directiveText));
}

///////////////////// Own Protected////////////////////////////////

String JSCDebuggerAgentImpl::sourceMapURLForScript(const Inspector::ScriptDebugListener::Script &script) {
  return script.sourceMappingURL;
}

void JSCDebuggerAgentImpl::enable() {
  if (m_enabled) return;

  m_debugger->addListener(this);

  if (m_listener) m_listener->debuggerWasEnabled();
  // active breakpoints by default
  setBreakpointsActive(true);
  m_enabled = true;
}

void JSCDebuggerAgentImpl::disable(bool isBeingDestroyed) {
  if (!m_enabled) return;

  m_debugger->removeListener(this, isBeingDestroyed);
  clearInspectorBreakpointState();

  if (!isBeingDestroyed) m_debugger->deactivateBreakpoints();

  ASSERT(m_javaScriptBreakpoints.isEmpty());

  if (m_listener) m_listener->debuggerWasDisabled();

  clearAsyncStackTraceData();

  m_pauseOnAssertionFailures = false;

  m_enabled = false;
}

void JSCDebuggerAgentImpl::didClearGlobalObject() {
  // Clear breakpoints from the debugger, but keep the inspector's model of which
  // pages have what breakpoints, as the mapping is only sent to DebuggerAgent once.
  clearDebuggerBreakpointState();

  clearAsyncStackTraceData();

  //m_frontendDispatcher->globalObjectCleared();
}

///////////////////// Own Private////////////////////////////////

Ref<JSON::ArrayOf<Inspector::Protocol::Debugger::CallFrame>>
JSCDebuggerAgentImpl::currentCallFrames(const Inspector::InjectedScript &injectedScript) {
  if (injectedScript.hasNoValue())
    return JSON::ArrayOf<Inspector::Protocol::Debugger::CallFrame>::create();

  return injectedScript.wrapCallFrames(m_currentCallStack.get());
}

void JSCDebuggerAgentImpl::resolveBreakpoint(const Inspector::ScriptDebugListener::Script &script,
                                             JSC::Breakpoint &breakpoint) {
  if (breakpoint.line < static_cast<unsigned>(script.startLine) ||
      static_cast<unsigned>(script.endLine) < breakpoint.line)
    return;

  m_debugger->resolveBreakpoint(breakpoint, script.sourceProvider.get());
}

void JSCDebuggerAgentImpl::setBreakpoint(JSC::Breakpoint &breakpoint, bool &existing) {
  JSC::JSLockHolder locker(m_debugger->vm());
  m_debugger->setBreakpoint(breakpoint, existing);
}

void JSCDebuggerAgentImpl::didSetBreakpoint(const JSC::Breakpoint &breakpoint, const String &breakpointIdentifier,
                                            const Inspector::ScriptBreakpoint &scriptBreakpoint) {
  JSC::BreakpointID id = breakpoint.id;
  m_debugger->setBreakpointActions(id, scriptBreakpoint);

  auto debugServerBreakpointIDsIterator = m_breakpointIdentifierToDebugServerBreakpointIDs.find(breakpointIdentifier);
  if (debugServerBreakpointIDsIterator == m_breakpointIdentifierToDebugServerBreakpointIDs.end())
    debugServerBreakpointIDsIterator =
      m_breakpointIdentifierToDebugServerBreakpointIDs.set(breakpointIdentifier, Vector<JSC::BreakpointID>()).iterator;
  debugServerBreakpointIDsIterator->value.append(id);

  m_debuggerBreakpointIdentifierToInspectorBreakpointIdentifier.set(id, breakpointIdentifier);
}

bool JSCDebuggerAgentImpl::assertPaused(Inspector::ErrorString &errorString) {
  if (!m_pausedScriptState) {
    errorString = ASCIILiteral::fromLiteralUnsafe("Can only perform operation while paused.");
    return false;
  }

  return true;
}

void JSCDebuggerAgentImpl::clearDebuggerBreakpointState() {
  {
    JSC::JSLockHolder holder(m_debugger->vm());
    m_debugger->clearBreakpointActions();
    m_debugger->clearBreakpoints();
    m_debugger->clearBlacklist();
  }

  m_pausedScriptState = nullptr;
  m_currentCallStack = {};
  m_scripts.clear();
  m_breakpointIdentifierToDebugServerBreakpointIDs.clear();
  m_debuggerBreakpointIdentifierToInspectorBreakpointIdentifier.clear();
  m_continueToLocationBreakpointID = JSC::noBreakpointID;
  clearBreakDetails();
  m_javaScriptPauseScheduled = false;
  m_hasExceptionValue = false;

  if (isPaused()) {
    m_debugger->continueProgram();
    m_frontend.resumed();
  }
}

void JSCDebuggerAgentImpl::clearInspectorBreakpointState() {
  Inspector::ErrorString dummyError;
  Vector<String> breakpointIdentifiers;
  for (auto key : m_breakpointIdentifierToDebugServerBreakpointIDs.keys()) {
    breakpointIdentifiers.append(key);
  }
  for (const String &identifier : breakpointIdentifiers) {
    removeBreakpoint(identifier.utf8().data());
  }

  m_javaScriptBreakpoints.clear();

  clearDebuggerBreakpointState();
}

void JSCDebuggerAgentImpl::clearBreakDetails() {
  m_breakReason = Inspector::DebuggerFrontendDispatcher::Reason::Other;
  m_breakAuxData = nullptr;
}

void JSCDebuggerAgentImpl::clearExceptionValue() {
  if (m_hasExceptionValue) {
    m_injectedScriptManager->clearExceptionValue();
    m_hasExceptionValue = false;
  }
}

void JSCDebuggerAgentImpl::clearAsyncStackTraceData() {
  m_pendingAsyncCalls.clear();
  m_currentAsyncCallIdentifier = WTF::nullopt;
}

void JSCDebuggerAgentImpl::registerIdleHandler() {
  if (!m_registeredIdleCallback) {
    m_registeredIdleCallback = true;
    JSC::VM &vm = m_debugger->vm();
    vm.whenIdle([this]() { didBecomeIdle(); });
  }
}

void JSCDebuggerAgentImpl::willStepAndMayBecomeIdle() {
  // When stepping the backend must eventually trigger a "paused" or "resumed" event.
  // If the step causes us to exit the VM, then we should issue "resumed".
  m_conditionToDispatchResumed = ShouldDispatchResumed::WhenIdle;

  registerIdleHandler();
}

void JSCDebuggerAgentImpl::didBecomeIdle() {
  m_registeredIdleCallback = false;

  if (m_conditionToDispatchResumed == ShouldDispatchResumed::WhenIdle) {
    cancelPauseOnNextStatement();
    m_debugger->continueProgram();
    m_frontend.resumed();
  }

  m_conditionToDispatchResumed = ShouldDispatchResumed::No;

  if (m_enablePauseWhenIdle) {
    pause();
  }
}

RefPtr<JSON::Object> JSCDebuggerAgentImpl::buildBreakpointPauseReason(JSC::BreakpointID debuggerBreakpointIdentifier) {

  //            ASSERT(debuggerBreakpointIdentifier != JSC::noBreakpointID);
  auto it = m_debuggerBreakpointIdentifierToInspectorBreakpointIdentifier.find(debuggerBreakpointIdentifier);
  if (it == m_debuggerBreakpointIdentifierToInspectorBreakpointIdentifier.end()) return nullptr;

  auto reason = Inspector::Protocol::Debugger::BreakpointPauseReason::create().setBreakpointId(it->value).release();
  return reason->openAccessors();
}

RefPtr<JSON::Object> JSCDebuggerAgentImpl::buildExceptionPauseReason(JSC::JSValue exception,
                                                                     const Inspector::InjectedScript &injectedScript) {

  //            ASSERT(exception);
  if (!exception) return nullptr;

  //            ASSERT(!injectedScript.hasNoValue());
  if (injectedScript.hasNoValue()) return nullptr;

  return injectedScript.wrapObject(exception, JSCDebuggerAgentImpl::backtraceObjectGroup)->openAccessors();
}

static bool breakpointActionTypeForString(const String &typeString, Inspector::ScriptBreakpointActionType *output) {
  if (typeString == Inspector::Protocol::InspectorHelpers::getEnumConstantValue(
                      Inspector::Protocol::Debugger::BreakpointAction::Type::Log)) {
    *output = Inspector::ScriptBreakpointActionTypeLog;
    return true;
  }
  if (typeString == Inspector::Protocol::InspectorHelpers::getEnumConstantValue(
                      Inspector::Protocol::Debugger::BreakpointAction::Type::Evaluate)) {
    *output = Inspector::ScriptBreakpointActionTypeEvaluate;
    return true;
  }
  if (typeString == Inspector::Protocol::InspectorHelpers::getEnumConstantValue(
                      Inspector::Protocol::Debugger::BreakpointAction::Type::Sound)) {
    *output = Inspector::ScriptBreakpointActionTypeSound;
    return true;
  }
  if (typeString == Inspector::Protocol::InspectorHelpers::getEnumConstantValue(
                      Inspector::Protocol::Debugger::BreakpointAction::Type::Probe)) {
    *output = Inspector::ScriptBreakpointActionTypeProbe;
    return true;
  }

  return false;
}

bool JSCDebuggerAgentImpl::breakpointActionsFromProtocol(Inspector::ErrorString &errorString,
                                                         RefPtr<JSON::Array> &actions,
                                                         Inspector::BreakpointActions *result) {
  if (!actions) return true;

  unsigned actionsLength = actions->length();
  if (!actionsLength) return true;

  result->reserveCapacity(actionsLength);
  for (unsigned i = 0; i < actionsLength; ++i) {
    RefPtr<JSON::Value> value = actions->get(i);
    RefPtr<JSON::Object> object;
    if (!value->asObject(object)) {
      errorString = ASCIILiteral::fromLiteralUnsafe("BreakpointAction of incorrect type, expected object");
      return false;
    }

    String typeString;
    if (!object->getString(ASCIILiteral::fromLiteralUnsafe("type"), typeString)) {
      errorString = ASCIILiteral::fromLiteralUnsafe("BreakpointAction had type missing");
      return false;
    }

    Inspector::ScriptBreakpointActionType type;
    if (!breakpointActionTypeForString(typeString, &type)) {
      errorString = ASCIILiteral::fromLiteralUnsafe("BreakpointAction had unknown type");
      return false;
    }

    // Specifying an identifier is optional. They are used to correlate probe samples
    // in the frontend across multiple backend probe actions and segregate object groups.
    int identifier = 0;
    object->getInteger(ASCIILiteral::fromLiteralUnsafe("id"), identifier);

    String data;
    object->getString(ASCIILiteral::fromLiteralUnsafe("data"), data);

    result->append(Inspector::ScriptBreakpointAction(type, identifier, data));
  }

  return true;
}

void JSCDebuggerAgentImpl::willRunMicrotask() {
}
void JSCDebuggerAgentImpl::didRunMicrotask() {
}

} // namespace kraken::debugger
