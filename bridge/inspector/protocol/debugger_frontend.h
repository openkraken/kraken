/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_DEBUGGERFRONTEND_H
#define KRAKEN_DEBUGGER_DEBUGGERFRONTEND_H

#include "inspector/protocol/call_frame.h"
#include "inspector/protocol/frontend_channel.h"
#include "inspector/protocol/location.h"
#include "inspector/protocol/maybe.h"
#include "inspector/protocol/stacktrace.h"
#include "inspector/protocol/stacktrace_id.h"
#include <string>
#include <vector>

namespace kraken {
namespace debugger {

//
//                  json-rpc events
//  JSDebugger ---------------------------> chrome devTool
//
//
class DebuggerFrontend {
public:
  explicit DebuggerFrontend(FrontendChannel *frontendChannel) : m_frontendChannel(frontendChannel) {}
  void breakpointResolved(const std::string &breakpointId, std::unique_ptr<Location> location);

  void paused(std::unique_ptr<std::vector<std::unique_ptr<CallFrame>>> callFrames, const std::string &reason,
              Maybe<rapidjson::Value> data = Maybe<rapidjson::Value>(),
              Maybe<std::vector<std::string>> hitBreakpoints = Maybe<std::vector<std::string>>(),
              Maybe<StackTrace> asyncStackTrace = Maybe<StackTrace>(),
              Maybe<StackTraceId> asyncStackTraceId = Maybe<StackTraceId>(),
              Maybe<StackTraceId> asyncCallStackTraceId = Maybe<StackTraceId>());

  void resumed();

  void scriptFailedToParse(const std::string &scriptId, const std::string &url, int startLine, int startColumn,
                           int endLine, int endColumn, int executionContextId, const std::string &hash,
                           Maybe<rapidjson::Value> executionContextAuxData = Maybe<rapidjson::Value>(),
                           Maybe<std::string> sourceMapURL = Maybe<std::string>(),
                           Maybe<bool> hasSourceURL = Maybe<bool>(), Maybe<bool> isModule = Maybe<bool>(),
                           Maybe<int> length = Maybe<int>(), Maybe<StackTrace> stackTrace = Maybe<StackTrace>());

  void scriptParsed(const std::string &scriptId, const std::string &url, int startLine, int startColumn, int endLine,
                    int endColumn, int executionContextId, const std::string &hash,
                    Maybe<rapidjson::Value> executionContextAuxData = Maybe<rapidjson::Value>(),
                    Maybe<bool> isLiveEdit = Maybe<bool>(), Maybe<std::string> sourceMapURL = Maybe<std::string>(),
                    Maybe<bool> hasSourceURL = Maybe<bool>(), Maybe<bool> isModule = Maybe<bool>(),
                    Maybe<int> length = Maybe<int>(), Maybe<StackTrace> stackTrace = Maybe<StackTrace>());

private:
  FrontendChannel *m_frontendChannel;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_DEBUGGERFRONTEND_H
