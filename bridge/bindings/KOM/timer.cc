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

struct TimerContext {
  TimerContext(JSContext &context, std::shared_ptr<Value> callback)
      : _context(context), _callback(std::move(callback)){};

  JSContext &_context;
  std::shared_ptr<Value> _callback;
};

Value setTimeout(JSContext &context, const Value &thisVal, const Value *args,
                 size_t count) {
  if (count <= 0) {
    KRAKEN_LOG(WARN) << "[setTimeout] function missing parameter";
    return Value::undefined();
  }

  std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  if (!callbackFunction.isFunction(context)) {
    KRAKEN_LOG(WARN) << "[setTimeout] first params should be a function";
    return Value::undefined();
  }

  auto &&timeout = args[1];
  int32_t time;

  if (timeout.isUndefined() || count < 2) {
    time = 0;
  } else if (timeout.isNumber()) {
    time = timeout.getNumber();
  } else {
    KRAKEN_LOG(WARN) << "[setTimeout] timeout should be a number";
    return Value::undefined();
  }

  if (getDartMethod()->setTimeout == nullptr) {
    KRAKEN_LOG(ERROR) << "[setTimeout] dart callback not register";
    return Value::undefined();
  }

  auto *timerContext = new TimerContext(context, callbackValue);

  auto callback = [](void *data) {
    auto *context = static_cast<TimerContext *>(data);
    if (!context->_context.isValid())
      return;

    if (context->_callback == nullptr) {
      KRAKEN_LOG(VERBOSE) << "callback is not a function";
      return;
    }

    Object callback = context->_callback->getObject(context->_context);
    callback.asFunction(context->_context)
        .call(context->_context, Value::undefined(), 0);

    delete context;
  };

  int32_t timerId = getDartMethod()->setTimeout(
      callback, static_cast<void *>(timerContext), time);
  return Value(timerId);
}

Value setInterval(JSContext &context, const Value &thisVal, const Value *args,
                  size_t count) {
  if (count <= 0) {
    KRAKEN_LOG(WARN) << "[setInterval] function missing parameter";
    return Value::undefined();
  }

  std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  if (!callbackFunction.isFunction(context)) {
    KRAKEN_LOG(WARN) << "[setInterval] first params should be a function";
    return Value::undefined();
  }

  auto &&timeout = args[1];
  int32_t time;

  if (timeout.isUndefined()) {
    time = 0;
  } else if (timeout.isNumber()) {
    time = timeout.getNumber();
  } else {
    KRAKEN_LOG(WARN) << "[setInterval] timeout should be a number";
    return Value::undefined();
  }

  if (getDartMethod()->setInterval == nullptr) {
    KRAKEN_LOG(ERROR) << "[setInterval] dart callback not register";
    return Value::undefined();
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto *timerContext = new TimerContext(context, callbackValue);
  // the callback pointer send and invoked by dart code.
  auto callback = [](void *data) {
    auto *context = static_cast<TimerContext *>(data);
    if (!context->_context.isValid())
      return;
    if (context->_callback == nullptr) {
      KRAKEN_LOG(VERBOSE) << "callback is not a function";
      return;
    }

    Object callback = context->_callback->getObject(context->_context);
    if (callback.isFunction(context->_context)) {
      callback.asFunction(context->_context)
          .call(context->_context, Value::undefined(), 0);
    } else {
      KRAKEN_LOG(VERBOSE) << "callback is not a function";
    }

    // delete timerContext pointer.
    delete context;
  };

  int32_t timerId = getDartMethod()->setInterval(
      callback, static_cast<void *>(timerContext), time);

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
  auto *timerContext = new TimerContext(context, callbackValue);
  // the callback pointer send and invoked by dart code.
  auto callback = [](void *data) {
    auto *context = static_cast<TimerContext *>(data);
    if (!context->_context.isValid())
      return;
    if (context->_callback == nullptr) {
      KRAKEN_LOG(VERBOSE) << "callback is not a function";
      return;
    }

    Object callback = context->_callback->getObject(context->_context);
    if (callback.isFunction(context->_context)) {
      callback.asFunction(context->_context)
          .call(context->_context, Value::undefined(), 0);
    } else {
      KRAKEN_LOG(VERBOSE) << "callback is not a function";
    }

    // delete timerContext pointer.
    delete context;
  };

  if (getDartMethod()->requestAnimationFrame == nullptr) {
    KRAKEN_LOG(ERROR) << "[requestAnimationFrame] dart callback not register";
    return Value::undefined();
  }

  int32_t timerId = getDartMethod()->requestAnimationFrame(
      callback, static_cast<void *>(timerContext));
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

void unbindTimer() {

}

} // namespace binding
} // namespace kraken
