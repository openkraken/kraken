/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "heap_profiler_dispatcher_impl.h"

namespace kraken {
namespace debugger {

bool HeapProfilerDispatcherImpl::canDispatch(const std::string &method) {
  return m_dispatchMap.find(method) != m_dispatchMap.end();
}

void HeapProfilerDispatcherImpl::dispatch(uint64_t callId, const std::string &method,
                                          kraken::debugger::JSONObject message) {
  std::unordered_map<std::string, CallHandler>::iterator it = m_dispatchMap.find(method);
  if (it == m_dispatchMap.end()) {
    return;
  }
  ErrorSupport errors;
  (it->second)(callId, method, std::move(message), &errors);
}

void HeapProfilerDispatcherImpl::enable(uint64_t callId, const std::string &method,
                                        kraken::debugger::JSONObject message,
                                        kraken::debugger::ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->enable();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void HeapProfilerDispatcherImpl::disable(uint64_t callId, const std::string &method,
                                         kraken::debugger::JSONObject message,
                                         kraken::debugger::ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->disable();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void HeapProfilerDispatcherImpl::collectGarbage(uint64_t callId, const std::string &method,
                                                kraken::debugger::JSONObject message,
                                                kraken::debugger::ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->collectGarbage();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void HeapProfilerDispatcherImpl::addInspectedHeapObject(uint64_t callId, const std::string &method,
                                                        kraken::debugger::JSONObject message,
                                                        kraken::debugger::ErrorSupport *) {}

void HeapProfilerDispatcherImpl::getHeapObjectId(uint64_t callId, const std::string &method,
                                                 kraken::debugger::JSONObject message,
                                                 kraken::debugger::ErrorSupport *) {}

void HeapProfilerDispatcherImpl::getObjectByHeapObjectId(uint64_t callId, const std::string &method,
                                                         kraken::debugger::JSONObject message,
                                                         kraken::debugger::ErrorSupport *) {}

void HeapProfilerDispatcherImpl::getSamplingProfile(uint64_t callId, const std::string &method,
                                                    kraken::debugger::JSONObject message,
                                                    kraken::debugger::ErrorSupport *) {}

void HeapProfilerDispatcherImpl::startSampling(uint64_t callId, const std::string &method,
                                               kraken::debugger::JSONObject message,
                                               kraken::debugger::ErrorSupport *) {}

void HeapProfilerDispatcherImpl::startTrackingHeapObjects(uint64_t callId, const std::string &method,
                                                          kraken::debugger::JSONObject message,
                                                          kraken::debugger::ErrorSupport *) {}

void HeapProfilerDispatcherImpl::stopSampling(uint64_t callId, const std::string &method,
                                              kraken::debugger::JSONObject message,
                                              kraken::debugger::ErrorSupport *) {}

void HeapProfilerDispatcherImpl::stopTrackingHeapObjects(uint64_t callId, const std::string &method,
                                                         kraken::debugger::JSONObject message,
                                                         kraken::debugger::ErrorSupport *) {}

void HeapProfilerDispatcherImpl::takeHeapSnapshot(uint64_t callId, const std::string &method,
                                                  kraken::debugger::JSONObject message,
                                                  kraken::debugger::ErrorSupport *) {}

} // namespace debugger
} // namespace kraken
