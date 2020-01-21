/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"
#include "jsa.h"
#include "logging.h"
#include "thread_safe_map.h"
#include <atomic>

#include <kraken_dart_export.h>

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

ThreadSafeMap<int, std::shared_ptr<Value>> timerCallbackMap;
ThreadSafeMap<int, int> timerIdToCallbackIdMap;
std::atomic<int> timerCallbackId = {1};

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
  int time;

  if (timeout.isUndefined() || count < 2) {
    time = 0;
  } else if (timeout.isNumber()) {
    time = timeout.getNumber();
  } else {
    KRAKEN_LOG(WARN) << "[setTimeout] timeout should be a number";
    return Value::undefined();
  }

  int callbackId = timerCallbackId.load();

  timerCallbackMap.set(callbackId, callbackValue);

  int timerId = KrakenRegisterSetTimeout(callbackId, time);

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
  int time;

  if (timeout.isUndefined()) {
    time = 0;
  } else if (timeout.isNumber()) {
    time = timeout.getNumber();
  } else {
    KRAKEN_LOG(WARN) << "[setInterval] timeout should be a number";
    return Value::undefined();
  }

  int callbackId = timerCallbackId.load();

  timerCallbackMap.set(callbackId, callbackValue);

  int timerId = KrakenRegisterSetInterval(callbackId, time);

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

  int timer = static_cast<int>(timerId.asNumber());
  int callbackId = 0;
  timerIdToCallbackIdMap.get(timer, callbackId);

  if (callbackId == 0) {
    KRAKEN_LOG(WARN) << "[clearTimeout] can not stop timer of timerId: "
                     << timer;
    return Value::undefined();
  }

  KrakenInvokeClearTimeout(timer);

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

  int callbackId = timerCallbackId.load();

  timerCallbackMap.set(callbackId, callbackValue);

  int timerId = KrakenRegisterRequestAnimationFrame(callbackId);

  timerIdToCallbackIdMap.set(timerId, callbackId);
  timerCallbackId = callbackId + 1;

  return Value(timerId);
}

void invokeSetTimeoutCallback(JSContext *context, const int callbackId) {
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

void invokeSetIntervalCallback(JSContext *context, const int callbackId) {
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

void invokeRequestAnimationFrameCallback(JSContext *context,
                                         const int callbackId) {
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

void bindTimer(JSContext *context) {
  JSA_BINDING_FUNCTION_SIMPLIFIED(*context, context->global(), setTimeout);
  JSA_BINDING_FUNCTION_SIMPLIFIED(*context, context->global(), setInterval);
  JSA_BINDING_FUNCTION_SIMPLIFIED(*context, context->global(),
                                  requestAnimationFrame);
  JSA_BINDING_FUNCTION(*context, context->global(), "clearTimeout", 0,
                       clearTimeout);
  JSA_BINDING_FUNCTION(*context, context->global(), "clearInterval", 0,
                       clearTimeout);
  JSA_BINDING_FUNCTION(*context, context->global(), "cancelAnimationFrame", 0,
                       clearTimeout);
}

void unbindTimer() {
  timerCallbackMap.reset();
  timerIdToCallbackIdMap.reset();
  timerCallbackId = 1;
}

} // namespace binding
} // namespace kraken
