/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/protocol/debugger_frontend.h"
#include "inspector/protocol/breakpoint_resolved_notification.h"
#include "inspector/protocol/paused_notification.h"
#include "inspector/protocol/script_failed_to_parse_notification.h"
#include "inspector/protocol/script_parsed_notification.h"

namespace kraken {
namespace debugger {
void DebuggerFrontend::breakpointResolved(const std::string &breakpointId,
                                          std::unique_ptr<kraken::debugger::Location> location) {
  if (!m_frontendChannel) return;
  std::unique_ptr<BreakpointResolvedNotification> messageData =
    BreakpointResolvedNotification::create().setBreakpointId(breakpointId).setLocation(std::move(location)).build();

  rapidjson::Document doc;
  Event event = {"Debugger.breakpointResolved", messageData->toValue(doc.GetAllocator())};
  m_frontendChannel->sendProtocolNotification(std::move(event));
}

void DebuggerFrontend::paused(std::unique_ptr<std::vector<std::unique_ptr<kraken::debugger::CallFrame>>> callFrames,
                              const std::string &reason, kraken::debugger::Maybe<rapidjson::Value> data,
                              kraken::debugger::Maybe<std::vector<std::string>> hitBreakpoints,
                              kraken::debugger::Maybe<kraken::debugger::StackTrace> asyncStackTrace,
                              kraken::debugger::Maybe<kraken::debugger::StackTraceId> asyncStackTraceId,
                              kraken::debugger::Maybe<kraken::debugger::StackTraceId> asyncCallStackTraceId) {

  if (!m_frontendChannel) return;
  std::unique_ptr<PausedNotification> messageData =
    PausedNotification::create().setCallFrames(std::move(callFrames)).setReason(reason).build();
  if (data.isJust()) messageData->setData(std::move(data).takeJust());
  if (hitBreakpoints.isJust()) messageData->setHitBreakpoints(std::move(hitBreakpoints).takeJust());
  if (asyncStackTrace.isJust()) messageData->setAsyncStackTrace(std::move(asyncStackTrace).takeJust());
  if (asyncStackTraceId.isJust()) messageData->setAsyncStackTraceId(std::move(asyncStackTraceId).takeJust());
  if (asyncCallStackTraceId.isJust())
    messageData->setAsyncCallStackTraceId(std::move(asyncCallStackTraceId).takeJust());

  rapidjson::Document doc;
  Event event = {"Debugger.paused", messageData->toValue(doc.GetAllocator())};
  m_frontendChannel->sendProtocolNotification(std::move(event));
}

void DebuggerFrontend::resumed() {
  if (!m_frontendChannel) return;
  Event event = {"Debugger.resumed", rapidjson::Value(rapidjson::kObjectType)};
  m_frontendChannel->sendProtocolNotification(std::move(event));
}

void DebuggerFrontend::scriptFailedToParse(const std::string &scriptId, const std::string &url, int startLine,
                                           int startColumn, int endLine, int endColumn, int executionContextId,
                                           const std::string &hash,
                                           kraken::debugger::Maybe<rapidjson::Value> executionContextAuxData,
                                           kraken::debugger::Maybe<std::string> sourceMapURL,
                                           kraken::debugger::Maybe<bool> hasSourceURL,
                                           kraken::debugger::Maybe<bool> isModule, kraken::debugger::Maybe<int> length,
                                           kraken::debugger::Maybe<kraken::debugger::StackTrace> stackTrace) {
  if (!m_frontendChannel) return;
  std::unique_ptr<ScriptFailedToParseNotification> messageData = ScriptFailedToParseNotification::create()
                                                                   .setScriptId(scriptId)
                                                                   .setUrl(url)
                                                                   .setStartLine(startLine)
                                                                   .setStartColumn(startColumn)
                                                                   .setEndLine(endLine)
                                                                   .setEndColumn(endColumn)
                                                                   .setExecutionContextId(executionContextId)
                                                                   .setHash(hash)
                                                                   .build();
  if (executionContextAuxData.isJust())
    messageData->setExecutionContextAuxData(std::move(executionContextAuxData).takeJust());
  if (sourceMapURL.isJust()) messageData->setSourceMapURL(std::move(sourceMapURL).takeJust());
  if (hasSourceURL.isJust()) messageData->setHasSourceURL(std::move(hasSourceURL).takeJust());
  if (isModule.isJust()) messageData->setIsModule(std::move(isModule).takeJust());
  if (length.isJust()) messageData->setLength(std::move(length).takeJust());
  if (stackTrace.isJust()) messageData->setStackTrace(std::move(stackTrace).takeJust());

  rapidjson::Document doc;
  Event event = {"Debugger.scriptFailedToParse", messageData->toValue(doc.GetAllocator())};

  m_frontendChannel->sendProtocolNotification(std::move(event));
}

void DebuggerFrontend::scriptParsed(const std::string &scriptId, const std::string &url, int startLine, int startColumn,
                                    int endLine, int endColumn, int executionContextId, const std::string &hash,
                                    kraken::debugger::Maybe<rapidjson::Value> executionContextAuxData,
                                    kraken::debugger::Maybe<bool> isLiveEdit,
                                    kraken::debugger::Maybe<std::string> sourceMapURL,
                                    kraken::debugger::Maybe<bool> hasSourceURL, kraken::debugger::Maybe<bool> isModule,
                                    kraken::debugger::Maybe<int> length,
                                    kraken::debugger::Maybe<kraken::debugger::StackTrace> stackTrace) {
  if (!m_frontendChannel) return;
  std::unique_ptr<ScriptParsedNotification> messageData = ScriptParsedNotification::create()
                                                            .setScriptId(scriptId)
                                                            .setUrl(url)
                                                            .setStartLine(startLine)
                                                            .setStartColumn(startColumn)
                                                            .setEndLine(endLine)
                                                            .setEndColumn(endColumn)
                                                            .setExecutionContextId(executionContextId)
                                                            .setHash(hash)
                                                            .build();
  if (executionContextAuxData.isJust())
    messageData->setExecutionContextAuxData(std::move(executionContextAuxData).takeJust());
  if (isLiveEdit.isJust()) messageData->setIsLiveEdit(std::move(isLiveEdit).takeJust());
  if (sourceMapURL.isJust()) messageData->setSourceMapURL(std::move(sourceMapURL).takeJust());
  if (hasSourceURL.isJust()) messageData->setHasSourceURL(std::move(hasSourceURL).takeJust());
  if (isModule.isJust()) messageData->setIsModule(std::move(isModule).takeJust());
  if (length.isJust()) messageData->setLength(std::move(length).takeJust());
  if (stackTrace.isJust()) messageData->setStackTrace(std::move(stackTrace).takeJust());

  rapidjson::Document doc;
  Event event = {"Debugger.scriptParsed", messageData->toValue(doc.GetAllocator())};

  m_frontendChannel->sendProtocolNotification(std::move(event));
}

} // namespace debugger
} // namespace kraken
