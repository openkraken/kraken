/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_test.h"
#include "bindings/jsa/KOM/blob.h"
#include "dart_methods.h"
#include "foundation/bridge_callback.h"
#include "testframework.h"

namespace kraken {
using namespace alibaba::jsa;
using namespace kraken::foundation;

bool JSBridgeTest::evaluateTestScripts(const uint16_t* code, size_t codeLength, const char* sourceURL, int startLine) {
  if (!context->isValid()) return false;
  binding::updateLocation(sourceURL);
  return !context->evaluateJavaScript(code, codeLength, sourceURL, startLine).isNull();
}

Value executeTest(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  const Value &callback = args[0];

  if (!args[0].isObject() || !args[0].getObject(context).isFunction(context)) {
    throw JSError(context, "Failed to execute 'executeTest': parameter 1 (callback) is not an function.");
  }

  auto bridge = static_cast<JSBridge*>(context.getOwner());
  auto bridgeTest = static_cast<JSBridgeTest*>(bridge->owner);
  bridgeTest->executeTestCallback = std::make_shared<Value>(Value(context, args[0]));

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

  auto fn = [](void *callbackContext, int32_t contextId, const char *errmsg) {
    auto ctx = static_cast<BridgeCallback::Context *>(callbackContext);
    JSContext &_context = ctx->_context;

    if (errmsg != nullptr) {
      ctx->_callback->getObject(_context).getFunction(_context).call(
        _context, {_context.global()
                     .getPropertyAsFunction(_context, "Error")
                     .call(_context, String::createFromAscii(_context, errmsg))});
    } else {
      ctx->_callback->getObject(_context).getFunction(_context).call(_context);
    }
    auto bridge = static_cast<JSBridge *>(ctx->_context.getOwner());
    bridge->bridgeCallback.freeBridgeCallbackContext(ctx);
  };

  auto bridge = static_cast<JSBridge*>(context.getOwner());
  bridge->bridgeCallback.registerCallback<void>(
    std::move(callbackContext),
    [&fn](BridgeCallback::Context *callbackContext, int32_t contextId) {
      getDartMethod()->refreshPaint(callbackContext, contextId, fn);
    });

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

  String name = screenShotName.getString(context);
  const uint16_t* unicodePtr = name.getUnicodePtr(context);
  size_t unicodeLength = name.unicodeLength(context);

  NativeString nativeString;
  nativeString.string = unicodePtr;
  nativeString.length = unicodeLength;

  std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, callback));
  auto callbackContext = std::make_unique<BridgeCallback::Context>(context, callbackValue);

  auto fn = [](void *callbackContext, int32_t contextId, int8_t result) {
    auto ctx = static_cast<BridgeCallback::Context *>(callbackContext);
    JSContext &_context = ctx->_context;
    ctx->_callback->getObject(_context).getFunction(_context).call(_context, {Value(static_cast<bool>(result))});
    auto bridge = static_cast<JSBridge *>(ctx->_context.getOwner());
    bridge->bridgeCallback.freeBridgeCallbackContext(ctx);
  };

  auto bridge = static_cast<JSBridge*>(context.getOwner());
  bridge->bridgeCallback.registerCallback<void>(
    std::move(callbackContext),
    [&jsBlob, &nativeString, &fn](BridgeCallback::Context *callbackContext, int32_t contextId) {
      getDartMethod()->matchImageSnapshot(callbackContext, contextId, jsBlob->bytes(), jsBlob->size(),
                                          &nativeString, fn);
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

Value simulatePointer(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (getDartMethod()->simulatePointer == nullptr) {
    throw JSError(context, "Failed to execute '__kraken_simulate_pointer__': dart method(simulatePointer) is not registered.");
  }

  const Value &firstArgs = args[0];
  if (!firstArgs.isObject()) {
    throw JSError(context, "Failed to execute '__kraken_simulate_pointer__': first arguments should be an array.");
  }

  Array &&inputArray = firstArgs.getObject(context).getArray(context);
  auto **mousePointerList = new MousePointer* [inputArray.length(context)];

  for (int i = 0; i < inputArray.length(context); i ++) {
    auto mouse = new MousePointer();
    Array &&params = inputArray.getValueAtIndex(context, i).getObject(context).getArray(context);
    mouse->contextId = context.getContextId();
    mouse->x = params.getValueAtIndex(context, 0).getNumber();
    mouse->y = params.getValueAtIndex(context, 1).getNumber();
    mouse->change = params.getValueAtIndex(context, 2).getNumber();
    mousePointerList[i] = mouse;
  }

  getDartMethod()->simulatePointer(mousePointerList, inputArray.length(context));

  delete[] mousePointerList;

  return Value::undefined();
}

JSBridgeTest::JSBridgeTest(JSBridge *bridge) : bridge_(bridge), context(bridge->getContext()) {
  bridge->owner = this;
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_executeTest__", 0, executeTest);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_refresh_paint__", 0, refreshPaint);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_match_image_snapshot__", 0, matchImageSnapshot);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_environment__", 0, environment);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_simulate_pointer__", 0, simulatePointer);

  initKrakenTestFramework(bridge);
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
    String statusString = status.getString(context);
    NativeString nativeString;
    nativeString.string = statusString.getUnicodePtr(context);
    nativeString.length = statusString.unicodeLength(context);
    executeCallback(context.getContextId(), &nativeString);
    return Value::undefined();
  };

  executeTestCallback->getObject(*context).getFunction(*context).call(
    *context,
    {Value(*context, Function::createFromHostFunction(*context, PropNameID::forUtf8(*context, "done"), 0, done))});
  executeTestCallback.reset();
  executeTestCallback = nullptr;
}

} // namespace kraken
