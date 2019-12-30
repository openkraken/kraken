/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include "websocket.h"

#include "logging.h"
#include "websocket_client.h"
#include <cassert>

namespace kraken {
namespace binding {

namespace {
inline bool isFunction(alibaba::jsa::JSContext &context, const alibaba::jsa::Value &v) {
  if (!v.isObject()) {
    return false;
  }
  return v.getObject(context).isFunction(context);
}

inline alibaba::jsa::Function asFunction(alibaba::jsa::JSContext &context,
                                         const alibaba::jsa::Value &v) {
  return v.getObject(context).asFunction(context);
}
} // namespace

class CallbackImpl : public foundation::WebSocketCallback {
public:
  CallbackImpl(alibaba::jsa::JSContext &context, alibaba::jsa::Object on_open,
               alibaba::jsa::Object on_message, alibaba::jsa::Object on_close,
               alibaba::jsa::Object on_err)
      : context_(std::move(on_message), std::move(on_open), std::move(on_close),
                 std::move(on_err), context) {}
  ~CallbackImpl() = default;
  virtual void onOpen() override;
  virtual void onMessage(const std::string &message) override;
  virtual void onClose(int code, const std::string &reason) override;
  virtual void onError(const std::string &error) override;

private:
  struct context {
    context(alibaba::jsa::Object on_message, alibaba::jsa::Object on_open,
            alibaba::jsa::Object on_close, alibaba::jsa::Object on_err,
            alibaba::jsa::JSContext &context)
        : _context(context), _on_open(std::move(on_open)),
          _on_message(std::move(on_message)), _on_close(std::move(on_close)),
          _on_err(std::move(on_err)) {}
    alibaba::jsa::Object _on_message;
    alibaba::jsa::Object _on_open;
    alibaba::jsa::Object _on_close;
    alibaba::jsa::Object _on_err;

    alibaba::jsa::JSContext &_context;

    // additional params
    std::string message;
    int code;
    std::string reason;
    std::string error;
  };

