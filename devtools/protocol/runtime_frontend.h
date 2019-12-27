//
// Created by rowandjj on 2019/4/17.
//

#ifndef KRAKEN_DEBUGGER_RUNTIME_FRONTEND_H
#define KRAKEN_DEBUGGER_RUNTIME_FRONTEND_H

#include "devtools/protocol/frontend_channel.h"
#include "devtools/protocol/remote_object.h"
#include "devtools/protocol/stacktrace.h"
#include "devtools/protocol/maybe.h"
#include "devtools/protocol/exception_details.h"
#include "devtools/protocol/execution_context_description.h"

#include <string>
#include <memory>
#include <vector>

namespace kraken{
    namespace Debugger {
        class RuntimeFrontend {
        public:
            explicit RuntimeFrontend(FrontendChannel* frontendChannel)
                    : m_frontendChannel(frontendChannel) {
            }

            void bindingCalled(const std::string& name, const std::string& payload, int executionContextId);
            void consoleAPICalled(const std::string& type,
                                  std::unique_ptr<std::vector<std::unique_ptr<RemoteObject>>> args,
                                  int executionContextId,
                                  double timestamp,
                                  Maybe<StackTrace> stackTrace = Maybe<StackTrace>(),
                                  Maybe<std::string> context = Maybe<std::string>());

            void exceptionRevoked(const std::string& reason, int exceptionId);
            void exceptionThrown(double timestamp, std::unique_ptr<ExceptionDetails> exceptionDetails);
            void executionContextCreated(std::unique_ptr<ExecutionContextDescription> context);
            void executionContextDestroyed(int executionContextId);
            void executionContextsCleared();
            void inspectRequested(std::unique_ptr<RemoteObject> object, std::unique_ptr<rapidjson::Value> hints);

        private:
            FrontendChannel* m_frontendChannel;
        };
    }
}

#endif //KRAKEN_DEBUGGER_RUNTIME_FRONTEND_H
