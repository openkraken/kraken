//
// Created by rowandjj on 2019/4/23.
//

#include "page_dispatcher_impl.h"

namespace kraken{
    namespace Debugger {
        bool PageDispatcherImpl::canDispatch(const std::string &method) {
            return m_dispatchMap.find(method) != m_dispatchMap.end();
        }

        void PageDispatcherImpl::dispatch(uint64_t callId, const std::string &method,
                                          kraken::Debugger::jsonRpc::JSONObject message) {
            std::unordered_map<std::string, CallHandler>::iterator it = m_dispatchMap.find(method);
            if(it == m_dispatchMap.end()) {
                return;
            }
            ErrorSupport errors;
            (it->second)(callId, method, std::move(message), &errors);
        }

        //--------------------------------------

        void PageDispatcherImpl::enable(uint64_t callId, const std::string &method,
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
            return;
        }

        void PageDispatcherImpl::disable(uint64_t callId, const std::string &method,
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

        void PageDispatcherImpl::reload(uint64_t callId, const std::string &method,
                                        kraken::Debugger::jsonRpc::JSONObject message,
                                        kraken::Debugger::ErrorSupport *errors) {
            // Prepare input parameters.
            errors->push();

            Maybe<bool> in_ignoreCache;
            if(message.HasMember("ignoreCache")) {
                errors->setName("ignoreCache");
                if(message["ignoreCache"].IsBool()) {
                    in_ignoreCache = message["ignoreCache"].GetBool();
                } else {
                    errors->addError("ignoreCache should be bool");
                }
            }


            Maybe<std::string> in_scriptToEvaluateOnLoad;
            if(message.HasMember("scriptToEvaluateOnLoad")) {
                errors->setName("scriptToEvaluateOnLoad");
                if(message["scriptToEvaluateOnLoad"].IsString()) {
                    in_scriptToEvaluateOnLoad = message["scriptToEvaluateOnLoad"].GetString();
                } else {
                    errors->addError("scriptToEvaluateOnLoad should be string");
                }
            }

            errors->pop();
            if (errors->hasErrors()) {
                reportProtocolError(callId, jsonRpc::kInvalidParams, kInvalidParamsString, errors);
                return;
            }

            std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
            DispatchResponse response = m_backend->reload(std::move(in_ignoreCache), std::move(in_scriptToEvaluateOnLoad));
            if (response.status() == DispatchResponse::kFallThrough) {
                channel()->fallThrough(callId, method, std::move(message));
                return;
            }
            if (weak->get())
                weak->get()->sendResponse(callId, response);
            return;
        }

    }
}