//
// Created by rowandjj on 2019/4/24.
//

#include "jsc_console_client_impl.h"
#include "JavaScriptCore/inspector/ScriptArguments.h"
#include "JavaScriptCore/inspector/ConsoleMessage.h"
#include "JavaScriptCore/bindings/ScriptValue.h"
#include <wtf/text/StringBuilder.h>
#include "devtools/protocol/log_entry.h"
#include "devtools/impl/jsc_log_agent_impl.h"

#include "foundation/time_point.h"
#include "foundation/logging.h"

namespace kraken{
    namespace Debugger {

        JSCConsoleClientImpl::JSCConsoleClientImpl(kraken::Debugger::JSCLogAgentImpl *logAgent)
                : m_consoleAgent(logAgent) {
        }

        void JSCConsoleClientImpl::sendMessageToConsole(MessageLevel level, const std::string& message) {
            std::string v8_level = LogEntry::LevelEnum::Verbose;
            if(level == MessageLevel::Log) {
                v8_level = LogEntry::LevelEnum::Verbose;
            } else if(level == MessageLevel::Info) {
                v8_level = LogEntry::LevelEnum::Info;
            } else if(level == MessageLevel::Warning) {
                v8_level = LogEntry::LevelEnum::Warning;
            } else if(level == MessageLevel::Debug) {
                v8_level = LogEntry::LevelEnum::Info;
            } else if(level == MessageLevel::Error) {
                v8_level = LogEntry::LevelEnum::Error;
            }

            std::string v8_source = LogEntry::SourceEnum::Javascript;

            auto logEntry = LogEntry::create()
                    .setLevel(v8_level)
                    .setTimestamp(foundation::TimePoint::Now().ToEpochDelta().ToMilliseconds())
                    .setSource(v8_source)
                    .setText(message)
                    .build();

            m_consoleAgent->addMessageToConsole(std::move(logEntry));
        }


        void JSCConsoleClientImpl::messageWithTypeAndLevel(MessageType type, MessageLevel level,
                                                           JSC::ExecState *exec,
                                                           Ref<Inspector::ScriptArguments> &&arguments) {
//            WTF::String message;
//            arguments->getFirstArgumentAsString(message);

            WTF::StringBuilder builder;
            for(size_t i = 0; i < exec->argumentCount(); i++) {
                builder.append(exec->argument(i).toWTFString(exec));
                builder.append(" ");
            }


            std::string v8_level = LogEntry::LevelEnum::Verbose;
            if(level == MessageLevel::Log) {
                v8_level = LogEntry::LevelEnum::Verbose;
            } else if(level == MessageLevel::Info) {
                v8_level = LogEntry::LevelEnum::Info;
            } else if(level == MessageLevel::Warning) {
                v8_level = LogEntry::LevelEnum::Warning;
            } else if(level == MessageLevel::Debug) {
                v8_level = LogEntry::LevelEnum::Info;
            } else if(level == MessageLevel::Error) {
                v8_level = LogEntry::LevelEnum::Error;
            }

            std::string v8_source = LogEntry::SourceEnum::Javascript;

            auto logEntry = LogEntry::create()
                    .setLevel(v8_level)
                    .setTimestamp(foundation::TimePoint::Now().ToEpochDelta().ToMilliseconds())
                    .setSource(v8_source)
                    .setText(builder.toString().utf8().data())
                    .build();

            m_consoleAgent->addMessageToConsole(std::move(logEntry));
        }

        void JSCConsoleClientImpl::count(JSC::ExecState *, Ref<Inspector::ScriptArguments> &&) {
            warnUnimplemented(ASCIILiteral("console.count"));
        }

        // 这个方法临时被借用，用于输出错误日志。参见 jsc_debugger_impl.h
        void JSCConsoleClientImpl::profile(JSC::ExecState *, const String &title) {
            auto logEntry = LogEntry::create()
                    .setLevel(LogEntry::LevelEnum::Error)
                    .setTimestamp(foundation::TimePoint::Now().ToEpochDelta().ToMilliseconds())
                    .setSource(LogEntry::SourceEnum::Javascript)
                    .setText(title.utf8().data())
                    .build();
            m_consoleAgent->addMessageToConsole(std::move(logEntry));
        }

        void JSCConsoleClientImpl::profileEnd(JSC::ExecState *, const String &title) {
            warnUnimplemented(ASCIILiteral("console.profileEnd"));
        }

        void JSCConsoleClientImpl::takeHeapSnapshot(JSC::ExecState *, const String &title) {
            warnUnimplemented(ASCIILiteral("console.takeHeapSnapshot"));
        }

        void JSCConsoleClientImpl::time(JSC::ExecState *, const String &title) {
            warnUnimplemented(ASCIILiteral("console.time"));
        }

        void JSCConsoleClientImpl::timeEnd(JSC::ExecState *, const String &title) {
            warnUnimplemented(ASCIILiteral("console.timeEnd"));
        }

        void JSCConsoleClientImpl::timeStamp(JSC::ExecState *,
                                             Ref<Inspector::ScriptArguments> &&) {
            warnUnimplemented(ASCIILiteral("console.timeStamp"));
        }

        void JSCConsoleClientImpl::warnUnimplemented(const String &method) {
            String message = method + " is currently ignored in JavaScript context inspection.";
            auto logEntry = LogEntry::create()
                    .setLevel(LogEntry::LevelEnum::Warning)
                    .setTimestamp(foundation::TimePoint::Now().ToEpochDelta().ToMilliseconds())
                    .setSource(LogEntry::SourceEnum::Javascript)
                    .setText(message.utf8().data())
                    .build();

            m_consoleAgent->addMessageToConsole(std::move(logEntry));
        }

    }
}
