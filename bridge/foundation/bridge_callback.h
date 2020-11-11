/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_CALLBACK_H
#define KRAKENBRIDGE_BRIDGE_CALLBACK_H

#ifdef KRAKEN_ENABLE_JSA
#include "jsa.h"
#elif KRAKEN_JSC_ENGINE
#include "bindings/jsc/js_context.h"
#endif

#include "js_engine_adaptor.h"
#include <atomic>
#include <cstdint>
#include <memory>
#include <vector>

namespace kraken::foundation {

#ifdef KRAKEN_ENABLE_JSA
using namespace alibaba::jsa;
#endif

/// An global standalone BridgeCallback register and collector used to register an callback which will call back from
/// outside of bridge.
/// This class can auto recycle callback context's memory when bridge are willing to unmount.
/// This class is thread safe.
class BridgeCallback {
public:
  ~BridgeCallback() {
    contextList.clear();
  }

#ifdef KRAKEN_ENABLE_JSA
  struct Context {
    Context(JSContext &context, std::shared_ptr<Value> callback) : _context(context), _callback(std::move(callback)){};
    ~Context() {}
    JSContext &_context;
    std::shared_ptr<Value> _callback;
  };
#elif KRAKEN_JSC_ENGINE
  struct Context {
    Context(kraken::binding::jsc::JSContext &context, JSValueRef callback, JSValueRef *exception)
      : _context(context), _callback(callback) {
      JSValueProtect(context.context(), callback);
    };
    ~Context() {
      JSValueUnprotect(_context.context(), _callback);
    }
    kraken::binding::jsc::JSContext &_context;
    JSValueRef _callback;
  };
#endif
  // An wrapper to register an callback outside of bridge and wait for callback to bridge.
  template <typename T>
  T registerCallback(std::unique_ptr<Context> &&context, std::function<T(BridgeCallback::Context *, int32_t)> fn) {
    Context *p = context.get();
    assert(p != nullptr && "Callback context can not be nullptr");
    auto &jsContext = context->_context;
    int32_t contextId = context->_context.getContextId();
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
