//
// Created by rowandjj on 2019/4/24.
//

#ifndef KRAKEN_DEBUGGER_JSC_CONSOLE_CLIENT_IMPL_H
#define KRAKEN_DEBUGGER_JSC_CONSOLE_CLIENT_IMPL_H

#include "JavaScriptCore/runtime/JSExportMacros.h"
#include "JavaScriptCore/runtime/ConsoleClient.h"
#include <wtf/Vector.h>
#include <wtf/text/WTFString.h>
#include <string>


namespace kraken{
    namespace Debugger {
        class JSCLogAgentImpl;
        class JSCConsoleClientImpl final : public JSC::ConsoleClient {
            WTF_MAKE_FAST_ALLOCATED;
        public:
            explicit JSCConsoleClientImpl(JSCLogAgentImpl*);
            virtual ~JSCConsoleClientImpl() { }

            void sendMessageToConsole(MessageLevel, const std::string& message);

        protected:
            void messageWithTypeAndLevel(MessageType, MessageLevel, JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) override;
            void count(JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) override;
            void profile(JSC::ExecState*, const String& title) override;
            void profileEnd(JSC::ExecState*, const String& title) override;
            void takeHeapSnapshot(JSC::ExecState*, const String& title) override;
            void time(JSC::ExecState*, const String& title) override;
            void timeEnd(JSC::ExecState*, const String& title) override;
            void timeStamp(JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) override;

        private:
            void warnUnimplemented(const String& method);

            JSCLogAgentImpl* m_consoleAgent;
        };
    }
}


#endif //KRAKEN_DEBUGGER_JSC_CONSOLE_CLIENT_IMPL_H
