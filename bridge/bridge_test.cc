/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_test.h"
#include "testframework.h"
#include "jsa.h"
#include "callback_context.h"
#include "dart_methods.h"

namespace kraken {
using namespace alibaba::jsa;
using namespace kraken::foundation;

Value describe(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count < 2) {
    throw JSError(context, "2 argument required, but only " + std::to_string(count) + " present.");
  }

  const Value &name = args[0];
  const Value &func = args[1];

  if (!name.isString()) {
    throw JSError(context, "failed to execute 'describe': parameter 1 (name) should be a string.");
  }
  if (!func.isObject() || !func.getObject(context).isFunction(context)) {
    throw JSError(context, "failed to execute 'describe': parameter 2 (func) should be a function.");
  }

  std::shared_ptr<Value> callbackValue = std::make_unique<Value>(Value(context, func));

  auto *ctx = new CallbackContext(context, callbackValue);
  auto callback = [](void* data) {
    auto *ctx = static_cast<CallbackContext *>(data);
    JSContext &context = ctx->_context;
    ctx->_callback->getObject(context).getFunction(context).call(context);

    delete ctx;
  };

  if (getDartMethod()->describe == nullptr) {
    throw JSError(context, "failed to execute 'describe': dart method (describe) is not registered.");
  }

  getDartMethod()->describe(name.getString(context).utf8(context).c_str(), static_cast<void*>(ctx), callback);

  return Value::undefined();
}


//Value it(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
//
//}


std::atomic<bool> test_inited {false};
bool JSBridgeTest::evaluteTestScript(const std::string &script, const std::string &url, int startLine) {
  if (!context->isValid()) return false;
  binding::updateLocation(url);
  if (test_inited == false) {
    initKrakenTestFramework(context);
    test_inited = true;
  }

  return !context->evaluateJavaScript(script.c_str(), url.c_str(), startLine).isNull();
}

JSBridgeTest::JSBridgeTest(JSBridge *bridge): bridge_(bridge), context(bridge->getContext()) {
  JSA_BINDING_FUNCTION(*context, context->global(), "describe", 2, describe);
}

}