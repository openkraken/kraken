/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BRIDGE_H_
#define KRAKEN_JS_BRIDGE_H_

#include "bindings/KOM/screen.h"
#include "bindings/KOM/window.h"
#include "foundation/thread_safe_array.h"
#include "foundation/bridge_callback.h"
#include "include/kraken_bridge.h"

#include "bindings/kraken.h"
#include <atomic>
#include <vector>
#ifdef ENABLE_DEBUGGER
#include <devtools/frontdoor.h>
#endif // ENABLE_DEBUGGER

namespace kraken {

using namespace alibaba::jsa;

class JSBridge final {
private:
  std::unique_ptr<alibaba::jsa::JSContext> context;
  std::shared_ptr<kraken::binding::JSScreen> screen_;
  std::shared_ptr<kraken::binding::JSWindow> window_;
  alibaba::jsa::JSExceptionHandler handler_;

public:
  JSBridge() = delete;
  JSBridge(int32_t contextId, const alibaba::jsa::JSExceptionHandler& handler);
  ~JSBridge();
#ifdef ENABLE_DEBUGGER
  void attachDevtools();
  void detachDevtools();
#endif // ENABLE_DEBUGGER

  std::vector<std::shared_ptr<Value>> krakenUIListenerList;
  std::vector<std::shared_ptr<Value>> krakenModuleListenerList;

  int32_t contextId;
  foundation::BridgeCallback bridgeCallback;
  // the owner pointer which take JSBridge as property.
  void *owner;
  /// evaluate JavaScript source codes in standard mode.
  alibaba::jsa::Value evaluateScript(const NativeString * script, const char* url, int startLine);

  alibaba::jsa::JSContext *getContext() const {
    return context.get();
  }

  void invokeEventListener(int32_t type, const NativeString *args);
  void handleUIListener(const NativeString *args);
  void handleModuleListener(const NativeString *args);
  //#ifdef ENABLE_DEBUGGER
  //  std::unique_ptr<kraken::Debugger::FrontDoor> devtools_front_door_;
  //#endif // ENABLE_DEBUGGER
};
} // namespace kraken

#endif // KRAKEN_JS_BRIDGE_H_
