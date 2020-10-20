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
    callbackCount = 0;
  }

  struct Context {
    Context(KRAKEN_JS_CONTEXT &context, std::shared_ptr<KRAKEN_JS_VALUE> callback)
      : _context(context), _callback(std::move(callback)) {
#ifndef KRAKEN_ENABLE_JSA
      JSValueProtect(_context.context(), *_callback);
#endif
    };
    ~Context() {
#ifndef KRAKEN_ENABLE_JSA
      JSValueUnprotect(_context.context(), *_callback);
#endif
    }
    KRAKEN_JS_CONTEXT &_context;
    std::shared_ptr<KRAKEN_JS_VALUE> _callback;
  };

  // An wrapper to register an callback outside of bridge and wait for callback to bridge.
  template <typename T>
  T registerCallback(std::unique_ptr<Context> &&context, std::function<T(BridgeCallback::Context *, int32_t)> fn) {
    Context *p = context.get();
    assert(p != nullptr && "Callback context can not be nullptr");
    KRAKEN_JS_CONTEXT &jsContext = context->_context;
    int32_t contextId = context->_context.getContextId();
    contextList.emplace_back(std::move(context));
    callbackCount.fetch_add(1);
    return fn(p, contextId);
  }

private:
  std::vector<std::unique_ptr<Context>> contextList;
  std::atomic<int> callbackCount{0};
};

} // namespace kraken::foundation

#endif // KRAKENBRIDGE_BRIDGE_CALLBACK_H
