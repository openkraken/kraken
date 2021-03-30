/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_ANDROID_PLAYGROUND_JSC_DEBUGGER_IMPL_H
#define KRAKEN_ANDROID_PLAYGROUND_JSC_DEBUGGER_IMPL_H

#include "foundation/logging.h"
#include "kraken_foundation.h"

#include <JavaScriptCore/ScriptArguments.h>
#include <JavaScriptCore/ConsoleClient.h>
#include <JavaScriptCore/ScriptDebugServer.h>
#include <JavaScriptCore/JSGlobalObject.h>
#include <JavaScriptCore/CatchScope.h>
#include <JavaScriptCore/ErrorHandlingScope.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/Exception.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>

namespace kraken::debugger {
class JSCDebuggerImpl : public Inspector::ScriptDebugServer {
private:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(JSCDebuggerImpl);

public:
  explicit JSCDebuggerImpl(JSC::JSGlobalObject *);
  virtual ~JSCDebuggerImpl() {}

  JSC::JSGlobalObject *globalObject() const {
    return m_globalObject;
  }

private:
  void attachDebugger() override;
  void detachDebugger(bool isBeingDestroyed) override;

  void recompileAllJSFunctions() override;

  void didPause(JSC::JSGlobalObject *) override {
    //                KRAKEN_LOG(VERBOSE) << "did pause called";
  }

  void didContinue(JSC::JSGlobalObject *) override {
    //                KRAKEN_LOG(VERBOSE) << "did continue called";
  }

  void runEventLoopWhilePaused() override;
  bool isContentScript(JSC::ExecState *) const override {
    return false;
  }

  // chrome控制台打印
  void reportException(JSC::ExecState *exec, JSC::Exception *exception) const override {
    if (m_globalObject && m_globalObject->consoleClient()) {
      JSC::VM &vm = exec->vm();
      if (isTerminatedExecutionException(vm, exception)) return;

      auto scope = DECLARE_CATCH_SCOPE(vm);
      JSC::ErrorHandlingScope errorScope(vm);

      Ref<Inspector::ScriptCallStack> callStack = Inspector::createScriptCallStackFromException(
        exec, exception, Inspector::ScriptCallStack::maxCallStackSizeToCapture);

      String errorMessage = exception->value().toWTFString(exec);
      scope.clearException();

      // 借用下这个方法将错误日志传过去...
      m_globalObject->consoleClient()->profile(nullptr, errorMessage);
    }
  }

  JSC::JSGlobalObject *m_globalObject;
};
} // namespace kraken

#endif // KRAKEN_ANDROID_PLAYGROUND_JSC_DEBUGGER_IMPL_H
