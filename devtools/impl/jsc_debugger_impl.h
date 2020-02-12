//
// Created by rowandjj on 2019/4/3.
//

#ifndef KRAKEN_ANDROID_PLAYGROUND_JSC_DEBUGGER_IMPL_H
#define KRAKEN_ANDROID_PLAYGROUND_JSC_DEBUGGER_IMPL_H

#include "devtools/base/jsc/jsc_debugger_headers.h"
#include "foundation/macros.h"
#include "foundation/logging.h"

#include "JavaScriptCore/runtime/ConsoleClient.h"
#include "JavaScriptCore/inspector/ScriptArguments.h"

namespace kraken{
    namespace Debugger {
        class JSCDebuggerImpl : public Inspector::ScriptDebugServer {
        private:
            KRAKEN_DISALLOW_COPY_AND_ASSIGN(JSCDebuggerImpl);
        public:
            JSCDebuggerImpl(JSC::JSGlobalObject*);
            virtual ~JSCDebuggerImpl() { }

            JSC::JSGlobalObject* globalObject() const {
                return m_globalObject;
            }

        private:
            void attachDebugger() override;
            void detachDebugger(bool isBeingDestroyed) override;

            void recompileAllJSFunctions() override ;

            void didPause(JSC::JSGlobalObject*) override {
//                KRAKEN_LOG(VERBOSE) << "did pause called";
            }

            void didContinue(JSC::JSGlobalObject*) override {
//                KRAKEN_LOG(VERBOSE) << "did continue called";
            }

            void runEventLoopWhilePaused() override;
            bool isContentScript(JSC::ExecState*) const override { return false; }

            // chrome控制台打印
            void reportException(JSC::ExecState *exec, JSC::Exception *exception) const override {
                if(m_globalObject && m_globalObject->consoleClient()) {
                    JSC::VM& vm = exec->vm();
                    if (isTerminatedExecutionException(vm, exception))
                        return;

                    auto scope = DECLARE_CATCH_SCOPE(vm);
                    JSC::ErrorHandlingScope errorScope(vm);

                    Ref<Inspector::ScriptCallStack> callStack =
                            Inspector::createScriptCallStackFromException(exec, exception, Inspector::ScriptCallStack::maxCallStackSizeToCapture);

                    String errorMessage = exception->value().toWTFString(exec);
                    scope.clearException();

                    // 借用下这个方法将错误日志传过去...
                    m_globalObject->consoleClient()->profile(nullptr, errorMessage);
                }
            }

            JSC::JSGlobalObject* m_globalObject;
        };
    }
}


#endif //KRAKEN_ANDROID_PLAYGROUND_JSC_DEBUGGER_IMPL_H
