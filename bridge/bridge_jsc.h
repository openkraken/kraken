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

namespace kraken {

class JSBridge final {
public:
  static ConsoleMessageHandler consoleMessageHandler;
  JSBridge() = delete;
  JSBridge(int32_t jsContext, const JSExceptionHandler &handler);
  ~JSBridge();

  static std::unordered_map<std::string, NativeString> pluginSourceCode;

  std::deque<JSObjectRef> krakenModuleListenerList;

  int32_t contextId;
  foundation::BridgeCallback *bridgeCallback;
  // the owner pointer which take JSBridge as property.
  void *owner;
  // evaluate JavaScript source codes in standard mode.
  KRAKEN_EXPORT void evaluateScript(const NativeString *script, const char *url, int startLine);
  KRAKEN_EXPORT void parseHTML(const NativeString *script, const char *url);
  KRAKEN_EXPORT void evaluateScript(const std::u16string &script, const char *url, int startLine);
  KRAKEN_EXPORT void setHref(const char *url);
  KRAKEN_EXPORT NativeString* getHref();

  const std::unique_ptr<kraken::binding::jsc::JSContext> &getContext() const {
    return m_context;
  }

  void invokeModuleEvent(NativeString *moduleName, const char *eventType, void *event, NativeString *extra);
  void reportError(const char *errmsg);
  void setDisposeCallback(Task task, void *data);

  std::atomic<bool> event_registered = false;
private:
  std::unique_ptr<binding::jsc::JSContext> m_context;
  JSExceptionHandler m_handler;
  Task m_disposeCallback{nullptr};
  void *m_disposePrivateData{nullptr};
};

} // namespace kraken

#endif
#endif // KRAKEN_JS_BRIDGE_H_
