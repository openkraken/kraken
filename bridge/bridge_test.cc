/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_test.h"
#include "callback_context.h"
#include "dart_methods.h"
#include "jsa.h"
#include "testframework.h"

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
  auto callback = [](void *data) {
    auto *ctx = static_cast<CallbackContext *>(data);
    JSContext &context = ctx->_context;
    ctx->_callback->getObject(context).getFunction(context).call(context);

    delete ctx;
  };

  if (getDartMethod()->describe == nullptr) {
    throw JSError(context, "failed to execute 'describe': dart method (describe) is not registered.");
  }

  getDartMethod()->describe(name.getString(context).utf8(context).c_str(), static_cast<void *>(ctx), callback);

  return Value::undefined();
}

Value it(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count < 2) {
    throw JSError(context, "2 argument required, but only " + std::to_string(count) + " present.");
  }

  const Value &name = args[0];
  const Value &func = args[1];

  if (!name.isString()) {
    throw JSError(context, "failed to execute 'it': parameter 1 (name) should be a string.");
  }
  if (!func.isObject() || !func.getObject(context).isFunction(context)) {
    throw JSError(context, "failed to execute 'it': parameter 2 (func) should be a function.");
  }

  std::shared_ptr<Value> callbackValue = std::make_unique<Value>(Value(context, func));
  auto *ctx = new CallbackContext(context, callbackValue);
  auto callback = [](void *data, int32_t completerId) {
    auto *ctx = static_cast<CallbackContext *>(data);
    JSContext &context = ctx->_context;

    if (getDartMethod()->itDone == nullptr) {
      throw JSError(context, "failed to execute 'done': dart method (itDone) is not registered.");
    }

    // the callback when js callback resolved with done();
    auto doneCallback = [=](JSContext &context, const Value &thisVal, const Value *args, size_t count) -> Value {
      if (count == 0) {
        // notify dart this test is success.
        getDartMethod()->itDone(completerId, nullptr);
        return Value::undefined();
      }

      if (count > 1) {
        throw JSError(context, "failed to execute 'done': only 1 parameter is accepted.");
      }

      const Value &error = args[0];
      if (error.isObject()) {
        JSError err(context, Value(context, error));
        getDartMethod()->itDone(completerId, err.what());
      } else {
        JSError err(context, error.toString(context).utf8(context));
        getDartMethod()->itDone(completerId, err.what());
      }

      // clear CallbackContext's memory
      return Value::undefined();
    };

    ctx->_callback->getObject(context).getFunction(context).call(
      context, {Function::createFromHostFunction(context, PropNameID::forAscii(context, "done"), 1, doneCallback)});
  };

  if (getDartMethod()->it == nullptr) {
    throw JSError(context, "failed to execute 'it': dart method (it) is not registered.");
  }

  getDartMethod()->it(name.getString(context).utf8(context).c_str(), static_cast<void *>(ctx), callback);

  return Value::undefined();
}

Value beforeEach(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count != 1) {
    throw JSError(context, "1 argument required, but only " + std::to_string(count) + " present.");
  }

  const Value &func = args[0];
  if (!func.isObject() || !func.getObject(context).isFunction(context)) {
    throw JSError(context, "failed to execute 'beforEach': parameter 1 (func) should be a function.");
  }

  std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, func));
  auto *ctx = new CallbackContext(context, callbackValue);
  auto callback = [](void *data) {
    auto *ctx = static_cast<CallbackContext *>(data);
    JSContext &context = ctx->_context;

    if (getDartMethod()->beforeEach == nullptr) {
      throw JSError(context, "failed to execute 'beforeEach': dart method (beforeEach) is not registered.");
    }

    ctx->_callback->getObject(context).getFunction(context).call(context);
  };

  if (getDartMethod()->beforeEach == nullptr) {
    throw JSError(context, "failed to execute 'beforeEach': dart method (beforEach) is not registered.");
  }

  getDartMethod()->beforeEach(static_cast<void *>(ctx), callback);

  return Value::undefined();
}

