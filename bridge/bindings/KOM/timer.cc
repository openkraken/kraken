/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"
#include "dart_callbacks.h"
#include "jsa.h"
#include "logging.h"
#include "thread_safe_map.h"
#include <atomic>

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

ThreadSafeMap<int32_t, std::shared_ptr<Value>> timerCallbackMap;
ThreadSafeMap<int32_t, int32_t> timerIdToCallbackIdMap;
std::atomic<int32_t> timerCallbackId = {1};

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

  int32_t callbackId = timerCallbackId.load();

  timerCallbackMap.set(callbackId, callbackValue);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[setTimeout]: "
                        << "([\"setTimeout\",[" << callbackId << "]])"
                        << std::endl;
  }

  if (getDartFunc()->setTimeout == nullptr) {
    KRAKEN_LOG(ERROR) << "[setTimeout] dart callback not register";
    return Value::undefined();
  }

  int32_t timerId = getDartFunc()->setTimeout(callbackId, time);
  timerIdToCallbackIdMap.set(timerId, callbackId);
  timerCallbackId = callbackId + 1;
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

  int32_t callbackId = timerCallbackId.load();

  timerCallbackMap.set(callbackId, callbackValue);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[setInterval]: "
                        << "([\"setTimeout\",[" << callbackId << "]])"
                        << std::endl;
  }

  if (getDartFunc()->setInterval == nullptr) {
    KRAKEN_LOG(ERROR) << "[setInterval] dart callback not register";
    return Value::undefined();
  }

  int32_t timerId = getDartFunc()->setInterval(callbackId, time);

  timerIdToCallbackIdMap.set(timerId, callbackId);
  timerCallbackId = callbackId + 1;

  return Value(timerId);
}

Value clearTimeout(JSContext &rt, const Value &thisVal, const Value *args,
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

  int32_t timer = static_cast<int32_t>(timerId.asNumber());
  int32_t callbackId = 0;
  timerIdToCallbackIdMap.get(timer, callbackId);

  if (callbackId == 0) {
    KRAKEN_LOG(WARN) << "[clearTimeout] can not stop timer of timerId: "
                     << timer;
    return Value::undefined();
  }

  if (getDartFunc()->clearTimeout == nullptr) {
    KRAKEN_LOG(ERROR) << "[clearTimeout]: dart callback not register";
    return Value::undefined();
  }

  getDartFunc()->clearTimeout(timer);

  std::shared_ptr<Value> callbackValue;
  timerCallbackMap.get(callbackId, callbackValue);

  if (callbackValue == nullptr ||
      !callbackValue->getObject(rt).isFunction(rt)) {
    KRAKEN_LOG(WARN) << "[clearTimeout] can not stop timer of callbackId: "
                     << callbackId;
    return Value::undefined();
  }

  timerCallbackMap.erase(callbackId);
  return Value::undefined();
}

Value cancelAnimationFrame(JSContext &context, const Value &thisVal, const Value *args,
                          size_t count) {
  if (count <= 0) {
    KRAKEN_LOG(WARN) << "[cancelAnimationFrame] function missing parameter";
    return Value::undefined();
  }

  const Value &timerId = args[0];
  if (!timerId.isNumber()) {
    KRAKEN_LOG(WARN)
    << "[clearAnimationFrame] cancelAnimationFrame accept number as parameter";
    return Value::undefined();
  }

  auto timer = static_cast<int32_t>(timerId.asNumber());
  int32_t callbackId = 0;
  timerIdToCallbackIdMap.get(timer, callbackId);

  if (callbackId == 0) {
    KRAKEN_LOG(WARN) << "[cancelAnimationFrame] can not stop timer of timerId: "
                     << timer;
    return Value::undefined();
  }

  if (getDartFunc()->cancelAnimationFrame == nullptr) {
    KRAKEN_LOG(ERROR) << "[cancelAnimationFrame]: dart callback not register";
    return Value::undefined();
  }

  getDartFunc()->cancelAnimationFrame(timer);

  std::shared_ptr<Value> callbackValue;
  timerCallbackMap.get(callbackId, callbackValue);

  if (callbackValue == nullptr ||
      !callbackValue->getObject(context).isFunction(context)) {
    KRAKEN_LOG(WARN) << "[cancelAnimationFrame] can not stop timer of callbackId: "
                     << callbackId;
    return Value::undefined();
  }

  timerCallbackMap.erase(callbackId);
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

  int32_t callbackId = timerCallbackId.load();

  timerCallbackMap.set(callbackId, callbackValue);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[requestAnimationFrame]: "
                        << "([\"requestAnimationFrame\",[" << callbackId << "]])"
                        << std::endl;
  }

  if (getDartFunc()->requestAnimationFrame == nullptr) {
    KRAKEN_LOG(ERROR) << "[requestAnimationFrame] dart callback not register";
    return Value::undefined();
  }

  int32_t timerId = getDartFunc()->requestAnimationFrame(callbackId);

  timerIdToCallbackIdMap.set(timerId, callbackId);
  timerCallbackId = callbackId + 1;

  return Value(timerId);
}

void invokeSetTimeoutCallback(std::unique_ptr<JSContext> &context,
                              int32_t callbackId) {
  std::shared_ptr<Value> callbackValue;
  timerCallbackMap.get(callbackId, callbackValue);

  if (callbackValue == nullptr) {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
    return;
  }

  Object callback = callbackValue->getObject(*context);

  if (callback.isFunction(*context)) {
    callback.asFunction(*context).call(*context, Value::undefined(), 0);
    timerCallbackMap.erase(callbackId);
  } else {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
  }
}

void invokeSetIntervalCallback(std::unique_ptr<JSContext> &context,
                               int32_t callbackId) {
  std::shared_ptr<Value> callbackValue;
  timerCallbackMap.get(callbackId, callbackValue);

  if (callbackValue == nullptr) {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
    return;
  }

  Object callback = callbackValue->getObject(*context);

  if (callback.isFunction(*context)) {
    callback.asFunction(*context).call(*context, Value::undefined(), 0);
  } else {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
  }
}

void invokeRequestAnimationFrameCallback(std::unique_ptr<JSContext> &context,
                                         int32_t callbackId) {
  std::shared_ptr<Value> callbackValue;
  timerCallbackMap.get(callbackId, callbackValue);

  if (callbackValue == nullptr) {
    KRAKEN_LOG(VERBOSE) << "callback is not a function" << callbackId;
    return;
  }

  Object callback = callbackValue->getObject(*context);

  if (callback.isFunction(*context)) {
    callback.asFunction(*context).call(*context, Value::undefined(), 0);
    timerCallbackMap.erase(callbackId);
  } else {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
  }
}

void bindTimer(std::unique_ptr<JSContext> &context) {
  JSA_BINDING_FUNCTION_SIMPLIFIED(*context, context->global(), setTimeout);
  JSA_BINDING_FUNCTION_SIMPLIFIED(*context, context->global(), setInterval);
  JSA_BINDING_FUNCTION_SIMPLIFIED(*context, context->global(),
                                  requestAnimationFrame);
  JSA_BINDING_FUNCTION(*context, context->global(), "clearTimeout", 0,
                       clearTimeout);
  JSA_BINDING_FUNCTION(*context, context->global(), "clearInterval", 0,
                       clearTimeout);
  JSA_BINDING_FUNCTION(*context, context->global(), "cancelAnimationFrame", 0,
                       cancelAnimationFrame);
}

void unbindTimer() {
  timerCallbackMap.reset();
  timerIdToCallbackIdMap.reset();
  timerCallbackId = 1;
}

} // namespace binding
} // namespace kraken
