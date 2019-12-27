//
// Created by rowandjj on 2019/4/2.
//
#include "devtools/protocol/dispatcher_base.h"

namespace kraken{
    namespace Debugger {

        const char DispatcherBase::kInvalidParamsString[] = "Invalid parameters";

        DispatcherBase::Callback::Callback(
                std::unique_ptr<kraken::Debugger::DispatcherBase::WeakPtr> backendImpl, uint64_t callId,
                const std::string &method, kraken::Debugger::jsonRpc::JSONObject message):
                m_backendImpl(std::move(backendImpl)),
                m_callId(callId),
                m_method(method),
                m_message(std::move(message))
                {}

        DispatcherBase::Callback::~Callback() = default;

        void DispatcherBase::Callback::dispose() {
            m_backendImpl = nullptr;
        }

        void DispatcherBase::Callback::sendIfActive(kraken::Debugger::jsonRpc::JSONObject message,
                                                    const kraken::Debugger::DispatchResponse &response) {
            if (!m_backendImpl || !m_backendImpl->get())
                return;
            m_backendImpl->get()->sendResponse(m_callId, response, std::move(message));
            m_backendImpl = nullptr;
        }

        void DispatcherBase::Callback::fallThroughIfActive() {
            if (!m_backendImpl || !m_backendImpl->get())
                return;
            m_backendImpl->get()->channel()->fallThrough(m_callId, m_method, std::move(m_message));
            m_backendImpl = nullptr;
        }

        /*****************************DispatcherBase::WeakPtr***************************/

        DispatcherBase::WeakPtr::WeakPtr(Debugger::DispatcherBase *dispatcher)
                :m_dispatcher(dispatcher) {
        }

        DispatcherBase::WeakPtr::~WeakPtr() {
            if(m_dispatcher) {
                m_dispatcher->m_weakPtrs.erase(this);
            }
        }

        /**********************************DispatcherBase********************************/
        DispatcherBase::DispatcherBase(Debugger::FrontendChannel *frontendChannel)
                :m_frontendChannel(frontendChannel) {
        }

        DispatcherBase::~DispatcherBase() {
            clearFrontend();
        }


        void DispatcherBase::sendResponse(uint64_t callId, const Debugger::DispatchResponse &response) {
            sendResponse(callId, response, jsonRpc::JSONObject(rapidjson::kObjectType));
        }

        void DispatcherBase::sendResponse(uint64_t callId,
                                          const Debugger::DispatchResponse &response,
                                          Debugger::jsonRpc::JSONObject result) {
            if(!m_frontendChannel) {
                KRAKEN_LOG(ERROR) << "FrontendChannel invalid...";
                return;
            }
            if(response.status() == DispatchResponse::kError) {
                reportProtocolError(callId, response.errorCode(), response.errorMessage(), nullptr);
                return;
            }
            m_frontendChannel->sendProtocolResponse(callId, {callId, std::move(result), jsonRpc::JSONObject(rapidjson::kObjectType), false});
        }

        void DispatcherBase::reportProtocolError(uint64_t callId,
                                                 Debugger::jsonRpc::ErrorCode code,
                                                 const std::string &errorMessage,
                                                 Debugger::ErrorSupport *errors) {
            Internal::reportProtocolErrorTo(m_frontendChannel, callId, code, errorMessage, errors);
        }

        void DispatcherBase::clearFrontend() {
            m_frontendChannel = nullptr;
            for(const auto& weak : m_weakPtrs) {
                weak->dispose();
            }
            m_weakPtrs.clear();
        }

        std::unique_ptr<DispatcherBase::WeakPtr> DispatcherBase::weakPtr() {
            auto weak = std::make_unique<DispatcherBase::WeakPtr>(this);
            m_weakPtrs.insert(weak.get());
            return weak;
        }

    }
}