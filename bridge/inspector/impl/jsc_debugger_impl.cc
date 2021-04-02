/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "jsc_debugger_impl.h"
#include <JavaScriptCore/JSCJSValueInlines.h>

namespace kraken::debugger {
using namespace JSC;
JSCDebuggerImpl::JSCDebuggerImpl(JSGlobalObject *globalObject)
  : Inspector::ScriptDebugServer(globalObject->vm()), m_globalObject(globalObject) {}

void JSCDebuggerImpl::recompileAllJSFunctions() {
  KRAKEN_LOG(VERBOSE) << "recompileAllJSFunctions called";
  JSC::JSLockHolder holder(vm());
  JSC::Debugger::recompileAllJSFunctions();
}

void JSCDebuggerImpl::attachDebugger() {
  attach(m_globalObject);
}

void JSCDebuggerImpl::detachDebugger(bool isBeingDestroyed) {

  KRAKEN_LOG(VERBOSE) << "[debugger] JS debugger detached!";

  detach(m_globalObject,
         isBeingDestroyed ? Debugger::GlobalObjectIsDestructing : Debugger::TerminatingDebuggingSession);
  if (!isBeingDestroyed) recompileAllJSFunctions();
}

void JSCDebuggerImpl::runEventLoopWhilePaused() {
  // Drop all locks so another thread can work in the VM while we are nested.
  JSC::JSLock::DropAllLocks dropAllLocks(m_globalObject->vm());

  while (!m_doneProcessingDebuggerEvents) {
    std::this_thread::sleep_for(std::chrono::milliseconds(50));
  }
}

void JSCDebuggerImpl::reportException(JSC::ExecState *exec, JSC::Exception *exception) const {
  if (m_globalObject && m_globalObject->consoleClient()) {
    JSC::VM &vm = m_globalObject->vm();
    if (isTerminatedExecutionException(vm, exception)) return;

    auto scope = DECLARE_CATCH_SCOPE(vm);
    JSC::ErrorHandlingScope errorScope(vm);

    Ref<Inspector::ScriptCallStack> callStack = Inspector::createScriptCallStackFromException(
      exec, exception, Inspector::ScriptCallStack::maxCallStackSizeToCapture);

    String errorMessage = exception->value().getString(exec);
    scope.clearException();

    m_globalObject->consoleClient()->profile(nullptr, errorMessage);
  }
}
} // namespace kraken::debugger
