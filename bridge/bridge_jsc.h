/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BRIDGE_H_
#define KRAKEN_JS_BRIDGE_H_

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

#include "bindings/jsc/DOM/document.h"
#include "bindings/jsc/KOM/blob.h"
#include "bindings/jsc/KOM/console.h"
#include "bindings/jsc/KOM/location.h"
#include "bindings/jsc/KOM/screen.h"
#include "bindings/jsc/KOM/timer.h"
#include "bindings/jsc/KOM/toBlob.h"
#include "bindings/jsc/KOM/window.h"
#include "bindings/jsc/js_context.h"
#include "bindings/jsc/kraken.h"
#include "bindings/jsc/ui_manager.h"

namespace kraken {

#ifdef KRAKEN_ENABLE_JSA
using namespace alibaba::jsa;
#endif

class JSBridge final {
public:
  JSBridge() = delete;
  JSBridge(int32_t contextId, const JSExceptionHandler &handler);
  ~JSBridge();
#ifdef ENABLE_DEBUGGER
  void attachDevtools();
  void detachDevtools();
#endif // ENABLE_DEBUGGER

  std::deque<JSObjectRef> krakenUIListenerList;
  std::deque<JSObjectRef> krakenModuleListenerList;

  std::shared_ptr<binding::jsc::JSWindow> _window;

  int32_t contextId;
  foundation::BridgeCallback *bridgeCallback;
  // the owner pointer which take JSBridge as property.
  void *owner;
  /// evaluate JavaScript source codes in standard mode.
  void evaluateScript(const NativeString *script, const char *url, int startLine);
  void evaluateScript(const char *script, const char *url, int startLine);

  const std::unique_ptr<KRAKEN_JS_CONTEXT> &getContext() const {
    return context;
  }

  void invokeEventListener(int32_t type, const NativeString *args);
  void handleUIListener(const NativeString *args, JSValueRef *exception);
  void handleModuleListener(const NativeString *args, JSValueRef *exception);
  void reportError(const char *errmsg);
  //#ifdef ENABLE_DEBUGGER
  //  std::unique_ptr<kraken::Debugger::FrontDoor> devtools_front_door_;
  //#endif // ENABLE_DEBUGGER
private:
  std::unique_ptr<binding::jsc::JSContext> context;
  JSExceptionHandler handler_;
};
} // namespace kraken

#endif // KRAKEN_JS_BRIDGE_H_
