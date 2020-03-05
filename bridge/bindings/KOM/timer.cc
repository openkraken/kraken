/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "timer.h"
#include "dart_methods.h"
#include "jsa.h"
#include "thread_safe_map.h"
#include "foundation/callback_context.h"
#include <atomic>

namespace kraken {
namespace binding {

using namespace alibaba::jsa;
using namespace kraken::foundation;

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
    // throw JSError inside of dart function callback will directly cause crash
    // so we handle it instead of throw
    JSError error(_context,  "Callback is null");
    obj->_context.reportError(error);
    return;
  }

  Object callback = obj->_callback->getObject(_context);
  callback.asFunction(_context).call(_context, Value::undefined(), 0);
}

void handleRAFPersistentCallback(void *data, double result) {
  auto *obj = static_cast<CallbackContext *>(data);
  JSContext &_context = obj->_context;
  if (!_context.isValid())
    return;

  if (obj->_callback == nullptr) {
    // throw JSError inside of dart function callback will directly cause crash
    // so we handle it instead of throw
    JSError error(_context, "Callback is null");
    obj->_context.reportError(error);
    return;
  }

  Object callback = obj->_callback->getObject(_context);
  callback.asFunction(_context).call(_context, Value(result), 0);
}

void handleTransientCallback(void *data) {
  handlePersistentCallback(data);
  destoryCallbackContext(data);
}

void handleRAFTransientCallback(void *data, double result) {
  handleRAFPersistentCallback(data, result);
  destoryCallbackContext(data);
}

Value setTimeout(JSContext &context, const Value &thisVal, const Value *args,
                 size_t count) {
  if (count < 1) {
    throw JSError(context, "Failed to execute 'setTimeout': 1 argument required, but only 0 present.");
  }

  if (!args->isObject() || !args->getObject(context).isFunction(context)) {
    throw JSError(context, "[setTimeout] first params should be a function");
  }

  std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  auto &&time = args[1];
  int32_t timeout;

  if (time.isUndefined() || count < 2) {
    timeout = 0;
  } else if (time.isNumber()) {
    timeout = time.getNumber();
  } else {
    throw JSError(context, "[setTimeout] timeout should be a number");
  }

  if (getDartMethod()->setTimeout == nullptr) {
    throw JSError(context, "Dart method 'setTimeout' not registered.");
  }

  auto *callbackContext = new CallbackContext(context, callbackValue);

  int32_t timerId = getDartMethod()->setTimeout(
      handleTransientCallback, static_cast<void *>(callbackContext), timeout);

  // `-1` represents ffi error occurred.
  if (timerId == -1) {
    throw JSError(context, "[setTimeout] dart method call failed") ;
  }

  return Value(timerId);
}

Value setInterval(JSContext &context, const Value &thisVal, const Value *args,
                  size_t count) {
  if (count < 1) {
    throw JSError(context, "Failed to execute 'setInterval': 1 argument required, but only 0 present.");
  }

  std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  if (!callbackFunction.isFunction(context)) {
    throw JSError(context, "[setInterval] first params should be a function");
  }

  auto &&time = args[1];
  int32_t delay;

  if (time.isUndefined()) {
    delay = 0;
  } else if (time.isNumber()) {
    delay = time.getNumber();
  } else {
    throw JSError(context, "[setInterval] timeout should be a number");
  }

  if (getDartMethod()->setInterval == nullptr) {
    throw JSError(context, "[setInterval] dart callback not register");
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto *callbackContext = new CallbackContext(context, callbackValue);
  // the callback pointer send and invoked by dart code.
  auto callback = [](void *data) {
    auto *obj = static_cast<CallbackContext *>(data);
    if (!obj->_context.isValid())
      return;
    if (obj->_callback == nullptr) {
      JSError error(obj->_context, "Callback is null");
      obj->_context.reportError(error);
      return;
    }

    Object callback = obj->_callback->getObject(obj->_context);
    if (callback.isFunction(obj->_context)) {
      callback.asFunction(obj->_context)
          .call(obj->_context, Value::undefined(), 0);
    } else {
      JSError error(obj->_context, "Callback is not a function");
      obj->_context.reportError(error);
      return;
    }
  };

  int32_t timerId = getDartMethod()->setInterval(
      handlePersistentCallback, static_cast<void *>(callbackContext), delay);

  if (timerId == -1) {
    throw JSError(context, "[setInterval] dart method call failed");
  }

  return Value(timerId);
}

Value clearTimeout(JSContext &context, const Value &thisVal, const Value *args,
                   size_t count) {
  if (count <= 0) {
    throw JSError(context, "[clearTimeout] function missing parameter");
  }

  const Value &timerId = args[0];
  if (!timerId.isNumber()) {
    throw JSError(context, "[clearTimeout] clearTimeout accept number as parameter");
  }

  auto id = static_cast<int32_t>(timerId.asNumber());

  if (getDartMethod()->clearTimeout == nullptr) {
    throw JSError(context, "[clearTimeout]: dart callback not register");
  }

  getDartMethod()->clearTimeout(id);
  return Value::undefined();
}

Value cancelAnimationFrame(JSContext &context, const Value &thisVal,
                           const Value *args, size_t count) {
  if (count <= 0) {
    throw JSError(context, "[cancelAnimationFrame] function missing parameter");
  }

  const Value &requestId = args[0];
  if (!requestId.isNumber()) {
    throw JSError(context, "[clearAnimationFrame] cancelAnimationFrame accept "
                           "number as parameter");
  }

  auto id = static_cast<int32_t>(requestId.asNumber());

  if (getDartMethod()->cancelAnimationFrame == nullptr) {
    throw JSError(context, "[cancelAnimationFrame]: dart callback not register");
  }

  getDartMethod()->cancelAnimationFrame(id);

  return Value::undefined();
}

Value requestAnimationFrame(JSContext &context, const Value &thisVal,
                            const Value *args, size_t count) {
  if (count <= 0) {
    throw JSError(context,"[requestAnimationFrame] function missing parameters");
  }

  std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  if (!callbackFunction.isFunction(context)) {
    throw JSError(context, "[requestAnimationFrame] first param should be a function");
  }

  // the context pointer which will be pass by pointer address to dart code.
  auto *callbackContext = new CallbackContext(context, callbackValue);

  if (getDartMethod()->requestAnimationFrame == nullptr) {
    throw JSError(context, "[requestAnimationFrame] dart callback not register");
  }

  int32_t requestId = getDartMethod()->requestAnimationFrame(
      handleRAFTransientCallback, static_cast<void *>(callbackContext));

  // `-1` represents some error occurred.
  if (requestId == -1) {
    throw JSError(context, "[requestAnimationFrame] requestAnimationFrame error");
  }

  return Value(requestId);
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
