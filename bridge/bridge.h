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

#ifdef KRAKEN_ENABLE_JSA
#include "bindings/jsa/ui_manager.h"
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
#endif

#include <atomic>
#include <vector>
#ifdef ENABLE_DEBUGGER
#include <devtools/frontdoor.h>
#endif // ENABLE_DEBUGGER

namespace kraken {

using namespace alibaba::jsa;

class JSBridge final {
private:
  std::unique_ptr<KRAKEN_JS_CONTEXT> context;
  JSExceptionHandler handler_;

#ifdef KRAKEN_ENABLE_JSA
  std::shared_ptr<kraken::binding::JSScreen> screen_;
  std::shared_ptr<kraken::binding::JSWindow> window_;
  std::shared_ptr<kraken::binding::JSDocument> document_;
#endif

public:
  JSBridge() = delete;
  JSBridge(int32_t contextId, const JSExceptionHandler &handler);
  ~JSBridge();
#ifdef ENABLE_DEBUGGER
  void attachDevtools();
  void detachDevtools();
#endif // ENABLE_DEBUGGER

  std::vector<std::shared_ptr<KRAKEN_JS_VALUE>> krakenUIListenerList;
  std::vector<std::shared_ptr<KRAKEN_JS_VALUE>> krakenModuleListenerList;

  int32_t contextId;
  foundation::BridgeCallback bridgeCallback;
  // the owner pointer which take JSBridge as property.
  void *owner;
  /// evaluate JavaScript source codes in standard mode.
  KRAKEN_JS_VALUE evaluateScript(const NativeString *script, const char *url, int startLine);
  KRAKEN_JS_VALUE evaluateScript(const char *script, const char *url, int startLine);

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
