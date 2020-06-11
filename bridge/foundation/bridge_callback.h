/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_CALLBACK_H
#define KRAKENBRIDGE_BRIDGE_CALLBACK_H

#include "jsa.h"
#include "thread_safe_array.h"
#include "bridge.h"
#include "kraken_bridge.h"
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
  template <typename T> T registerCallback(std::unique_ptr<Context> &&context, std::function<T(void *)> fn) {
    Context *p = context.get();
    contextList.push(std::move(context));
    callbackCount.fetch_add(1);
    return fn(static_cast<void *>(p));
  }

  // dispose all callbacks and recycle callback context's memory
  void disposeAllCallbacks();

  static bool checkContext(JSContext &context) {
    auto *bridge = static_cast<kraken::JSBridge*>(getBridge());
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
