/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_CALLBACK_H
#define KRAKENBRIDGE_BRIDGE_CALLBACK_H

#include "bridge.h"
#include "jsa.h"
#include "kraken_bridge.h"
#include "thread_safe_array.h"
#include <atomic>
#include <cstdint>
#include <memory>

namespace kraken {
namespace foundation {

using namespace alibaba::jsa;

/// An global standalone BridgeCallback register and collector used to register an callback which will call back from
/// outside of bridge.
/// This class can auto recycle callback context's memory when bridge are willing to unmount.
/// This class is thread safe.
class BridgeCallback {
public:
  ~BridgeCallback() {
    disposeAllCallbacks();
  }

  static std::shared_ptr<BridgeCallback> instance();
  struct Context {
    Context(JSContext &context, std::shared_ptr<Value> callback) : _context(context), _callback(std::move(callback)){};
    JSContext &_context;
    std::shared_ptr<Value> _callback;
  };

  // An wrapper to register an callback outside of bridge and wait for callback to bridge.
  template <typename T>
  T registerCallback(std::unique_ptr<Context> &&context,
                     std::function<T(BridgeCallback::Context *, JSBridge *, int32_t)> fn) {
    Context *p = context.get();
    assert(p != nullptr && "Callback context can not be nullptr");
    JSContext &jsContext = context->_context;
    int32_t contextIndex = context->_context.getContextIndex();
    auto bridge = static_cast<JSBridge *>(getJSBridge(contextIndex));
    contextList.push(std::move(context));
    callbackCount.fetch_add(1);
    return fn(p, bridge, contextIndex);
  }

  // dispose all callbacks and recycle callback context's memory
  void disposeAllCallbacks();

  static bool checkContext(JSContext &context, int32_t contextIndex) {
    auto *bridge = static_cast<kraken::JSBridge *>(getJSBridge(contextIndex));
    auto currentContext = bridge->getContext();
    return currentContext == &context;
  }

private:
  ThreadSafeArray<std::unique_ptr<Context>> contextList;
  std::atomic<int> callbackCount{0};
};

} // namespace foundation
} // namespace kraken

#endif // KRAKENBRIDGE_BRIDGE_CALLBACK_H
