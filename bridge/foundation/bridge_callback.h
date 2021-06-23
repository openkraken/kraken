/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_CALLBACK_H
#define KRAKENBRIDGE_BRIDGE_CALLBACK_H

#ifdef KRAKEN_JSC_ENGINE
#include "bindings/jsc/js_context_internal.h"
#elif KRAKEN_QUICK_JS_ENGINE
#include "bindings/qjs/js_context.h"
#endif

#include <atomic>
#include <cstdint>
#include <memory>
#include <vector>

namespace kraken::foundation {

/// An global standalone BridgeCallback register and collector used to register an callback which will call back from
/// outside of bridge.
/// This class can auto recycle callback context's memory when bridge are willing to unmount.
/// This class is thread safe.
class BridgeCallback {
public:
  ~BridgeCallback() {
    contextList.clear();
  }

#if KRAKEN_JSC_ENGINE
  struct Context {
    Context(kraken::binding::jsc::JSContext &context, JSValueRef callback, JSValueRef *exception)
      : m_context(context), m_callback(callback) {
      JSValueProtect(context.context(), callback);
    };
    Context(kraken::binding::jsc::JSContext &context, JSValueRef callback, JSValueRef secondaryCallback,
            JSValueRef *exception)
      : m_context(context), m_callback(callback), m_secondaryCallback(secondaryCallback) {
      JSValueProtect(context.context(), callback);
      JSValueProtect(context.context(), secondaryCallback);
    };
    ~Context() {
      JSValueUnprotect(m_context.context(), m_callback);

      if (m_secondaryCallback != nullptr) {
        JSValueUnprotect(m_context.context(), m_secondaryCallback);
      }
    }
    kraken::binding::jsc::JSContext &m_context;
    JSValueRef m_callback{nullptr};
    JSValueRef m_secondaryCallback{nullptr};
  };
#elif KRAKEN_QUICK_JS_ENGINE
  struct Context {
    Context(kraken::binding::qjs::JSContext &context, JSValue callback, JSValue *exception)
      : m_context(context), m_callback(callback), m_func_count(1) {
      JS_DupValue(context.context(), callback);
    };
    Context(kraken::binding::qjs::JSContext &context, JSValue callback, JSValue secondaryCallback, JSValue *exception)
      : m_context(context), m_callback(callback), m_secondaryCallback(secondaryCallback), m_func_count(2) {
      JS_DupValue(context.context(), callback);
      JS_DupValue(context.context(), secondaryCallback);
    };
    ~Context() {
      JS_FreeValue(m_context.context(), m_callback);
      if (m_func_count == 2) {
        JS_FreeValue(m_context.context(), m_secondaryCallback);
      }
    }
    kraken::binding::qjs::JSContext &m_context;
    int32_t m_func_count{0};
    JSValue m_callback;
    JSValue m_secondaryCallback;
  };
#endif

  // An wrapper to register an callback outside of bridge and wait for callback to bridge.
  template <typename T>
  T registerCallback(std::unique_ptr<Context> &&context, std::function<T(BridgeCallback::Context *, int32_t)> fn) {
    Context *p = context.get();
    assert(p != nullptr && "Callback context can not be nullptr");
    auto &jsContext = context->m_context;
    int32_t contextId = context->m_context.getContextId();
    contextList.emplace_back(std::move(context));
    return fn(p, contextId);
  }

  void freeBridgeCallbackContext(Context *context) {
    auto begin = std::begin(contextList);
    auto end = std::end(contextList);

    while (begin != end) {
      auto &&ctx = *begin;
      if (ctx.get() == context) {
        ctx.reset();
        contextList.erase(begin);
      }

      begin++;
    }
  }

private:
  std::vector<std::unique_ptr<Context>> contextList;
};

} // namespace kraken::foundation

#endif // KRAKENBRIDGE_BRIDGE_CALLBACK_H
