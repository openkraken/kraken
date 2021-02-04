/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BRIDGE_H_
#define KRAKEN_JS_BRIDGE_H_

#ifndef  KRAKEN_ENABLE_JSA

#include "foundation/bridge_callback.h"
#include "foundation/thread_safe_array.h"
#include "include/kraken_bridge.h"

#include <atomic>
#include <deque>
#include <vector>
#ifdef ENABLE_DEBUGGER
#include <devtools/frontdoor.h>
#endif // ENABLE_DEBUGGER

#include "bindings/jsc/DOM/comment_node.h"
#include "bindings/jsc/DOM/custom_event.h"
#include "bindings/jsc/DOM/document.h"
#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/DOM/elements/image_element.h"
#include "bindings/jsc/DOM/elements/input_element.h"
#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/DOM/event_target.h"
#include "bindings/jsc/DOM/events/close_event.h"
#include "bindings/jsc/DOM/events/input_event.h"
#include "bindings/jsc/DOM/events/intersection_change_event.h"
#include "bindings/jsc/DOM/events/media_error_event.h"
#include "bindings/jsc/DOM/events/message_event.h"
#include "bindings/jsc/DOM/events/touch_event.h"
#include "bindings/jsc/DOM/node.h"
#include "bindings/jsc/DOM/style_declaration.h"
#include "bindings/jsc/DOM/text_node.h"
#include "bindings/jsc/KOM/blob.h"
#include "bindings/jsc/KOM/console.h"
#include "bindings/jsc/KOM/location.h"
#include "bindings/jsc/KOM/performance.h"
#include "bindings/jsc/KOM/screen.h"
#include "bindings/jsc/KOM/window.h"
#include "bindings/jsc/js_context_internal.h"
#include "bindings/jsc/kraken.h"
#include "bindings/jsc/ui_manager.h"

namespace kraken {

class JSBridge final {
public:
  JSBridge() = delete;
  JSBridge(int32_t jsContext, const JSExceptionHandler &handler);
  ~JSBridge();
#ifdef ENABLE_DEBUGGER
  void attachDevtools();
  void detachDevtools();
#endif // ENABLE_DEBUGGER

  std::deque<JSObjectRef> krakenModuleListenerList;

  int32_t contextId;
  foundation::BridgeCallback *bridgeCallback;
  // the owner pointer which take JSBridge as property.
  void *owner;
  /// evaluate JavaScript source codes in standard mode.
  void evaluateScript(const NativeString *script, const char *url, int startLine);
  void evaluateScript(const std::u16string& script, const char *url, int startLine);

  const std::unique_ptr<kraken::binding::jsc::JSContext> &getContext() const {
    return context;
  }

  void invokeEventListener(int32_t type, const NativeString *args);
  void handleModuleListener(const NativeString *args, JSValueRef *exception);
  void reportError(const char *errmsg);

  std::atomic<bool> event_registered = false;

  //#ifdef ENABLE_DEBUGGER
  //  std::unique_ptr<kraken::Debugger::FrontDoor> devtools_front_door_;
  //#endif // ENABLE_DEBUGGER
private:
  std::unique_ptr<binding::jsc::JSContext> context;
  JSExceptionHandler handler_;
};
} // namespace kraken

#endif
#endif // KRAKEN_JS_BRIDGE_H_
