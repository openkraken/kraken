/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_QJS_BRIDGE_H_
#define KRAKEN_JS_QJS_BRIDGE_H_

#include <quickjs/quickjs.h>
#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/html_parser.h"
#include "include/kraken_bridge.h"

#include <atomic>
#include <deque>
#include <vector>

namespace kraken {

class KrakenPage;
using JSBridgeDisposeCallback = void (*)(KrakenPage* bridge);

/// KrakenPage is class which manage all js objects create by <Kraken> flutter widget.
/// Every <Kraken> flutter widgets have a corresponding KrakenPage, and all objects created by JavaScript are stored here,
/// and there is no data sharing between objects between different KrakenPages.
/// It's safe to allocate many KrakenPages at the same times on one thread, but not safe for multi-threads, only one thread can enter to KrakenPage at the same time.
class KrakenPage final {
 public:
  static ConsoleMessageHandler consoleMessageHandler;
  KrakenPage() = delete;
  KrakenPage(int32_t jsContext, const JSExceptionHandler& handler);
  ~KrakenPage();

  // Bytecodes which registered by kraken plugins.
  static std::unordered_map<std::string, NativeByteCode> pluginByteCode;

  // evaluate JavaScript source codes in standard mode.
  void evaluateScript(const NativeString* script, const char* url, int startLine);
  void evaluateScript(const uint16_t* script, size_t length, const char* url, int startLine);
  bool parseHTML(const char* code, size_t length);
  void evaluateScript(const char* script, size_t length, const char* url, int startLine);
  uint8_t* dumpByteCode(const char* script, size_t length, const char* url, size_t* byteLength);
  void evaluateByteCode(uint8_t* bytes, size_t byteLength);

  [[nodiscard]] const std::unique_ptr<kraken::binding::qjs::ExecutionContext>& getContext() const { return m_context; }

  void invokeModuleEvent(NativeString* moduleName, const char* eventType, void* event, NativeString* extra);
  void reportError(const char* errmsg);

  int32_t contextId;
#if IS_TEST
  // the owner pointer which take JSBridge as property.
  void* owner;
  JSBridgeDisposeCallback disposeCallback{nullptr};
#endif
 private:
  std::unique_ptr<binding::qjs::ExecutionContext> m_context;
  JSExceptionHandler m_handler;
};

}  // namespace kraken

#endif  // KRAKEN_JS_QJS_BRIDGE_H_
