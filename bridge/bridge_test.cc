/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_test.h"
#include "callback_context.h"
#include "dart_methods.h"
#include "testframework.h"
#include <iostream>

namespace kraken {
using namespace alibaba::jsa;
using namespace kraken::foundation;

bool JSBridgeTest::evaluateTestScripts(const std::string &script, const std::string &url, int startLine) {
  if (!context->isValid()) return false;
  binding::updateLocation(url);
  return !context->evaluateJavaScript(script.c_str(), url.c_str(), startLine).isNull();
}

std::shared_ptr<Value> executeTestCallback{nullptr};

Value executeTest(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  const Value &callback = args[0];

  if (!args[0].isObject() || !args[0].getObject(context).isFunction(context)) {
    throw JSError(context, "Failed to execute 'executeTest': parameter 1 (callback) is not an function.");
  }

  executeTestCallback = std::make_shared<Value>(Value(context, args[0]));

  return Value::undefined();
}

Value refreshPaint(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  const Value &callback = args[0];

  if (!callback.isObject() || !callback.getObject(context).isFunction(context)) {
    throw JSError(context, "Failed to execute '_kraken_refresh_paint__': parameter 1 (callback) is not an function.");
  }

  if (getDartMethod()->refreshPaint == nullptr) {
    throw JSError(context,
                  "Failed to execute '__kraken_refresh_paint__': dart method (refreshPaint) is not registered.");
  }

  std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, callback));
  auto ctx = new CallbackContext(context, callbackValue);

  auto fn = [](void *data) {
    auto ctx = static_cast<CallbackContext *>(data);
    JSContext &context = ctx->_context;
    ctx->_callback->getObject(context).getFunction(context).call(context);
    delete ctx;
  };

  getDartMethod()->refreshPaint(static_cast<void *>(ctx), fn);

  return Value::undefined();
}

Value matchScreenShot(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  const Value &screenShotName = args[0];
  const Value &callback = args[1];

  if (!screenShotName.isString()) {
    throw JSError(context,
                  "Failed to execute '__kraken_match_screenshot__': parameter 1 (screenShotName) must be an string.");
  }

  if (!callback.isObject() || !callback.getObject(context).isFunction(context)) {
    throw JSError(context,
                  "Failed to execute '__kraken_match_screenshot__': parameter 2 (callback) is not an function.");
  }

  if (getDartMethod()->matchScreenShot == nullptr) {
    throw JSError(context,
                  "Failed to execute '__kraken_match_screenshot__': dart method (matchScreenShot) is not registered.");
  }

  std::string &&name = screenShotName.getString(context).utf8(context);
  std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, callback));
  auto ctx = new CallbackContext(context, callbackValue);

  auto fn = [](void *data, int8_t result) {
    auto ctx = static_cast<CallbackContext *>(data);
    JSContext &context = ctx->_context;
    ctx->_callback->getObject(context).getFunction(context).call(context, {Value(static_cast<bool>(result))});
    delete ctx;
  };

  getDartMethod()->matchScreenShot(name.c_str(), static_cast<void *>(ctx), fn);

  return Value::undefined();
}

JSBridgeTest::JSBridgeTest(JSBridge *bridge) : bridge_(bridge), context(bridge->getContext()) {
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_executeTest__", 0, executeTest);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_refresh_paint__", 0, refreshPaint);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_match_screenshot__", 0, matchScreenShot);
  initKrakenTestFramework(bridge->getContext());
}

void JSBridgeTest::invokeExecuteTest(ExecuteCallback executeCallback) {
  if (executeTestCallback == nullptr) {
    return;
  }

  auto done = [=](JSContext &context, const Value &thisVal, const Value *args, size_t count) -> Value {
    const Value &status = args[0];
    if (!status.isString()) {
      throw JSError(context, "failed to execute 'done': parameter 1 (status) is not a string");
    }
    executeCallback(status.getString(context).utf8(context).c_str());
    return Value::undefined();
  };

  executeTestCallback->getObject(*context).getFunction(*context).call(
    *context, {Function::createFromHostFunction(*context, PropNameID::forUtf8(*context, "done"), 0, done)});
  executeTestCallback.reset();
  executeTestCallback = nullptr;
}

} // namespace kraken