/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_RUNTIME_DISPATCHER_IMPL_H
#define KRAKEN_DEBUGGER_RUNTIME_DISPATCHER_IMPL_H

#include "inspector/protocol/dispatcher_base.h"
#include "inspector/protocol/error_support.h"
#include "inspector/protocol/frontend_channel.h"
#include "inspector/protocol/runtime_backend.h"

#include <functional>
#include <string>
#include <unordered_map>

namespace kraken {
namespace debugger {
class RuntimeDispatcherImpl : public DispatcherBase {
public:
  RuntimeDispatcherImpl(FrontendChannel *frontendChannel, RuntimeBackend *backend)
    : DispatcherBase(frontendChannel), m_backend(backend) {
    m_dispatchMap["Runtime.awaitPromise"] =
      std::bind(&RuntimeDispatcherImpl::awaitPromise, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.callFunctionOn"] =
      std::bind(&RuntimeDispatcherImpl::callFunctionOn, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.compileScript"] =
      std::bind(&RuntimeDispatcherImpl::compileScript, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.disable"] = std::bind(&RuntimeDispatcherImpl::disable, this, std::placeholders::_1,
                                                 std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.discardConsoleEntries"] =
      std::bind(&RuntimeDispatcherImpl::discardConsoleEntries, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.enable"] = std::bind(&RuntimeDispatcherImpl::enable, this, std::placeholders::_1,
                                                std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.evaluate"] = std::bind(&RuntimeDispatcherImpl::evaluate, this, std::placeholders::_1,
                                                  std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.getIsolateId"] =
      std::bind(&RuntimeDispatcherImpl::getIsolateId, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.getHeapUsage"] =
      std::bind(&RuntimeDispatcherImpl::getHeapUsage, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.getProperties"] =
      std::bind(&RuntimeDispatcherImpl::getProperties, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.globalLexicalScopeNames"] =
      std::bind(&RuntimeDispatcherImpl::globalLexicalScopeNames, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.queryObjects"] =
      std::bind(&RuntimeDispatcherImpl::queryObjects, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.releaseObject"] =
      std::bind(&RuntimeDispatcherImpl::releaseObject, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.releaseObjectGroup"] =
      std::bind(&RuntimeDispatcherImpl::releaseObjectGroup, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.runIfWaitingForDebugger"] =
      std::bind(&RuntimeDispatcherImpl::runIfWaitingForDebugger, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.runScript"] = std::bind(&RuntimeDispatcherImpl::runScript, this, std::placeholders::_1,
                                                   std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_redirects["Runtime.setAsyncCallStackDepth"] = "Debugger.setAsyncCallStackDepth";
    m_dispatchMap["Runtime.setCustomObjectFormatterEnabled"] =
      std::bind(&RuntimeDispatcherImpl::setCustomObjectFormatterEnabled, this, std::placeholders::_1,
                std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.setMaxCallStackSizeToCapture"] =
      std::bind(&RuntimeDispatcherImpl::setMaxCallStackSizeToCapture, this, std::placeholders::_1,
                std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.terminateExecution"] =
      std::bind(&RuntimeDispatcherImpl::terminateExecution, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.addBinding"] =
      std::bind(&RuntimeDispatcherImpl::addBinding, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Runtime.removeBinding"] =
      std::bind(&RuntimeDispatcherImpl::removeBinding, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
  }

  ~RuntimeDispatcherImpl() override {}
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

  RuntimeBackend *m_backend;
  rapidjson::Document m_json_doc;

  /*runtime commands*/
  void awaitPromise(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void callFunctionOn(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void compileScript(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void disable(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void discardConsoleEntries(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void enable(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void evaluate(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void getIsolateId(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void getHeapUsage(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void getProperties(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void globalLexicalScopeNames(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void queryObjects(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void releaseObject(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void releaseObjectGroup(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void runIfWaitingForDebugger(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void runScript(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setCustomObjectFormatterEnabled(uint64_t callId, const std::string &method, JSONObject message,
                                       ErrorSupport *);
  void setMaxCallStackSizeToCapture(uint64_t callId, const std::string &method, JSONObject message,
                                    ErrorSupport *);
  void terminateExecution(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void addBinding(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void removeBinding(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_RUNTIME_DISPATCHER_IMPL_H
