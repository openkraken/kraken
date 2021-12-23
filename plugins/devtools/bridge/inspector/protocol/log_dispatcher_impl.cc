/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "log_dispatcher_impl.h"

namespace kraken {
namespace debugger {

bool LogDispatcherImpl::canDispatch(const std::string &method) {
  return m_dispatchMap.find(method) != m_dispatchMap.end();
}

void LogDispatcherImpl::dispatch(uint64_t callId, const std::string &method,
                                 kraken::debugger::JSONObject message) {
  std::unordered_map<std::string, CallHandler>::iterator it = m_dispatchMap.find(method);
  if (it == m_dispatchMap.end()) {
    return;
  }
  ErrorSupport errors;
  (it->second)(callId, method, std::move(message), &errors);
}

/////////

void LogDispatcherImpl::enable(uint64_t callId, const std::string &method,
                               kraken::debugger::JSONObject message, kraken::debugger::ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->enable();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void LogDispatcherImpl::disable(uint64_t callId, const std::string &method,
                                kraken::debugger::JSONObject message, kraken::debugger::ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->disable();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void LogDispatcherImpl::clear(uint64_t callId, const std::string &method, kraken::debugger::JSONObject message,
                              kraken::debugger::ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->clear();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void LogDispatcherImpl::startViolationsReport(uint64_t callId, const std::string &method,
                                              kraken::debugger::JSONObject message,
                                              kraken::debugger::ErrorSupport *) {
  // TODO
}

void LogDispatcherImpl::stopViolationsReport(uint64_t callId, const std::string &method,
                                             kraken::debugger::JSONObject message,
                                             kraken::debugger::ErrorSupport *) {
  // TODO
}

} // namespace debugger
} // namespace kraken