Value beforeAll(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count != 1) {
    throw JSError(context, "1 argument required, but only " + std::to_string(count) + " present.");
  }

  const Value &func = args[0];
  if (!func.isObject() || !func.getObject(context).isFunction(context)) {
    throw JSError(context, "failed to execute 'beforeAll': parameter 1 (func) should be a function.");
  }

  std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, func));
  auto *ctx = new CallbackContext(context, callbackValue);
  auto callback = [](void *data) {
    auto *ctx = static_cast<CallbackContext *>(data);
    JSContext &context = ctx->_context;

    if (getDartMethod()->beforeAll == nullptr) {
      throw JSError(context, "failed to execute 'beforeAll': dart method (beforeAll) is not registered.");
    }

    ctx->_callback->getObject(context).getFunction(context).call(context);
  };

  if (getDartMethod()->beforeAll == nullptr) {
    throw JSError(context, "failed to execute 'beforeAll': dart method (beforeAll) is not registered.");
  }

  getDartMethod()->beforeAll(static_cast<void *>(ctx), callback);

  return Value::undefined();
}

Value afterEach(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count != 1) {
    throw JSError(context, "1 argument required, but only " + std::to_string(count) + " present.");
  }

  const Value &func = args[0];
  if (!func.isObject() || !func.getObject(context).isFunction(context)) {
    throw JSError(context, "failed to execute 'afterEach': parameter 1 (func) should be a function.");
  }

  std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, func));
  auto *ctx = new CallbackContext(context, callbackValue);
  auto callback = [](void *data) {
    auto *ctx = static_cast<CallbackContext *>(data);
    JSContext &context = ctx->_context;

    if (getDartMethod()->afterEach == nullptr) {
      throw JSError(context, "failed to execute 'afterEach': dart method (afterEach) is not registered.");
    }

    ctx->_callback->getObject(context).getFunction(context).call(context);
  };

  if (getDartMethod()->afterEach == nullptr) {
    throw JSError(context, "failed to execute 'afterEach': dart method (afterEach) is not registered.");
  }

  getDartMethod()->afterEach(static_cast<void *>(ctx), callback);

  return Value::undefined();
}

Value afterAll(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count != 1) {
    throw JSError(context, "1 argument required, but only " + std::to_string(count) + " present.");
  }

  const Value &func = args[0];
  if (!func.isObject() || !func.getObject(context).isFunction(context)) {
    throw JSError(context, "failed to execute 'afterAll': parameter 1 (func) should be a function.");
  }

  std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, func));
  auto *ctx = new CallbackContext(context, callbackValue);
  auto callback = [](void *data) {
    auto *ctx = static_cast<CallbackContext *>(data);
    JSContext &context = ctx->_context;

    if (getDartMethod()->afterAll == nullptr) {
      throw JSError(context, "failed to execute 'afterAll': dart method (afterAll) is not registered.");
    }

    ctx->_callback->getObject(context).getFunction(context).call(context);
  };

  if (getDartMethod()->afterAll== nullptr) {
    throw JSError(context, "failed to execute 'afterALl': dart method (afterAll) is not registered.");
  }

  getDartMethod()->afterAll(static_cast<void *>(ctx), callback);

  return Value::undefined();
}

bool JSBridgeTest::evaluteTestScript(const std::string &script, const std::string &url, int startLine) {
  if (!context->isValid()) return false;
  binding::updateLocation(url);
  return !context->evaluateJavaScript(script.c_str(), url.c_str(), startLine).isNull();
}

JSBridgeTest::JSBridgeTest(JSBridge *bridge) : bridge_(bridge), context(bridge->getContext()) {
  JSA_BINDING_FUNCTION(*context, context->global(), "describe", 2, describe);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_it__", 2, it);
  JSA_BINDING_FUNCTION(*context, context->global(), "beforeEach", 1, beforeEach);
  JSA_BINDING_FUNCTION(*context, context->global(), "beforeAll", 1, beforeAll);
  JSA_BINDING_FUNCTION(*context, context->global(), "afterEach", 1, afterEach);
  JSA_BINDING_FUNCTION(*context, context->global(), "afterAll", 1, afterAll);

  initKrakenTestFramework(bridge->getContext());
}

} // namespace kraken