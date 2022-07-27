/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

#ifndef BRIDGE_PAGE_TEST_H
#define BRIDGE_PAGE_TEST_H

#include "bindings/qjs/dom/document.h"
#include "bindings/qjs/html_parser.h"
#include "page.h"
#include "webf_bridge_test.h"

namespace webf {

struct ImageSnapShotContext {
  JSValue callback;
  binding::qjs::ExecutionContext* context;
  list_head link;
};

class WebFPageTest final {
 public:
  explicit WebFPageTest() = delete;
  explicit WebFPageTest(WebFPage* bridge);

  ~WebFPageTest() {
    if (!JS_IsNull(executeTestCallback)) {
      JS_FreeValue(m_page_context->ctx(), executeTestCallback);
    }
    if (!JS_IsNull(executeTestProxyObject)) {
      JS_FreeValue(m_page_context->ctx(), executeTestProxyObject);
    }

    {
      struct list_head *el, *el1;
      list_for_each_safe(el, el1, &image_link) {
        auto* image = list_entry(el, ImageSnapShotContext, link);
        JS_FreeValue(m_page_context->ctx(), image->callback);
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
  WebFPage* m_page;
  /// the pointer of JSContext, overship belongs to JSContext
  binding::qjs::ExecutionContext* m_page_context;
};

}  // namespace webf

#endif  // BRIDGE_PAGE_TEST_H
