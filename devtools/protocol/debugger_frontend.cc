//
// Created by rowandjj on 2019/4/9.
//

#include "devtools/protocol/debugger_frontend.h"
#include "devtools/protocol/breakpoint_resolved_notification.h"
#include "devtools/protocol/paused_notification.h"
#include "devtools/protocol/script_failed_to_parse_notification.h"
#include "devtools/protocol/script_parsed_notification.h"

namespace kraken{
    namespace Debugger {
        void DebuggerFrontend::breakpointResolved(const std::string &breakpointId,
                                          std::unique_ptr<kraken::Debugger::Location> location) {
            if (!m_frontendChannel)
                return;
            std::unique_ptr<BreakpointResolvedNotification> messageData = BreakpointResolvedNotification::create()
                    .setBreakpointId(breakpointId)
                    .setLocation(std::move(location))
                    .build();

            rapidjson::Document doc;
            jsonRpc::Event event = {"Debugger.breakpointResolved", messageData->toValue(doc.GetAllocator())};
            m_frontendChannel->sendProtocolNotification(std::move(event));
        }


        void DebuggerFrontend::paused(
                std::unique_ptr<std::vector<std::unique_ptr<kraken::Debugger::CallFrame>>> callFrames,
                const std::string &reason, kraken::Debugger::Maybe<rapidjson::Value> data,
                kraken::Debugger::Maybe<std::vector<std::string>> hitBreakpoints,
                kraken::Debugger::Maybe<kraken::Debugger::StackTrace> asyncStackTrace,
                kraken::Debugger::Maybe<kraken::Debugger::StackTraceId> asyncStackTraceId,
                kraken::Debugger::Maybe<kraken::Debugger::StackTraceId> asyncCallStackTraceId) {

            if (!m_frontendChannel)
                return;
            std::unique_ptr<PausedNotification> messageData = PausedNotification::create()
                    .setCallFrames(std::move(callFrames))
                    .setReason(reason)
                    .build();
            if (data.isJust())
                messageData->setData(std::move(data).takeJust());
            if (hitBreakpoints.isJust())
                messageData->setHitBreakpoints(std::move(hitBreakpoints).takeJust());
            if (asyncStackTrace.isJust())
                messageData->setAsyncStackTrace(std::move(asyncStackTrace).takeJust());
            if (asyncStackTraceId.isJust())
                messageData->setAsyncStackTraceId(std::move(asyncStackTraceId).takeJust());
            if (asyncCallStackTraceId.isJust())
                messageData->setAsyncCallStackTraceId(std::move(asyncCallStackTraceId).takeJust());

            rapidjson::Document doc;
            jsonRpc::Event event = {"Debugger.paused", messageData->toValue(doc.GetAllocator())};
            m_frontendChannel->sendProtocolNotification(std::move(event));
        }


        void DebuggerFrontend::resumed() {
            if (!m_frontendChannel)
                return;
            jsonRpc::Event event = {"Debugger.resumed",rapidjson::Value(rapidjson::kObjectType)};
            m_frontendChannel->sendProtocolNotification(std::move(event));
        }

        void DebuggerFrontend::scriptFailedToParse(const std::string &scriptId, const std::string &url,
                                           int startLine, int startColumn, int endLine,
                                           int endColumn, int executionContextId,
                                           const std::string &hash,
                                           kraken::Debugger::Maybe<rapidjson::Value> executionContextAuxData,
                                           kraken::Debugger::Maybe<std::string> sourceMapURL,
                                           kraken::Debugger::Maybe<bool> hasSourceURL,
                                           kraken::Debugger::Maybe<bool> isModule,
                                           kraken::Debugger::Maybe<int> length,
                                           kraken::Debugger::Maybe<kraken::Debugger::StackTrace> stackTrace) {
            if (!m_frontendChannel)
                return;
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
            if (sourceMapURL.isJust())
                messageData->setSourceMapURL(std::move(sourceMapURL).takeJust());
            if (hasSourceURL.isJust())
                messageData->setHasSourceURL(std::move(hasSourceURL).takeJust());
            if (isModule.isJust())
                messageData->setIsModule(std::move(isModule).takeJust());
            if (length.isJust())
                messageData->setLength(std::move(length).takeJust());
            if (stackTrace.isJust())
                messageData->setStackTrace(std::move(stackTrace).takeJust());

            rapidjson::Document doc;
            jsonRpc::Event event = {"Debugger.scriptFailedToParse", messageData->toValue(doc.GetAllocator())};

            m_frontendChannel->sendProtocolNotification(std::move(event));
        }


        void DebuggerFrontend::scriptParsed(const std::string &scriptId, const std::string &url,
                                    int startLine, int startColumn, int endLine, int endColumn,
                                    int executionContextId, const std::string &hash,
                                    kraken::Debugger::Maybe<rapidjson::Value> executionContextAuxData,
                                    kraken::Debugger::Maybe<bool> isLiveEdit,
                                    kraken::Debugger::Maybe<std::string> sourceMapURL,
                                    kraken::Debugger::Maybe<bool> hasSourceURL,
                                    kraken::Debugger::Maybe<bool> isModule,
                                    kraken::Debugger::Maybe<int> length,
                                    kraken::Debugger::Maybe<kraken::Debugger::StackTrace> stackTrace) {
            if (!m_frontendChannel)
                return;
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
            if (isLiveEdit.isJust())
                messageData->setIsLiveEdit(std::move(isLiveEdit).takeJust());
            if (sourceMapURL.isJust())
                messageData->setSourceMapURL(std::move(sourceMapURL).takeJust());
            if (hasSourceURL.isJust())
                messageData->setHasSourceURL(std::move(hasSourceURL).takeJust());
            if (isModule.isJust())
                messageData->setIsModule(std::move(isModule).takeJust());
            if (length.isJust())
                messageData->setLength(std::move(length).takeJust());
            if (stackTrace.isJust())
                messageData->setStackTrace(std::move(stackTrace).takeJust());

            rapidjson::Document doc;
            jsonRpc::Event event = {"Debugger.scriptParsed", messageData->toValue(doc.GetAllocator())};

            m_frontendChannel->sendProtocolNotification(std::move(event));
        }

    }
}