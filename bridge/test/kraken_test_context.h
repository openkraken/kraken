/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_KRAKEN_TEST_CONTEXT_H
#define KRAKENBRIDGE_KRAKEN_TEST_CONTEXT_H

#include "core/executing_context.h"
#include "core/page.h"
#include "bindings/qjs/qjs_function.h"
#include "kraken_bridge_test.h"

namespace kraken {

struct ImageSnapShotContext {
  JSValue callback;
  ExecutionContext* context;
  list_head link;
};

class KrakenTestContext final {
 public:
  explicit KrakenTestContext() = delete;
  explicit KrakenTestContext(ExecutionContext* context);

  /// Evaluate JavaScript source code with build-in test frameworks, use in test only.
  bool evaluateTestScripts(const uint16_t* code, size_t codeLength, const char* sourceURL, int startLine);
  bool parseTestHTML(const uint16_t* code, size_t codeLength);
  void invokeExecuteTest(ExecuteCallback executeCallback);
  void registerTestEnvDartMethods(uint64_t* methodBytes, int32_t length);

//  ScriptValue m_executeTestCallback{m_context->ctx()};
//  ScriptValue m_executeTestProxyObject{m_context->ctx()};

 private:
  /// the pointer of JSContext, ownership belongs to JSContext
  ExecutionContext* m_context{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_KRAKEN_TEST_CONTEXT_H
