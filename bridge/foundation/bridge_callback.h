/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BRIDGE_CALLBACK_H
#define KRAKENBRIDGE_BRIDGE_CALLBACK_H

#include "jsa.h"
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
    contextList.clear();
  }

  struct Context {
    Context(JSContext &context, std::shared_ptr<Value> callback) : _context(context), _callback(std::move(callback)){};
    JSContext &_context;
    std::shared_ptr<Value> _callback;
  };

  // An wrapper to register an callback outside of bridge and wait for callback to bridge.
  template <typename T>
  T registerCallback(std::unique_ptr<Context> &&context,
                     std::function<T(BridgeCallback::Context *, int32_t)> fn) {
    Context *p = context.get();
    assert(p != nullptr && "Callback context can not be nullptr");
    JSContext &jsContext = context->_context;
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

} // namespace foundation
} // namespace kraken

#endif // KRAKENBRIDGE_BRIDGE_CALLBACK_H
