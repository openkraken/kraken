/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_QJS_BRIDGE_H_
#define KRAKEN_JS_QJS_BRIDGE_H_

#include <quickjs/quickjs.h>
#include <atomic>
#include <deque>
#include <thread>
#include <vector>

#include "core/executing_context.h"
#include "foundation/native_string.h"

namespace kraken {

class KrakenPage;
using JSBridgeDisposeCallback = void (*)(KrakenPage* bridge);
using ConsoleMessageHandler = std::function<void(void* ctx, const std::string& message, int logLevel)>;

/// KrakenPage is class which manage all js objects Create by <Kraken> flutter widget.
/// Every <Kraken> flutter widgets have a corresponding KrakenPage, and all objects created by JavaScript are stored here,
/// and there is no data sharing between objects between different KrakenPages.
/// It's safe to Allocate many KrakenPages at the same times on one thread, but not safe for multi-threads, only one thread can enter to KrakenPage at the same time.
class KrakenPage final {
 public:
  static kraken::KrakenPage** pageContextPool;
  static ConsoleMessageHandler consoleMessageHandler;
  KrakenPage() = delete;
  KrakenPage(int32_t jsContext, const JSExceptionHandler& handler);
  ~KrakenPage();

  // evaluate JavaScript source codes in standard mode.
  void evaluateScript(const NativeString* script, const char* url, int startLine);
  void evaluateScript(const uint16_t* script, size_t length, const char* url, int startLine);
  bool parseHTML(const char* code, size_t length);
  void evaluateScript(const char* script, size_t length, const char* url, int startLine);
  uint8_t* dumpByteCode(const char* script, size_t length, const char* url, size_t* byteLength);
  void evaluateByteCode(uint8_t* bytes, size_t byteLength);

  void registerDartMethods(uint64_t* methodBytes, int32_t length);
  std::thread::id currentThread() const;

  [[nodiscard]] ExecutingContext* getContext() const { return m_context; }

  void invokeModuleEvent(const NativeString* moduleName, const char* eventType, void* event, NativeString* extra);
  void reportError(const char* errmsg);

  int32_t contextId;
#if IS_TEST
  // the owner pointer which take JSBridge as property.
  void* owner;
  JSBridgeDisposeCallback disposeCallback{nullptr};
#endif
 private:
  const std::thread::id ownerThreadId;
  // FIXME: we must to use raw pointer instead of unique_ptr because we needs to access m_context when dispose page.
  // TODO: Raw pointer is dangerous and just works but it's fragile. We needs refactor this for more stable and maintainable.
  ExecutingContext* m_context;
  JSExceptionHandler m_handler;
};

}  // namespace kraken

#endif  // KRAKEN_JS_QJS_BRIDGE_H_
