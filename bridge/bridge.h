/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BRIDGE_H_
#define KRAKEN_JS_BRIDGE_H_

#include "foundation/bridge_callback.h"
#include "foundation/thread_safe_array.h"
#include "foundation/js_engine_adaptor.h"
#include "include/kraken_bridge.h"

#include <atomic>
#include <vector>
#include <deque>
#ifdef ENABLE_DEBUGGER
#include <devtools/frontdoor.h>
#endif // ENABLE_DEBUGGER

namespace kraken {

#ifdef KRAKEN_ENABLE_JSA
using namespace alibaba::jsa;
#endif

class JSBridge final {
private:
  std::unique_ptr<KRAKEN_JS_CONTEXT> context;
  JSExceptionHandler handler_;

#ifdef KRAKEN_ENABLE_JSA
  std::shared_ptr<kraken::binding::jsa::JSScreen> screen_;
  std::shared_ptr<kraken::binding::jsa::JSWindow> window_;
  std::shared_ptr<kraken::binding::jsa::JSDocument> document_;
#endif

public:
  JSBridge() = delete;
  JSBridge(int32_t contextId, const JSExceptionHandler &handler);
  ~JSBridge();
#ifdef ENABLE_DEBUGGER
  void attachDevtools();
  void detachDevtools();
#endif // ENABLE_DEBUGGER

#ifdef KRAKEN_ENABLE_JSC
  std::vector<std::shared_ptr<Value>> krakenUIListenerList;
  std::vector<std::shared_ptr<Value>> krakenModuleListenerList;
#elif KRAKEN_JSC_ENGINE
  std::deque<JSObjectRef> krakenUIListenerList;
  std::deque<JSObjectRef> krakenModuleListenerList;
#endif

  int32_t contextId;
  foundation::BridgeCallback bridgeCallback;
  // the owner pointer which take JSBridge as property.
  void *owner;
  /// evaluate JavaScript source codes in standard mode.
  void evaluateScript(const NativeString *script, const char *url, int startLine);
  void evaluateScript(const char *script, const char *url, int startLine);

  KRAKEN_JS_CONTEXT *getContext() const {
    return context.get();
  }

  void invokeEventListener(int32_t type, const NativeString *args);
  void handleUIListener(const NativeString *args);
  void handleModuleListener(const NativeString *args);
  void reportError(const char* errmsg);
  //#ifdef ENABLE_DEBUGGER
  //  std::unique_ptr<kraken::Debugger::FrontDoor> devtools_front_door_;
  //#endif // ENABLE_DEBUGGER
};
} // namespace kraken

#endif // KRAKEN_JS_BRIDGE_H_
