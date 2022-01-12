/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_HEAP_PROFILER_DISPATCHER_IMPL_H
#define KRAKEN_DEBUGGER_HEAP_PROFILER_DISPATCHER_IMPL_H

#include "inspector/protocol/dispatcher_base.h"
#include "inspector/protocol/error_support.h"
#include "inspector/protocol/heap_profiler_backend.h"

#include <functional>
#include <string>
#include <unordered_map>

namespace kraken {
namespace debugger {
class HeapProfilerDispatcherImpl : public DispatcherBase {
public:
  HeapProfilerDispatcherImpl(FrontendChannel *frontendChannel, HeapProfilerBackend *backend)
    : DispatcherBase(frontendChannel), m_backend(backend) {

    m_dispatchMap["HeapProfiler.addInspectedHeapObject"] =
      std::bind(&HeapProfilerDispatcherImpl::addInspectedHeapObject, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.collectGarbage"] =
      std::bind(&HeapProfilerDispatcherImpl::collectGarbage, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.disable"] =
      std::bind(&HeapProfilerDispatcherImpl::disable, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.enable"] =
      std::bind(&HeapProfilerDispatcherImpl::enable, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.getHeapObjectId"] =
      std::bind(&HeapProfilerDispatcherImpl::getHeapObjectId, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.getObjectByHeapObjectId"] =
      std::bind(&HeapProfilerDispatcherImpl::getObjectByHeapObjectId, this, std::placeholders::_1,
                std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.getSamplingProfile"] =
      std::bind(&HeapProfilerDispatcherImpl::getSamplingProfile, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.startSampling"] =
      std::bind(&HeapProfilerDispatcherImpl::startSampling, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.startTrackingHeapObjects"] =
      std::bind(&HeapProfilerDispatcherImpl::startTrackingHeapObjects, this, std::placeholders::_1,
                std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.stopSampling"] =
      std::bind(&HeapProfilerDispatcherImpl::stopSampling, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.stopTrackingHeapObjects"] =
      std::bind(&HeapProfilerDispatcherImpl::stopTrackingHeapObjects, this, std::placeholders::_1,
                std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["HeapProfiler.takeHeapSnapshot"] =
      std::bind(&HeapProfilerDispatcherImpl::takeHeapSnapshot, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
  }

  ~HeapProfilerDispatcherImpl() override {}

  bool canDispatch(const std::string &method) override;
  void dispatch(uint64_t callId, const std::string &method, JSONObject message) override;
  std::unordered_map<std::string, std::string> &redirects() {
    return m_redirects;
  }

protected:
  using CallHandler = std::function<void(uint64_t /*callId*/, const std::string & /*method*/,
                                         JSONObject /*msg*/, ErrorSupport *)>;
  using DispatchMap = std::unordered_map<std::string, CallHandler>;

  DispatchMap m_dispatchMap;
  std::unordered_map<std::string, std::string> m_redirects;

  void addInspectedHeapObject(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void collectGarbage(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void disable(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void enable(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void getHeapObjectId(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void getObjectByHeapObjectId(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void getSamplingProfile(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void startSampling(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void startTrackingHeapObjects(uint64_t callId, const std::string &method, JSONObject message,
                                ErrorSupport *);
  void stopSampling(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void stopTrackingHeapObjects(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void takeHeapSnapshot(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);

  HeapProfilerBackend *m_backend;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_HEAP_PROFILER_DISPATCHER_IMPL_H
