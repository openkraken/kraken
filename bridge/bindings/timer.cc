/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"
#include "jsa.h"
#include "logging.h"
#include "thread_safe_data.h"
#include "thread_safe_map.h"

#include <kraken_dart_export.h>

namespace kraken {
namespace binding {

ThreadSafeMap<int, alibaba::jsa::Value *> timerCallbackMap;
ThreadSafeMap<int, int> timerIdToCallbackIdMap;
ThreadSafeData<int> timerCallbackId(1);

alibaba::jsa::Value setTimeout(alibaba::jsa::JSContext &rt,
                               const alibaba::jsa::Value &thisVal,
                               const alibaba::jsa::Value *args, size_t count) {
  if (count <= 0) {
    KRAKEN_LOG(WARN) << "[setTimeout] function missing parameter";
    return alibaba::jsa::Value::undefined();
  }

  alibaba::jsa::Value *callbackValue =
      new alibaba::jsa::Value(args[0].getObject(rt));
  alibaba::jsa::Object &&callbackFunction = callbackValue->getObject(rt);

  if (!callbackFunction.isFunction(rt)) {
    KRAKEN_LOG(WARN) << "[setTimeout] first params should be a function";
    return alibaba::jsa::Value::undefined();
  }

  auto &&timeout = args[1];
  int time;

  if (timeout.isUndefined() || count < 2) {
    time = 0;
  } else if (timeout.isNumber()) {
    time = timeout.getNumber();
  } else {
    KRAKEN_LOG(WARN) << "[setTimeout] timeout should be a number";
    return alibaba::jsa::Value::undefined();
  }

  int callbackId;
  timerCallbackId.get(callbackId);

  timerCallbackMap.set(callbackId, callbackValue);

  int timerId = KrakenRegisterSetTimeout(callbackId, time);

  timerIdToCallbackIdMap.set(timerId, callbackId);

  timerCallbackId.set(callbackId + 1);

  return alibaba::jsa::Value(timerId);
}

alibaba::jsa::Value setInterval(alibaba::jsa::JSContext &rt,
                                const alibaba::jsa::Value &thisVal,
                                const alibaba::jsa::Value *args, size_t count) {
  if (count <= 0) {
    KRAKEN_LOG(WARN) << "[setInterval] function missing parameter";
    return alibaba::jsa::Value::undefined();
  }

  alibaba::jsa::Value *callbackValue =
      new alibaba::jsa::Value(args[0].getObject(rt));
  alibaba::jsa::Object &&callbackFunction = callbackValue->getObject(rt);

  if (!callbackFunction.isFunction(rt)) {
    KRAKEN_LOG(WARN) << "[setInterval] first params should be a function";
    return alibaba::jsa::Value::undefined();
  }

  auto &&timeout = args[1];
  int time;

  if (timeout.isUndefined()) {
    time = 0;
  } else if (timeout.isNumber()) {
    time = timeout.getNumber();
  } else {
    KRAKEN_LOG(WARN) << "[setInterval] timeout should be a number";
    return alibaba::jsa::Value::undefined();
  }

  int callbackId;
  timerCallbackId.get(callbackId);

  timerCallbackMap.set(callbackId, callbackValue);

  int timerId = KrakenRegisterSetInterval(callbackId, time);

  timerIdToCallbackIdMap.set(timerId, callbackId);
  timerCallbackId.set(callbackId + 1);

  return alibaba::jsa::Value(timerId);
}

alibaba::jsa::Value clearTimeout(alibaba::jsa::JSContext &rt,
                                 const alibaba::jsa::Value &thisVal,
                                 const alibaba::jsa::Value *args,
                                 size_t count) {
  if (count <= 0) {
    KRAKEN_LOG(WARN) << "[clearTimeout] function missing parameter";
    return alibaba::jsa::Value::undefined();
  }

  const alibaba::jsa::Value &timerId = args[0];
  if (!timerId.isNumber()) {
    KRAKEN_LOG(WARN)
        << "[clearTimeout] clearTimeout accept number as parameter";
    return alibaba::jsa::Value::undefined();
  }

  int timer = static_cast<int>(timerId.asNumber());
  int callbackId = 0;
  timerIdToCallbackIdMap.get(timer, callbackId);

  if (callbackId == 0) {
    KRAKEN_LOG(WARN) << "[clearTimeout] can not stop timer of timerId: "
                     << timer;
    return alibaba::jsa::Value::undefined();
  }

  KrakenInvokeClearTimeout(timer);

  alibaba::jsa::Value *callbackValue;

  timerCallbackMap.get(callbackId, callbackValue);

  if (callbackValue == nullptr ||
      !callbackValue->getObject(rt).isFunction(rt)) {
    KRAKEN_LOG(WARN) << "[clearTimeout] can not stop timer of callbackId: "
                     << callbackId;
    return alibaba::jsa::Value::undefined();
  }

  delete callbackValue;

  timerCallbackMap.erase(callbackId);
  return alibaba::jsa::Value::undefined();
}

void invokeSetTimeoutCallback(alibaba::jsa::JSContext *context,
                              const int callbackId) {
  alibaba::jsa::Value *callbackValue;
  timerCallbackMap.get(callbackId, callbackValue);

  if (callbackValue == nullptr) {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
    return;
  }

  alibaba::jsa::Object callback = callbackValue->getObject(*context);

  if (callback.isFunction(*context)) {
    callback.asFunction(*context).call(*context,
                                       alibaba::jsa::Value::undefined(), 0);
    delete callbackValue;
    timerCallbackMap.erase(callbackId);
  } else {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
  }
}

void invokeSetIntervalCallback(alibaba::jsa::JSContext *context,
                               const int callbackId) {
  alibaba::jsa::Value *callbackValue;
  timerCallbackMap.get(callbackId, callbackValue);

  if (callbackValue == nullptr) {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
    return;
  }

  alibaba::jsa::Object callback = callbackValue->getObject(*context);

  if (callback.isFunction(*context)) {
    callback.asFunction(*context).call(*context,
                                       alibaba::jsa::Value::undefined(), 0);
  } else {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
  }
}

void bindTimer(alibaba::jsa::JSContext *context) {
  JSA_BINDING_FUNCTION_SIMPLIFIED(*context, context->global(), setTimeout);
  JSA_BINDING_FUNCTION_SIMPLIFIED(*context, context->global(), setInterval);
  JSA_BINDING_FUNCTION(*context, context->global(), "clearTimeout", 0,
                       clearTimeout);
  JSA_BINDING_FUNCTION(*context, context->global(), "clearInterval", 0,
                       clearTimeout);
}

} // namespace binding
} // namespace kraken
