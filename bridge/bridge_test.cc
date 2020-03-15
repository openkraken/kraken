/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_test.h"
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

JSBridgeTest::JSBridgeTest(JSBridge *bridge) : bridge_(bridge), context(bridge->getContext()) {
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_executeTest__", 0, executeTest);
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