/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BRIDGE_H_
#define KRAKEN_JS_BRIDGE_H_

#include "bindings/KOM/screen.h"
#include "bindings/KOM/window.h"

#include "bindings/kraken.h"
#include <atomic>
#ifdef ENABLE_DEBUGGER
#include <devtools/frontdoor.h>
#endif // ENABLE_DEBUGGER

namespace kraken {

class JSBridge final {
private:
  std::unique_ptr<alibaba::jsa::JSContext> context;
  std::shared_ptr<kraken::binding::JSScreen> screen_;
  std::shared_ptr<kraken::binding::JSWindow> window_;
  alibaba::jsa::JSExceptionHandler handler_;

public:
  JSBridge() = delete;
  JSBridge(int32_t contextIndex, const alibaba::jsa::JSExceptionHandler& handler);
  ~JSBridge();
#ifdef ENABLE_DEBUGGER
  void attachDevtools();
  void detachDevtools();
#endif // ENABLE_DEBUGGER

  int32_t contextIndex;
  /// evaluate JavaScript source codes in standard mode.
  alibaba::jsa::Value evaluateScript(const std::string &script, const std::string &url, int startLine);

  alibaba::jsa::JSContext *getContext() const {
    return context.get();
  }

  void invokeEventListener(int32_t type, const char *args);
  void handleUIListener(const char *args);
  void handleModuleListener(const char *args);
  //#ifdef ENABLE_DEBUGGER
  //  std::unique_ptr<kraken::Debugger::FrontDoor> devtools_front_door_;
  //#endif // ENABLE_DEBUGGER
};
} // namespace kraken

#endif // KRAKEN_JS_BRIDGE_H_
