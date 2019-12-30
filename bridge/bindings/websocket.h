/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/


#ifndef KRAKEN_JS_BINDINGS_WEBSOCKET_H_
#define KRAKEN_JS_BINDINGS_WEBSOCKET_H_

#include "websocket_client.h"
#include "jsa.h"

#include <map>
#include <memory>

namespace kraken {
namespace binding {
class CallbackImpl;
class JSWebSocket : public alibaba::jsa::HostObject,
      public std::enable_shared_from_this<JSWebSocket> {
public:
  JSWebSocket();
  ~JSWebSocket() = default;

  // JSBinding
  virtual void bind(alibaba::jsa::JSContext *context);

  // alibaba::jsa::HostObject
  virtual alibaba::jsa::Value
  get(alibaba::jsa::JSContext &, const alibaba::jsa::PropNameID &name) override;

  virtual void set(alibaba::jsa::JSContext &,
                   const alibaba::jsa::PropNameID &name,
                   const alibaba::jsa::Value &value) override;

  virtual std::vector<alibaba::jsa::PropNameID>
  getPropertyNames(alibaba::jsa::JSContext &context) override;

private:
  std::shared_ptr<JSWebSocket> sharedSelf() {
    return shared_from_this();
  }
  
  alibaba::jsa::Value connect(alibaba::jsa::JSContext &context,
                              const alibaba::jsa::Value &thisVal,
                              const alibaba::jsa::Value *args, size_t count);

  alibaba::jsa::Value send(alibaba::jsa::JSContext &context,
                           const alibaba::jsa::Value &thisVal,
                           const alibaba::jsa::Value *args, size_t count);

  alibaba::jsa::Value close(alibaba::jsa::JSContext &context,
                            const alibaba::jsa::Value &thisVal,
                            const alibaba::jsa::Value *args, size_t count);

private:
  std::unique_ptr<kraken::foundation::WebSocketClient> _websocket;
  std::map<int, std::shared_ptr<CallbackImpl>> _callback_map;
};

} // namespace binding
} // namespace kraken

#endif // KRAKEN_JS_BINDINGS_WEBSOCKET_H_
