/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifdef KRAKEN_JSC_ENGINE

#include "foundation/bridge_callback.h"
#include "js_context.h"
#include "jsc/jsc_implementation.h"
#include "gtest/gtest.h"
#include <chrono>
#include <condition_variable>
#include <memory>
#include <mutex>
#include <thread>

using namespace kraken::foundation;
using namespace alibaba;
using namespace jsc;

void normalPrint(jsa::JSContext &context, const jsa::JSError &error) {
  std::cerr << error.what() << std::endl;
  FAIL();
}

TEST(BridgeCallback, worksWithNoFunctionLeaks) {
  auto context = std::make_unique<JSCContext>(0, normalPrint, nullptr);
  std::mutex mutex;
  std::condition_variable condition;
  void *sharedData = nullptr;

  auto producterThread = [&]() {
    auto postToChildThread = [&](void *data) {
      std::unique_lock<std::mutex> lock(mutex);
      sharedData = data;
      condition.notify_one();
    };

    HostFunctionType func = [](JSContext &context, const Value &thisVal, const Value *args, size_t count) -> Value {
      return Value::undefined();
    };
    Function hostFunction = Function::createFromHostFunction(*context, PropNameID::forAscii(*context, "func"), 0, func);

    std::shared_ptr<Value> callbackValue = std::make_shared<Value>(jsa::Value(*context, hostFunction));
    auto callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackValue);

    BridgeCallback::instance()->registerCallback<void>(std::move(callbackContext),
                                                       [&postToChildThread](void *data, int32_t contextId) { postToChildThread(data); });
  };

  auto customerThread = [&]() {
    std::unique_lock<std::mutex> lock(mutex);
    condition.wait(lock);
    std::this_thread::sleep_for(std::chrono::microseconds(1));
    auto *ctx = static_cast<BridgeCallback::Context *>(sharedData);
    JSContext &_context = ctx->_context;
    ctx->_callback->getObject(_context).getFunction(_context).call(_context);
  };

  std::thread childA(producterThread);
  std::thread childB(customerThread);

  childA.join();
  childB.join();

  BridgeCallback::instance()->disposeAllCallbacks();
}

#endif
