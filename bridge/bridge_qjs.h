/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_QJS_BRIDGE_H_
#define KRAKEN_JS_QJS_BRIDGE_H_

#include <quickjs/quickjs.h>
#include "bindings/qjs/html_parser.h"
#include "bindings/qjs/js_context.h"
#include "include/kraken_bridge.h"

#include <atomic>
#include <deque>
#include <vector>

namespace kraken {

class JSBridge;
using JSBridgeDisposeCallback = void (*)(JSBridge* bridge);

class JSBridge final {
 public:
  static ConsoleMessageHandler consoleMessageHandler;
  JSBridge() = delete;
  JSBridge(int32_t jsContext, const JSExceptionHandler& handler);
  ~JSBridge();

  static std::unordered_map<std::string, NativeByteCode> pluginByteCode;

  int32_t contextId;
  // the owner pointer which take JSBridge as property.
  void* owner;
  JSBridgeDisposeCallback disposeCallback{nullptr};
  // evaluate JavaScript source codes in standard mode.
  void evaluateScript(const NativeString* script, const char* url, int startLine);
  void evaluateScript(const uint16_t* script, size_t length, const char* url, int startLine);
  bool parseHTML(const char* code, size_t length);
  void evaluateScript(const char* script, size_t length, const char* url, int startLine);
  uint8_t* dumpByteCode(const char* script, size_t length, const char* url, size_t* byteLength);
  void evaluateByteCode(uint8_t* bytes, size_t byteLength);

  const std::unique_ptr<kraken::binding::qjs::JSContext>& getContext() const { return m_context; }

  void invokeModuleEvent(NativeString* moduleName, const char* eventType, void* event, NativeString* extra);
  void reportError(const char* errmsg);
  void setDisposeCallback(Task task, void* data);

  std::atomic<bool> event_registered = false;

 private:
  std::unique_ptr<binding::qjs::JSContext> m_context;
  JSExceptionHandler m_handler;
  Task m_disposeCallback{nullptr};
  void* m_disposePrivateData{nullptr};
};

}  // namespace kraken

#endif  // KRAKEN_JS_QJS_BRIDGE_H_
