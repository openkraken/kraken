/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BINDINGS_WEBSOCKET_H_
#define KRAKEN_JS_BINDINGS_WEBSOCKET_H_

#include "jsa.h"
#include "websocket_client.h"

#include <map>
#include <memory>

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

class CallbackImpl;
class JSWebSocket : public HostObject, public std::enable_shared_from_this<JSWebSocket> {
public:
  JSWebSocket();
  ~JSWebSocket() = default;

  // JSBinding
  void bind(std::unique_ptr<JSContext> &context);
  void unbind(std::unique_ptr<JSContext> &context);

  // HostObject
  Value get(JSContext &, const PropNameID &name) override;

  void set(JSContext &, const PropNameID &name, const Value &value) override;

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

private:
  std::shared_ptr<JSWebSocket> sharedSelf() {
    return shared_from_this();
  }

  Value connect(JSContext &context, const Value &thisVal, const Value *args, size_t count);

  Value send(JSContext &context, const Value &thisVal, const Value *args, size_t count);

  Value close(JSContext &context, const Value &thisVal, const Value *args, size_t count);

private:
  std::unique_ptr<kraken::foundation::WebSocketClient> _websocket;
  std::map<int, std::shared_ptr<CallbackImpl>> _callback_map;
};

} // namespace binding
} // namespace kraken

#endif // KRAKEN_JS_BINDINGS_WEBSOCKET_H_