  context context_;
};

void CallbackImpl::onOpen() {
  if (!context_._on_open.isFunction(context_._context)) {
    return;
  }
  auto scope = context_._context.threadScope();
  if (scope) {
    scope->postToUIThread(
        [](void *data) {
          auto c = reinterpret_cast<context *>(data);
          c->_on_open.asFunction(c->_context).call(c->_context, nullptr, 0);
        },
        reinterpret_cast<void *>(&context_));
  } else {
    context_._on_open.asFunction(context_._context)
        .call(context_._context, nullptr, 0);
  }
}

void CallbackImpl::onMessage(const std::string &message) {
  if (!context_._on_message.isFunction(context_._context)) {
    return;
  }
  auto scope = context_._context.threadScope();
  if (scope) {
    context_.message = message;
    scope->postToUIThread(
        [](void *data) {
          auto c = reinterpret_cast<context *>(data);
          c->_on_message.asFunction(c->_context)
              .call(c->_context, {alibaba::jsa::String::createFromUtf8(
                                     c->_context, c->message)});
        },
        reinterpret_cast<void *>(&context_));
  } else {
    context_._on_message.asFunction(context_._context)
        .call(context_._context, {alibaba::jsa::String::createFromUtf8(
                                     context_._context, message)});
  }
}

void CallbackImpl::onClose(int code, const std::string &reason) {
  if (!context_._on_close.isFunction(context_._context)) {
    return;
  }

  auto scope = context_._context.threadScope();
  if (scope) {
    context_.code = code;
    context_.reason = reason;
    scope->postToUIThread(
        [](void *data) {
          auto c = reinterpret_cast<context *>(data);
          auto obj = JSA_CREATE_OBJECT(c->_context);
          JSA_SET_PROPERTY(c->_context, obj, "code", c->code);
          JSA_SET_PROPERTY(
              c->_context, obj, "message",
              alibaba::jsa::String::createFromUtf8(c->_context, c->reason));
          c->_on_close.asFunction(c->_context)
              .call(c->_context, {alibaba::jsa::Value(c->_context, obj)});
        },
        reinterpret_cast<void *>(&context_));
  } else {
    auto obj = JSA_CREATE_OBJECT(context_._context);
    JSA_SET_PROPERTY(context_._context, obj, "code", code);
    JSA_SET_PROPERTY(
        context_._context, obj, "message",
        alibaba::jsa::String::createFromUtf8(context_._context, reason));
    context_._on_close.asFunction(context_._context)
        .call(context_._context, {alibaba::jsa::Value(context_._context, obj)});
  }
}

void CallbackImpl::onError(const std::string &error) {
  if (!context_._on_err.isFunction(context_._context)) {
    return;
  }
  auto scope = context_._context.threadScope();
  if (scope) {
    context_.error = error;
    scope->postToUIThread(
        [](void *data) {
          auto c = reinterpret_cast<context *>(data);
          c->_on_err.asFunction(c->_context)
              .call(c->_context, {alibaba::jsa::String::createFromUtf8(
                                     c->_context, c->error)});
        },
        reinterpret_cast<void *>(&context_));
  } else {
    context_._on_err.asFunction(context_._context)
        .call(context_._context,
              {alibaba::jsa::String::createFromUtf8(context_._context, error)});
  }
}

//////////////////////////
JSWebSocket::JSWebSocket() {
  _websocket = foundation::WebSocketClient::buildDefault();
}

alibaba::jsa::Value JSWebSocket::connect(alibaba::jsa::JSContext &context,
                            const alibaba::jsa::Value &thisVal,
                            const alibaba::jsa::Value *args, size_t count) {
  if (count < 5) {
    KRAKEN_LOG(WARN) << "connect method takes 5 arguments. "
                        "[connetct(url,onMessage,onOpen,onClose,onError)]";
    return alibaba::jsa::Value::undefined();
  }
  auto &&url = args[0];
  alibaba::jsa::Object onMessage = std::move(args[1]).getObject(context);
  alibaba::jsa::Object onOpen = std::move(args[2]).getObject(context);
  alibaba::jsa::Object onClose = std::move(args[3]).getObject(context);
  alibaba::jsa::Object onError = std::move(args[4]).getObject(context);

  assert(_websocket != nullptr);
  if (!url.isString()) {
    KRAKEN_LOG(ERROR) << "websocket url must be string";
    return alibaba::jsa::Value::undefined();
  }

  auto callback = std::make_shared<CallbackImpl>(
      context, std::move(onOpen), std::move(onMessage), std::move(onClose),
      std::move(onError));
  auto token = _websocket->connect(url.getString(context).utf8(context), callback);
  _callback_map[token] = callback;
  return alibaba::jsa::Value(token);
}

alibaba::jsa::Value JSWebSocket::send(alibaba::jsa::JSContext &context,
                                             const alibaba::jsa::Value &thisVal,
                                             const alibaba::jsa::Value *args,
                                             size_t count) {
  if (count < 2) {
    KRAKEN_LOG(WARN)
        << "websocket.send method takes 2 arguments. [send(token, message)]";
    return alibaba::jsa::Value::undefined();
  }
  auto &&token = args[0];
  auto &&message = args[1];

  if (!token.isNumber()) {
    KRAKEN_LOG(ERROR) << "token must be number";
    return alibaba::jsa::Value::undefined();
  }
  if (!message.isString()) {
    KRAKEN_LOG(ERROR) << "message must be string";
    return alibaba::jsa::Value::undefined();
  }

  assert(_websocket != nullptr);
  _websocket->send(static_cast<int>(token.getNumber()),
                   message.getString(context).utf8(context));
  return alibaba::jsa::Value::undefined();
}

alibaba::jsa::Value JSWebSocket::close(alibaba::jsa::JSContext &context,
                          const alibaba::jsa::Value &thisVal,
                          const alibaba::jsa::Value *args, size_t count) {
  if (count < 3) {
    KRAKEN_LOG(WARN) << "websocket.close method takes 3 arguments. "
                        "[close(token, code, reason)]";
    return alibaba::jsa::Value::undefined();
  }
  auto &&token = args[0];
  auto &&code = args[1];
  auto &&reason = args[2];
  if (!token.isNumber()) {
    KRAKEN_LOG(ERROR) << "token must be number";
    return alibaba::jsa::Value::undefined();
  }
  if (!code.isNumber()) {
    KRAKEN_LOG(ERROR) << "code must be number";
    return alibaba::jsa::Value::undefined();
  }
  if (!reason.isString()) {
    KRAKEN_LOG(ERROR) << "reason must be string";
    return alibaba::jsa::Value::undefined();
  }
  assert(_websocket != nullptr);
  _websocket->close(static_cast<int>(token.getNumber()),
                    static_cast<int>(code.getNumber()),
                    reason.getString(context).utf8(context));
  return alibaba::jsa::Value::undefined();
}

void JSWebSocket::set(alibaba::jsa::JSContext &,
                             const alibaba::jsa::PropNameID &name,
                             const alibaba::jsa::Value &value) {
  KRAKEN_LOG(ERROR) << "global.websocket not support set property";
#ifndef NDEBUG
  std::abort();
#endif
}

alibaba::jsa::Value JSWebSocket::get(alibaba::jsa::JSContext &context,
                        const alibaba::jsa::PropNameID &name) {
  auto _name = name.utf8(context);
  using namespace alibaba::jsa;
  if (_name == "connect") {
    auto connectFunc = JSA_CREATE_HOST_FUNCTION_SIMPLIFIED(
        context, std::bind(&JSWebSocket::connect, this, std::placeholders::_1,
                      std::placeholders::_2, std::placeholders::_3,
                      std::placeholders::_4));
    return alibaba::jsa::Value(context, connectFunc);
  } else if (_name == "send") {
    auto sendFunc = JSA_CREATE_HOST_FUNCTION_SIMPLIFIED(
        context, std::bind(&JSWebSocket::send, this, std::placeholders::_1,
                      std::placeholders::_2, std::placeholders::_3,
                      std::placeholders::_4));
    return alibaba::jsa::Value(context, sendFunc);
  } else if (_name == "close") {
    auto closeFunc = JSA_CREATE_HOST_FUNCTION_SIMPLIFIED(
        context, std::bind(&JSWebSocket::close, this, std::placeholders::_1,
                      std::placeholders::_2, std::placeholders::_3,
                      std::placeholders::_4));
    return alibaba::jsa::Value(context, closeFunc);
  }
  return alibaba::jsa::Value::undefined();
}

std::vector<alibaba::jsa::PropNameID>
JSWebSocket::getPropertyNames(alibaba::jsa::JSContext &context) {
  std::vector<alibaba::jsa::PropNameID> propertyNames;
  propertyNames.emplace_back(alibaba::jsa::PropNameID::forUtf8(context, "connect"));
  propertyNames.emplace_back(alibaba::jsa::PropNameID::forUtf8(context, "send"));
  propertyNames.emplace_back(alibaba::jsa::PropNameID::forUtf8(context, "close"));
  return propertyNames;
}

// 这里把websocket对象绑到global上
void JSWebSocket::bind(alibaba::jsa::JSContext *context) {
  assert(context != nullptr);
  JSA_BINDING_GLOBAL_HOST_OBJECT(*context, "__kraken_websocket__", sharedSelf());
}
} // namespace binding
} // namespace kraken
