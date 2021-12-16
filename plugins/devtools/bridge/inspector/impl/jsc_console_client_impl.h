/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_JSC_CONSOLE_CLIENT_IMPL_H
#define KRAKEN_DEBUGGER_JSC_CONSOLE_CLIENT_IMPL_H

#include <JavaScriptCore/ConsoleClient.h>
#include <JavaScriptCore/JSExportMacros.h>
#include <string>
#include <wtf/Vector.h>
#include <wtf/text/WTFString.h>

namespace kraken::debugger {
class JSCLogAgentImpl;
class JSCConsoleClientImpl : public JSC::ConsoleClient {
  WTF_MAKE_FAST_ALLOCATED;

public:
  explicit JSCConsoleClientImpl(JSCLogAgentImpl *);
  virtual ~JSCConsoleClientImpl() {}

  void sendMessageToConsole(MessageLevel, const std::string &message);

protected:
  void messageWithTypeAndLevel(MessageType, MessageLevel, JSC::ExecState *,
                               Ref<Inspector::ScriptArguments> &&) override;
  void count(JSC::ExecState *, const String& label) override;
  void profile(JSC::ExecState *, const String &title) override;
  void profileEnd(JSC::ExecState *, const String &title) override;
  void takeHeapSnapshot(JSC::ExecState *, const String &title) override;
  void time(JSC::ExecState *, const String &title) override;
  void timeEnd(JSC::ExecState *, const String &title) override;
  void timeStamp(JSC::ExecState *, Ref<Inspector::ScriptArguments> &&) override;
  void record(JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) override;
  void recordEnd(JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) override;
  void countReset(JSC::ExecState*, const String& label) override;
  void timeLog(JSC::ExecState*, const String& label, Ref<Inspector::ScriptArguments>&&) override;
  void screenshot(JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) override;

private:
  void warnUnimplemented(const String &method);

  JSCLogAgentImpl *m_consoleAgent;
};
} // namespace kraken

#endif // KRAKEN_DEBUGGER_JSC_CONSOLE_CLIENT_IMPL_H
