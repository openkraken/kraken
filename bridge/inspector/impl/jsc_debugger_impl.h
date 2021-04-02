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

  void reportException(JSC::ExecState *exec, JSC::Exception *exception) const override;

  JSC::JSGlobalObject *m_globalObject;
};
} // namespace kraken

#endif // KRAKEN_ANDROID_PLAYGROUND_JSC_DEBUGGER_IMPL_H
