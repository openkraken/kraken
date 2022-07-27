/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_JS_QJS_BRIDGE_H_
#define WEBF_JS_QJS_BRIDGE_H_

#include <quickjs/quickjs.h>
#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/html_parser.h"
#include "include/webf_bridge.h"

#include <atomic>
#include <deque>
#include <vector>

namespace webf {

class WebFPage;
using JSBridgeDisposeCallback = void (*)(WebFPage* bridge);

/// WebFPage is class which manage all js objects create by <WebF> flutter widget.
/// Every <WebF> flutter widgets have a corresponding WebFPage, and all objects created by JavaScript are stored here,
/// and there is no data sharing between objects between different WebFPages.
/// It's safe to allocate many WebFPages at the same times on one thread, but not safe for multi-threads, only one thread can enter to WebFPage at the same time.
class WebFPage final {
 public:
  static webf::WebFPage** pageContextPool;
  static ConsoleMessageHandler consoleMessageHandler;
  WebFPage() = delete;
  WebFPage(int32_t jsContext, const JSExceptionHandler& handler);
  ~WebFPage();

  // Bytecodes which registered by webf plugins.
  static std::unordered_map<std::string, NativeByteCode> pluginByteCode;

  // evaluate JavaScript source codes in standard mode.
  void evaluateScript(const NativeString* script, const char* url, int startLine);
  void evaluateScript(const uint16_t* script, size_t length, const char* url, int startLine);
  bool parseHTML(const char* code, size_t length);
  void evaluateScript(const char* script, size_t length, const char* url, int startLine);
  uint8_t* dumpByteCode(const char* script, size_t length, const char* url, size_t* byteLength);
  void evaluateByteCode(uint8_t* bytes, size_t byteLength);

  [[nodiscard]] webf::binding::qjs::ExecutionContext* getContext() const { return m_context; }

  void invokeModuleEvent(NativeString* moduleName, const char* eventType, void* event, NativeString* extra);
  void reportError(const char* errmsg);

  int32_t contextId;
#if IS_TEST
  // the owner pointer which take JSBridge as property.
  void* owner;
  JSBridgeDisposeCallback disposeCallback{nullptr};
#endif
 private:
  // FIXME: we must to use raw pointer instead of unique_ptr because we needs to access m_context when dispose page.
  // TODO: Raw pointer is dangerous and just works but it's fragile. We needs refactor this for more stable and maintainable.
  binding::qjs::ExecutionContext* m_context;
  JSExceptionHandler m_handler;
};

}  // namespace webf

#endif  // WEBF_JS_QJS_BRIDGE_H_
