/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_DEBUG_DISPATCHER_IMPL_H
#define KRAKEN_DEBUGGER_DEBUG_DISPATCHER_IMPL_H

#include "inspector/protocol/debugger_backend.h"
#include "inspector/protocol/dispatcher_base.h"

#include <functional>
#include <unordered_map>

namespace kraken::debugger {

class DebugDispatcherImpl : public DispatcherBase {

public:
  DebugDispatcherImpl(FrontendChannel *frontendChannel, DebuggerBackend *backend)
    : DispatcherBase(frontendChannel), m_backend(backend) {
    m_dispatchMap["Debugger.continueToLocation"] =
      std::bind(&DebugDispatcherImpl::continueToLocation, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.disable"] = std::bind(&DebugDispatcherImpl::disable, this, std::placeholders::_1,
                                                  std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.enable"] = std::bind(&DebugDispatcherImpl::enable, this, std::placeholders::_1,
                                                 std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.evaluateOnCallFrame"] =
      std::bind(&DebugDispatcherImpl::evaluateOnCallFrame, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.getPossibleBreakpoints"] =
      std::bind(&DebugDispatcherImpl::getPossibleBreakpoints, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.getScriptSource"] =
      std::bind(&DebugDispatcherImpl::getScriptSource, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.getStackTrace"] =
      std::bind(&DebugDispatcherImpl::getStackTrace, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.pause"] = std::bind(&DebugDispatcherImpl::pause, this, std::placeholders::_1,
                                                std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.pauseOnAsyncCall"] =
      std::bind(&DebugDispatcherImpl::pauseOnAsyncCall, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.removeBreakpoint"] =
      std::bind(&DebugDispatcherImpl::removeBreakpoint, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.restartFrame"] =
      std::bind(&DebugDispatcherImpl::restartFrame, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.resume"] = std::bind(&DebugDispatcherImpl::resume, this, std::placeholders::_1,
                                                 std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.searchInContent"] =
      std::bind(&DebugDispatcherImpl::searchInContent, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setAsyncCallStackDepth"] =
      std::bind(&DebugDispatcherImpl::setAsyncCallStackDepth, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setBlackboxPatterns"] =
      std::bind(&DebugDispatcherImpl::setBlackboxPatterns, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setBlackboxedRanges"] =
      std::bind(&DebugDispatcherImpl::setBlackboxedRanges, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setBreakpoint"] =
      std::bind(&DebugDispatcherImpl::setBreakpoint, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setBreakpointByUrl"] =
      std::bind(&DebugDispatcherImpl::setBreakpointByUrl, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setBreakpointOnFunctionCall"] =
      std::bind(&DebugDispatcherImpl::setBreakpointOnFunctionCall, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setBreakpointsActive"] =
      std::bind(&DebugDispatcherImpl::setBreakpointsActive, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setPauseOnExceptions"] =
      std::bind(&DebugDispatcherImpl::setPauseOnExceptions, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setReturnValue"] =
      std::bind(&DebugDispatcherImpl::setReturnValue, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setScriptSource"] =
      std::bind(&DebugDispatcherImpl::setScriptSource, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setSkipAllPauses"] =
      std::bind(&DebugDispatcherImpl::setSkipAllPauses, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.setVariableValue"] =
      std::bind(&DebugDispatcherImpl::setVariableValue, this, std::placeholders::_1, std::placeholders::_2,
                std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.stepInto"] = std::bind(&DebugDispatcherImpl::stepInto, this, std::placeholders::_1,
                                                   std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.stepOut"] = std::bind(&DebugDispatcherImpl::stepOut, this, std::placeholders::_1,
                                                  std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
    m_dispatchMap["Debugger.stepOver"] = std::bind(&DebugDispatcherImpl::stepOver, this, std::placeholders::_1,
                                                   std::placeholders::_2, std::placeholders::_3, std::placeholders::_4);
  }
  ~DebugDispatcherImpl() override {}

  bool canDispatch(const std::string &method) override;
  void dispatch(uint64_t callId, const std::string &method, JSONObject message) override;
  std::unordered_map<std::string, std::string> &redirects() {
    return m_redirects;
  }

protected:
  DebuggerBackend *m_backend; /*debugger实现*/
  std::unordered_map<std::string, std::string> m_redirects;

  rapidjson::Document m_json_doc;
  using CallHandler = std::function<void(uint64_t /*callId*/, const std::string & /*method*/,
                                         JSONObject /*msg*/, ErrorSupport *)>;
  using DispatchMap = std::unordered_map<std::string, CallHandler>;
  DispatchMap m_dispatchMap;

  /*debugger commands (28)*/

  void continueToLocation(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void disable(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void enable(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void evaluateOnCallFrame(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void getPossibleBreakpoints(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void getScriptSource(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void getStackTrace(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void pause(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void pauseOnAsyncCall(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void removeBreakpoint(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void restartFrame(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void resume(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void searchInContent(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setAsyncCallStackDepth(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setBlackboxPatterns(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setBlackboxedRanges(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setBreakpoint(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setBreakpointByUrl(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setBreakpointOnFunctionCall(uint64_t callId, const std::string &method, JSONObject message,
                                   ErrorSupport *);
  void setBreakpointsActive(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setPauseOnExceptions(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setReturnValue(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setScriptSource(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setSkipAllPauses(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void setVariableValue(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void stepInto(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void stepOut(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
  void stepOver(uint64_t callId, const std::string &method, JSONObject message, ErrorSupport *);
};
} // namespace kraken

#endif // KRAKEN_DEBUGGER_DEBUG_DISPATCHER_IMPL_H
