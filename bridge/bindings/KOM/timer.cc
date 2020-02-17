/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"
#include "dart_methods.h"
#include "jsa.h"
#include "logging.h"
#include "thread_safe_map.h"
#include <atomic>

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

struct CallbackContext {
  CallbackContext(JSContext &context, std::shared_ptr<Value> callback)
      : _context(context), _callback(std::move(callback)){};

  JSContext &_context;
  std::shared_ptr<Value> _callback;
};

void destoryCallbackContext(void *data) {
  auto *obj = static_cast<CallbackContext *>(data);
  delete obj;
}

void handlePersistentCallback(void *data) {
  auto *obj = static_cast<CallbackContext *>(data);
  JSContext &_context = obj->_context;
  if (!_context.isValid())
    return;

  if (obj->_callback == nullptr) {
    KRAKEN_LOG(VERBOSE) << "Callback is null";
    return;
  }

  Object callback = obj->_callback->getObject(_context);
  callback.asFunction(_context).call(_context, Value::undefined(), 0);
}

void handleTransientCallback(void *data) {
  handlePersistentCallback(data);
  destoryCallbackContext(data);
}

Value setTimeout(JSContext &context, const Value &thisVal, const Value *args,
                 size_t count) {
  if (count < 1) {
    KRAKEN_LOG(ERROR) << "Failed to execute 'setTimeout': 1 argument required, but only 0 present.";
    return Value::undefined();
  }

  std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  if (!callbackFunction.isFunction(context)) {
    KRAKEN_LOG(WARN) << "[setTimeout] first params should be a function";
    return Value::undefined();
  }

  auto &&time = args[1];
  int32_t timeout;

  if (time.isUndefined() || count < 2) {
    timeout = 0;
  } else if (time.isNumber()) {
    timeout = time.getNumber();
  } else {
    KRAKEN_LOG(WARN) << "[setTimeout] timeout should be a number";
    return Value::undefined();
  }

  if (getDartMethod()->setTimeout == nullptr) {
    KRAKEN_LOG(ERROR) << "Dart method 'setTimeout' not registered.";
    return Value::undefined();
  }

  auto *callbackContext = new CallbackContext(context, callbackValue);

  int32_t timerId = getDartMethod()->setTimeout(
      handleTransientCallback, static_cast<void *>(callbackContext), timeout);
  return Value(timerId);
}

Value setInterval(JSContext &context, const Value &thisVal, const Value *args,
                  size_t count) {
  if (count < 1) {
    KRAKEN_LOG(ERROR) << "Failed to execute 'setInterval': 1 argument required, but only 0 present.";
    return Value::undefined();
  }

  std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  if (!callbackFunction.isFunction(context)) {
    KRAKEN_LOG(WARN) << "[setInterval] first params should be a function";
    return Value::undefined();
  }

  auto &&time = args[1];
  int32_t delay;

  if (time.isUndefined()) {
    delay = 0;
  } else if (time.isNumber()) {
    delay = time.getNumber();
  } else {
    KRAKEN_LOG(WARN) << "[setInterval] timeout should be a number";
    return Value::undefined();
  }

  if (getDartMethod()->setInterval == nullptr) {
    KRAKEN_LOG(ERROR) << "[setInterval] dart callback not register";
    return Value::undefined();
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto *callbackContext = new CallbackContext(context, callbackValue);
  // the callback pointer send and invoked by dart code.
  auto callback = [](void *data) {
    auto *obj = static_cast<CallbackContext *>(data);
    if (!obj->_context.isValid())
      return;
    if (obj->_callback == nullptr) {
      KRAKEN_LOG(VERBOSE) << "Callback is null";
      return;
    }

    Object callback = obj->_callback->getObject(obj->_context);
    if (callback.isFunction(obj->_context)) {
      callback.asFunction(obj->_context)
          .call(obj->_context, Value::undefined(), 0);
    } else {
      KRAKEN_LOG(VERBOSE) << "Callback is not a function";
    }
  };

  int32_t timerId = getDartMethod()->setInterval(
      handlePersistentCallback, static_cast<void *>(callbackContext), delay);

  return Value(timerId);
}

Value clearTimeout(JSContext &context, const Value &thisVal, const Value *args,
                   size_t count) {
  if (count <= 0) {
    KRAKEN_LOG(WARN) << "[clearTimeout] function missing parameter";
    return Value::undefined();
  }

  const Value &timerId = args[0];
  if (!timerId.isNumber()) {
    KRAKEN_LOG(WARN)
        << "[clearTimeout] clearTimeout accept number as parameter";
    return Value::undefined();
  }

  auto id = static_cast<int32_t>(timerId.asNumber());

  if (getDartMethod()->clearTimeout == nullptr) {
    KRAKEN_LOG(ERROR) << "[clearTimeout]: dart callback not register";
    return Value::undefined();
  }

  getDartMethod()->clearTimeout(id);
  return Value::undefined();
}

Value cancelAnimationFrame(JSContext &context, const Value &thisVal,
                           const Value *args, size_t count) {
  if (count <= 0) {
    KRAKEN_LOG(WARN) << "[cancelAnimationFrame] function missing parameter";
    return Value::undefined();
  }

  const Value &timerId = args[0];
  if (!timerId.isNumber()) {
    KRAKEN_LOG(WARN) << "[clearAnimationFrame] cancelAnimationFrame accept "
                        "number as parameter";
    return Value::undefined();
  }

  auto id = static_cast<int32_t>(timerId.asNumber());

  if (getDartMethod()->cancelAnimationFrame == nullptr) {
    KRAKEN_LOG(ERROR) << "[cancelAnimationFrame]: dart callback not register";
    return Value::undefined();
  }

  getDartMethod()->cancelAnimationFrame(id);

  return Value::undefined();
}

Value requestAnimationFrame(JSContext &context, const Value &thisVal,
                            const Value *args, size_t count) {
  if (count <= 0) {
    KRAKEN_LOG(WARN) << "[requestAnimationFrame] function missing parameters";
    return Value::undefined();
  }

  std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  if (!callbackFunction.isFunction(context)) {
    KRAKEN_LOG(WARN)
        << "[requestAnimationFrame] first param should be a function";
    return Value::undefined();
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto *callbackContext = new CallbackContext(context, callbackValue);

  if (getDartMethod()->requestAnimationFrame == nullptr) {
    KRAKEN_LOG(ERROR) << "[requestAnimationFrame] dart callback not register";
    return Value::undefined();
  }

  int32_t timerId = getDartMethod()->requestAnimationFrame(
      handleTransientCallback, static_cast<void *>(callbackContext));
  return Value(timerId);
}

void bindTimer(std::unique_ptr<JSContext> &context) {
  JSA_BINDING_FUNCTION(*context, context->global(), "setTimeout", 0,
                       setTimeout);
  JSA_BINDING_FUNCTION(*context, context->global(), "setInterval", 0,
                       setInterval);
  JSA_BINDING_FUNCTION(*context, context->global(), "requestAnimationFrame", 0,
                       requestAnimationFrame);
  JSA_BINDING_FUNCTION(*context, context->global(), "clearTimeout", 0,
                       clearTimeout);
  JSA_BINDING_FUNCTION(*context, context->global(), "clearInterval", 0,
                       clearTimeout);
  JSA_BINDING_FUNCTION(*context, context->global(), "cancelAnimationFrame", 0,
                       cancelAnimationFrame);
}

} // namespace binding
} // namespace kraken
