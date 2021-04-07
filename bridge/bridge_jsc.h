/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BRIDGE_H_
#define KRAKEN_JS_BRIDGE_H_

#ifndef KRAKEN_ENABLE_JSA

#include "foundation/bridge_callback.h"
#include "include/kraken_bridge.h"

#include <atomic>
#include <deque>
#include <vector>

#ifdef ENABLE_DEBUGGER
#include "inspector/frontdoor.h"
#include "inspector/protocol_handler.h"
#endif // ENABLE_DEBUGGER

namespace kraken {

class JSBridge final {
public:
  JSBridge() = delete;
  JSBridge(int32_t jsContext, const JSExceptionHandler &handler);
  ~JSBridge();
#ifdef ENABLE_DEBUGGER
  void attachInspector();
#endif // ENABLE_DEBUGGER

  static std::unordered_map<std::string, NativeString> pluginSourceCode;

  std::deque<JSObjectRef> krakenModuleListenerList;

  int32_t contextId;
  foundation::BridgeCallback *bridgeCallback;
  // the owner pointer which take JSBridge as property.
  void *owner;
  /// evaluate JavaScript source codes in standard mode.
  KRAKEN_EXPORT void evaluateScript(const NativeString *script, const char *url, int startLine);
  KRAKEN_EXPORT void evaluateScript(const std::u16string &script, const char *url, int startLine);

  const std::unique_ptr<kraken::binding::jsc::JSContext> &getContext() const {
    return context;
  }

  void invokeModuleEvent(NativeString *moduleName, const char *eventType, void *event, NativeString *extra);
  void reportError(const char *errmsg);

  std::atomic<bool> event_registered = false;

  #ifdef ENABLE_DEBUGGER
    std::shared_ptr<debugger::FrontDoor> m_inspector;
  #endif // ENABLE_DEBUGGER
private:
  std::unique_ptr<binding::jsc::JSContext> context;
  JSExceptionHandler handler_;
};

#if ENABLE_DEBUGGER
class BridgeProtocolHandler : public debugger::ProtocolHandler {
public:
  BridgeProtocolHandler(JSBridge *bridge): m_bridge(bridge) {};
  ~BridgeProtocolHandler(){

  };
  void handlePageReload() override;

private:
  JSBridge *m_bridge{nullptr};
};
#endif

} // namespace kraken

#endif
#endif // KRAKEN_JS_BRIDGE_H_
