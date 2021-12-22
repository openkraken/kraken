/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_LOG_DISPATCHER_IMPL_H
#define KRAKEN_DEBUGGER_LOG_DISPATCHER_IMPL_H

#include "inspector/protocol/dispatcher_base.h"
#include "inspector/protocol/error_support.h"
#include "inspector/protocol/log_backend.h"

#include <functional>
#include <string>
#include <unordered_map>

namespace kraken {
namespace debugger {
class LogDispatcherImpl : public DispatcherBase {
public:
  LogDispatcherImpl(FrontendChannel *frontendChannel, LogBackend *backend)
    : DispatcherBase(frontendChannel), m_backend(backend) {
    m_dispatchMap["Log.clear"] = std::bind(&LogDispatcherImpl::clear, this, std::placeholders::_1,
                                           std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Log.disable"] = std::bind(&LogDispatcherImpl::disable, this, std::placeholders::_1,
                                             std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Log.enable"] = std::bind(&LogDispatcherImpl::enable, this, std::placeholders::_1,
                                            std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    //                m_dispatchMap["Log.startViolationsReport"] =
    //                        std::bind(&LogDispatcherImpl::startViolationsReport,this, std::placeholders::_1,
    //                        std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    //                m_dispatchMap["Log.stopViolationsReport"] =
    //                        std::bind( &LogDispatcherImpl::stopViolationsReport,this, std::placeholders::_1,
    //                        std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
  }
  ~LogDispatcherImpl() override {}
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

  void clear(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void disable(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void enable(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void startViolationsReport(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void stopViolationsReport(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);

  LogBackend *m_backend;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_LOG_DISPATCHER_IMPL_H
