/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <wtf/text/StringBuilder.h>
#include <wtf/text/ASCIILiteral.h>
#include <JavaScriptCore/ScriptValue.h>
#include <JavaScriptCore/ConsoleMessage.h>
#include <JavaScriptCore/ScriptArguments.h>
#include "jsc_console_client_impl.h"
#include "inspector/impl/jsc_log_agent_impl.h"
#include "inspector/protocol/log_entry.h"
#include <chrono>

namespace kraken::debugger {

JSCConsoleClientImpl::JSCConsoleClientImpl(kraken::debugger::JSCLogAgentImpl *logAgent) : m_consoleAgent(logAgent) {}

void JSCConsoleClientImpl::sendMessageToConsole(MessageLevel level, const std::string &message) {
  std::string v8_level = LogEntry::LevelEnum::Verbose;
  if (level == MessageLevel::Log) {
    v8_level = LogEntry::LevelEnum::Verbose;
  } else if (level == MessageLevel::Info) {
    v8_level = LogEntry::LevelEnum::Info;
  } else if (level == MessageLevel::Warning) {
    v8_level = LogEntry::LevelEnum::Warning;
  } else if (level == MessageLevel::Debug) {
    v8_level = LogEntry::LevelEnum::Info;
  } else if (level == MessageLevel::Error) {
    v8_level = LogEntry::LevelEnum::Error;
  }

  std::string v8_source = LogEntry::SourceEnum::Javascript;

  auto now = std::chrono::high_resolution_clock::now();
  auto logEntry = LogEntry::create()
                    .setLevel(v8_level)
                    .setTimestamp(std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count())
                    .setSource(v8_source)
                    .setText(message)
                    .build();
  m_consoleAgent->addMessageToConsole(std::move(logEntry));
}

void JSCConsoleClientImpl::messageWithTypeAndLevel(MessageType type, MessageLevel level, JSC::ExecState *exec,
                                                   Ref<Inspector::ScriptArguments> &&arguments) {
  //            WTF::String message;
  //            arguments->getFirstArgumentAsString(message);

  WTF::StringBuilder builder;
  for (size_t i = 0; i < exec->argumentCount(); i++) {
    auto &&string = exec->argument(i).getString(exec);
    builder.appendCharacters(string.characters8(), string.length());
    builder.append(" ");
  }

  std::string v8_level = LogEntry::LevelEnum::Verbose;
  if (level == MessageLevel::Log) {
    v8_level = LogEntry::LevelEnum::Verbose;
  } else if (level == MessageLevel::Info) {
    v8_level = LogEntry::LevelEnum::Info;
  } else if (level == MessageLevel::Warning) {
    v8_level = LogEntry::LevelEnum::Warning;
  } else if (level == MessageLevel::Debug) {
    v8_level = LogEntry::LevelEnum::Info;
  } else if (level == MessageLevel::Error) {
    v8_level = LogEntry::LevelEnum::Error;
  }

  std::string v8_source = LogEntry::SourceEnum::Javascript;

  auto now = std::chrono::high_resolution_clock::now();
  auto logEntry = LogEntry::create()
                    .setLevel(v8_level)
                    .setTimestamp(std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count())
                    .setSource(v8_source)
                    .setText(builder.toString().utf8().data())
                    .build();

  m_consoleAgent->addMessageToConsole(std::move(logEntry));
}

void JSCConsoleClientImpl::count(JSC::ExecState *, const String& label) {
  warnUnimplemented(ASCIILiteral::fromLiteralUnsafe("console.count"));
}

void JSCConsoleClientImpl::profile(JSC::ExecState *, const String &title) {
  auto now = std::chrono::high_resolution_clock::now();
  auto logEntry = LogEntry::create()
                    .setLevel(LogEntry::LevelEnum::Error)
                    .setTimestamp(std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count())
                    .setSource(LogEntry::SourceEnum::Javascript)
                    .setText(title.utf8().data())
                    .build();
  m_consoleAgent->addMessageToConsole(std::move(logEntry));
}

void JSCConsoleClientImpl::profileEnd(JSC::ExecState *, const String &title) {
  warnUnimplemented(ASCIILiteral::fromLiteralUnsafe("console.profileEnd"));
}

void JSCConsoleClientImpl::takeHeapSnapshot(JSC::ExecState *, const String &title) {
  warnUnimplemented(ASCIILiteral::fromLiteralUnsafe("console.takeHeapSnapshot"));
}

void JSCConsoleClientImpl::time(JSC::ExecState *, const String &title) {
  warnUnimplemented(ASCIILiteral::fromLiteralUnsafe("console.time"));
}

void JSCConsoleClientImpl::timeEnd(JSC::ExecState *, const String &title) {
  warnUnimplemented(ASCIILiteral::fromLiteralUnsafe("console.timeEnd"));
}

void JSCConsoleClientImpl::timeStamp(JSC::ExecState *, Ref<Inspector::ScriptArguments> &&) {
  warnUnimplemented(ASCIILiteral::fromLiteralUnsafe("console.timeStamp"));
}

void JSCConsoleClientImpl::record(JSC::ExecState *, Ref<Inspector::ScriptArguments> &&) {
  warnUnimplemented(ASCIILiteral::fromLiteralUnsafe("console.record"));
}

void JSCConsoleClientImpl::recordEnd(JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) {
  warnUnimplemented(ASCIILiteral::fromLiteralUnsafe("console.recordEnd"));
};

void JSCConsoleClientImpl::warnUnimplemented(const String &method) {
  String message = method + " is currently ignored in JavaScript context inspection.";
  auto now = std::chrono::high_resolution_clock::now();
  auto logEntry = LogEntry::create()
                    .setLevel(LogEntry::LevelEnum::Warning)
                    .setTimestamp(std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count())
                    .setSource(LogEntry::SourceEnum::Javascript)
                    .setText(message.utf8().data())
                    .build();

  m_consoleAgent->addMessageToConsole(std::move(logEntry));
}

void JSCConsoleClientImpl::countReset(JSC::ExecState *, const String &label) {}
void JSCConsoleClientImpl::timeLog(JSC::ExecState *, const String &label, Ref<Inspector::ScriptArguments> &&) {}
void JSCConsoleClientImpl::screenshot(JSC::ExecState *, Ref<Inspector::ScriptArguments> &&) {}

} // namespace kraken
