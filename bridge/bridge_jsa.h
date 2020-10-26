/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BRIDGE_H_
#define KRAKEN_JS_BRIDGE_H_

#ifdef KRAKEN_ENABLE_JSA

#include "foundation/bridge_callback.h"
#include "foundation/js_engine_adaptor.h"
#include "foundation/thread_safe_array.h"
#include "include/kraken_bridge.h"

#include <atomic>
#include <deque>
#include <vector>
#ifdef ENABLE_DEBUGGER
#include <devtools/frontdoor.h>
#endif // ENABLE_DEBUGGER

#include "bindings/jsa/DOM/document.h"
#include "bindings/jsa/DOM/element.h"
#include "bindings/jsa/DOM/eventTarget.h"
#include "bindings/jsa/KOM/blob.h"
#include "bindings/jsa/KOM/console.h"
#include "bindings/jsa/KOM/location.h"
#include "bindings/jsa/KOM/screen.h"
#include "bindings/jsa/KOM/timer.h"
#include "bindings/jsa/KOM/toBlob.h"
#include "bindings/jsa/KOM/window.h"
#include "bindings/jsa/kraken.h"
#include "bindings/jsa/ui_manager.h"

namespace kraken {

using namespace alibaba::jsa;

class JSBridge final {
private:
  std::unique_ptr<KRAKEN_JS_CONTEXT> context;
  JSExceptionHandler handler_;

  std::shared_ptr<kraken::binding::jsa::JSScreen> screen_;
  std::shared_ptr<kraken::binding::jsa::JSWindow> window_;
  std::shared_ptr<kraken::binding::jsa::JSDocument> document_;

public:
  JSBridge() = delete;
  JSBridge(int32_t contextId, const JSExceptionHandler &handler);
  ~JSBridge();
#ifdef ENABLE_DEBUGGER
  void attachDevtools();
  void detachDevtools();
#endif // ENABLE_DEBUGGER

  std::vector<std::shared_ptr<Value>> krakenUIListenerList;
  std::vector<std::shared_ptr<Value>> krakenModuleListenerList;

  int32_t contextId;
  std::unique_ptr<foundation::BridgeCallback> bridgeCallback;
  // the owner pointer which take JSBridge as property.
  void *owner;
  /// evaluate JavaScript source codes in standard mode.
  void evaluateScript(const NativeString *script, const char *url, int startLine);
  void evaluateScript(const char *script, const char *url, int startLine);

  const std::unique_ptr<KRAKEN_JS_CONTEXT> &getContext() const {
    return context;
  }

  void invokeEventListener(int32_t type, const NativeString *args);
  void handleUIListener(const NativeString *args);
  void handleModuleListener(const NativeString *args);
  void reportError(const char *errmsg);
  //#ifdef ENABLE_DEBUGGER
  //  std::unique_ptr<kraken::Debugger::FrontDoor> devtools_front_door_;
  //#endif // ENABLE_DEBUGGER
};
} // namespace kraken

#endif
#endif // KRAKEN_JS_BRIDGE_H_
