/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_test.h"
#include "bindings/KOM/blob.h"
#include "dart_methods.h"
#include "foundation/bridge_callback.h"
#include "testframework.h"

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
  auto callbackContext = std::make_unique<BridgeCallback::Context>(context, callbackValue);

  auto fn = [](void *data, const char *errmsg) {
    auto ctx = static_cast<BridgeCallback::Context *>(data);
    JSContext &context = ctx->_context;

    if (errmsg != nullptr) {
      ctx->_callback->getObject(context).getFunction(context).call(
        context, {context.global()
                    .getPropertyAsFunction(context, "Error")
                    .call(context, String::createFromAscii(context, errmsg))});
    } else {
      ctx->_callback->getObject(context).getFunction(context).call(context);
    }
    delete ctx;
  };

  BridgeCallback::instance()->registerCallback<void>(std::move(callbackContext),
                                                     [&fn](void *data) { getDartMethod()->refreshPaint(data, fn); });

  return Value::undefined();
}

Value matchImageSnapshot(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  const Value &blob = args[0];
  const Value &screenShotName = args[1];
  const Value &callback = args[2];

  if (!blob.isObject() || !blob.getObject(context).isHostObject(context)) {
    throw JSError(context,
                  "Failed to execute '__kraken_match_screenshot__': parameter 1 (blob) must be an Blob object.");
  }

  if (!screenShotName.isString()) {
    throw JSError(context,
                  "Failed to execute '__kraken_match_image_snapshot__': parameter 2 (match) must be an string.");
  }

  if (!callback.isObject() || !callback.getObject(context).isFunction(context)) {
    throw JSError(context,
                  "Failed to execute '__kraken_match_image_snapshot__': parameter 3 (callback) is not an function.");
  }

  if (getDartMethod()->matchImageSnapshot == nullptr) {
    throw JSError(
      context,
      "Failed to execute '__kraken_match_image_snapshot__': dart method (matchImageSnapshot) is not registered.");
  }

  std::shared_ptr<binding::JSBlob> jsBlob = blob.getObject(context).getHostObject<binding::JSBlob>(context);

  std::string &&name = screenShotName.getString(context).utf8(context);
  std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, callback));
  auto callbackContext = std::make_unique<BridgeCallback::Context>(context, callbackValue);

  auto fn = [](void *data, int8_t result) {
    auto ctx = static_cast<BridgeCallback::Context *>(data);
    JSContext &context = ctx->_context;
    ctx->_callback->getObject(context).getFunction(context).call(context, {Value(static_cast<bool>(result))});
    delete ctx;
  };

  BridgeCallback::instance()->registerCallback<void>(std::move(callbackContext), [&jsBlob, &name, &fn](void *data) {
    getDartMethod()->matchImageSnapshot(jsBlob->bytes(), jsBlob->size(), name.c_str(), data, fn);
  });

  return Value::undefined();
}

Value environment(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (getDartMethod()->environment == nullptr) {
    throw JSError(context, "Failed to execute '__kraken_environment__': dart method (environment) is not registered.");
  }

  const char *env = getDartMethod()->environment();
  return context.global()
    .getPropertyAsObject(context, "JSON")
    .getPropertyAsFunction(context, "parse")
    .call(context, {Value(context, String::createFromAscii(context, env))});
}

JSBridgeTest::JSBridgeTest(JSBridge *bridge) : bridge_(bridge), context(bridge->getContext()) {
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_executeTest__", 0, executeTest);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_refresh_paint__", 0, refreshPaint);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_match_image_snapshot__", 0, matchImageSnapshot);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_environment__", 0, environment);
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
    *context,
    {Value(*context, Function::createFromHostFunction(*context, PropNameID::forUtf8(*context, "done"), 0, done))});
  executeTestCallback.reset();
  executeTestCallback = nullptr;
}

} // namespace kraken
