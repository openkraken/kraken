/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/protocol/dispatcher_base.h"

namespace kraken {
namespace debugger {

const char DispatcherBase::kInvalidParamsString[] = "Invalid parameters";

DispatcherBase::Callback::Callback(std::unique_ptr<kraken::debugger::DispatcherBase::WeakPtr> backendImpl,
                                   uint64_t callId, const std::string &method,
                                   kraken::debugger::JSONObject message)
  : m_backendImpl(std::move(backendImpl)), m_callId(callId), m_method(method), m_message(std::move(message)) {}

DispatcherBase::Callback::~Callback() = default;

void DispatcherBase::Callback::dispose() {
  m_backendImpl = nullptr;
}

void DispatcherBase::Callback::sendIfActive(kraken::debugger::JSONObject message,
                                            const kraken::debugger::DispatchResponse &response) {
  if (!m_backendImpl || !m_backendImpl->get()) return;
  m_backendImpl->get()->sendResponse(m_callId, response, std::move(message));
  m_backendImpl = nullptr;
}

void DispatcherBase::Callback::fallThroughIfActive() {
  if (!m_backendImpl || !m_backendImpl->get()) return;
  m_backendImpl->get()->channel()->fallThrough(m_callId, m_method, std::move(m_message));
  m_backendImpl = nullptr;
}

/*****************************DispatcherBase::WeakPtr***************************/

DispatcherBase::WeakPtr::WeakPtr(debugger::DispatcherBase *dispatcher) : m_dispatcher(dispatcher) {}

DispatcherBase::WeakPtr::~WeakPtr() {
  if (m_dispatcher) {
    m_dispatcher->m_weakPtrs.erase(this);
  }
}

/**********************************DispatcherBase********************************/
DispatcherBase::DispatcherBase(debugger::FrontendChannel *frontendChannel) : m_frontendChannel(frontendChannel) {}

DispatcherBase::~DispatcherBase() {
  clearFrontend();
}

void DispatcherBase::sendResponse(uint64_t callId, const debugger::DispatchResponse &response) {
  sendResponse(callId, response, JSONObject(rapidjson::kObjectType));
}

void DispatcherBase::sendResponse(uint64_t callId, const debugger::DispatchResponse &response,
                                  debugger::JSONObject result) {
  if (!m_frontendChannel) {
    KRAKEN_LOG(ERROR) << "FrontendChannel invalid...";
    return;
  }
  if (response.status() == DispatchResponse::kError) {
    reportProtocolError(callId, response.errorCode(), response.errorMessage(), nullptr);
    return;
  }
  m_frontendChannel->sendProtocolResponse(
    callId, {callId, std::move(result), JSONObject(rapidjson::kObjectType), false});
}

void DispatcherBase::reportProtocolError(uint64_t callId, debugger::ErrorCode code,
                                         const std::string &errorMessage, debugger::ErrorSupport *errors) {
  Internal::reportProtocolErrorTo(m_frontendChannel, callId, code, errorMessage, errors);
}

void DispatcherBase::clearFrontend() {
  m_frontendChannel = nullptr;
  for (const auto &weak : m_weakPtrs) {
    weak->dispose();
  }
  m_weakPtrs.clear();
}

std::unique_ptr<DispatcherBase::WeakPtr> DispatcherBase::weakPtr() {
  auto weak = std::make_unique<DispatcherBase::WeakPtr>(this);
  m_weakPtrs.insert(weak.get());
  return weak;
}

} // namespace debugger
} // namespace kraken
