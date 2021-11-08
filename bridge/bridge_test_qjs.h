/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_TEST_QJS_H
#define KRAKENBRIDGE_BRIDGE_TEST_QJS_H

#include "bindings/qjs/dom/document.h"
#include "bindings/qjs/html_parser.h"
#include "bridge_qjs.h"
#include "kraken_bridge_test.h"

namespace kraken {

struct ImageSnapShotContext {
  JSValue callback;
  binding::qjs::JSContext* context;
  list_head link;
};

class JSBridgeTest final {
 public:
  explicit JSBridgeTest() = delete;
  explicit JSBridgeTest(JSBridge* bridge);

  ~JSBridgeTest() {
    if (!JS_IsNull(executeTestCallback)) {
      JS_FreeValue(context->ctx(), executeTestCallback);
    }
    if (!JS_IsNull(executeTestProxyObject)) {
      JS_FreeValue(context->ctx(), executeTestProxyObject);
    }

    {
      struct list_head *el, *el1;
      list_for_each_safe(el, el1, &image_link) {
        auto* image = list_entry(el, ImageSnapShotContext, link);
        JS_FreeValue(context->ctx(), image->callback);
      }
    }
  }

  /// evaluete JavaScript source code with build-in test frameworks, use in test only.
  bool evaluateTestScripts(const uint16_t* code, size_t codeLength, const char* sourceURL, int startLine);
  bool parseTestHTML(const uint16_t* code, size_t codeLength);
  void invokeExecuteTest(ExecuteCallback executeCallback);

  JSValue executeTestCallback{JS_NULL};
  JSValue executeTestProxyObject{JS_NULL};
  list_head image_link;

 private:
  /// the pointer of bridge, ownership belongs to JSBridge
  JSBridge* bridge_;
  /// the pointer of JSContext, overship belongs to JSContext
  const std::unique_ptr<binding::qjs::JSContext>& context;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BRIDGE_TEST_QJS_H
