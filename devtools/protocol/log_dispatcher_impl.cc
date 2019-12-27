//
// Created by rowandjj on 2019/4/24.
//

#include "log_dispatcher_impl.h"
#include "foundation/time_point.h"

namespace kraken{
    namespace Debugger {

        static const char* welcome = " _  __          _              \n"
                                     "| |/ /         | |             \n"
                                     "| ' / _ __ __ _| | _____ _ __  \n"
                                     "|  < | '__/ _` | |/ / _ \\ '_ \\ \n"
                                     "| . \\| | | (_| |   <  __/ | | |\n"
                                     "|_|\\_\\_|  \\__,_|_|\\_\\___|_| |_|\n welcome to kraken devtools";

        bool LogDispatcherImpl::canDispatch(const std::string &method) {
            return m_dispatchMap.find(method) != m_dispatchMap.end();
        }

        void LogDispatcherImpl::dispatch(uint64_t callId, const std::string &method,
                                         kraken::Debugger::jsonRpc::JSONObject message) {
            std::unordered_map<std::string, CallHandler>::iterator it = m_dispatchMap.find(method);
            if(it == m_dispatchMap.end()) {
                return;
            }
            ErrorSupport errors;
            (it->second)(callId, method, std::move(message), &errors);
        }

        /////////

        void LogDispatcherImpl::enable(uint64_t callId, const std::string &method,
                                       kraken::Debugger::jsonRpc::JSONObject message,
                                       kraken::Debugger::ErrorSupport *) {
            std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
            DispatchResponse response = m_backend->enable();
            if (response.status() == DispatchResponse::kFallThrough) {
                channel()->fallThrough(callId, method, std::move(message));
                return;
            }
            if (weak->get())
                weak->get()->sendResponse(callId, response);

            // welcome message
            auto logEntry = LogEntry::create()
                    .setLevel(LogEntry::LevelEnum::Verbose)
                    .setTimestamp(foundation::TimePoint::Now().ToEpochDelta().ToMilliseconds())
                    .setSource(LogEntry::SourceEnum::Javascript)
                    .setText(welcome)
                    .build();
            m_backend->addMessageToConsole(std::move(logEntry));
            return;
        }

        void LogDispatcherImpl::disable(uint64_t callId, const std::string &method,
                                        kraken::Debugger::jsonRpc::JSONObject message,
                                        kraken::Debugger::ErrorSupport *) {
            std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
            DispatchResponse response = m_backend->disable();
            if (response.status() == DispatchResponse::kFallThrough) {
                channel()->fallThrough(callId, method, std::move(message));
                return;
            }
            if (weak->get())
                weak->get()->sendResponse(callId, response);
            return;
        }

        void LogDispatcherImpl::clear(uint64_t callId, const std::string &method,
                                      kraken::Debugger::jsonRpc::JSONObject message,
                                      kraken::Debugger::ErrorSupport *) {
            std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
            DispatchResponse response = m_backend->clear();
            if (response.status() == DispatchResponse::kFallThrough) {
                channel()->fallThrough(callId, method, std::move(message));
                return;
            }
            if (weak->get())
                weak->get()->sendResponse(callId, response);
            return;
        }

        void LogDispatcherImpl::startViolationsReport(uint64_t callId, const std::string &method,
                                                      kraken::Debugger::jsonRpc::JSONObject message,
                                                      kraken::Debugger::ErrorSupport *) {
            // TODO
        }

        void LogDispatcherImpl::stopViolationsReport(uint64_t callId, const std::string &method,
                                                     kraken::Debugger::jsonRpc::JSONObject message,
                                                     kraken::Debugger::ErrorSupport *) {
            // TODO
        }

    }
}