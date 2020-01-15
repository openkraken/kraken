/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"

#include "logging.h"
#include <cassert>

namespace kraken {
namespace binding {

alibaba::jsa::Value *callback(nullptr);
alibaba::jsa::Value *initDevicePixelRatioCallback(nullptr);

alibaba::jsa::Value JSWindow::connect(alibaba::jsa::JSContext &context,
                                         const alibaba::jsa::Value &thisVal,
                                         const alibaba::jsa::Value *args,
                                         size_t count) {
  if (count != 2) {
    KRAKEN_LOG(WARN) << "__connect__ should only have two parameter";
    return alibaba::jsa::Value::undefined();
  }

  const alibaba::jsa::Value &func = args[0];
  const alibaba::jsa::Value &init = args[1];
  if (!func.getObject(context).isFunction(context) || !init.getObject(context).isFunction(context)) {
    KRAKEN_LOG(WARN) << "__connect__: the parameter should be an function";
    return alibaba::jsa::Value::undefined();
  }

  callback = new alibaba::jsa::Value(func.getObject(context));
  initDevicePixelRatioCallback = new alibaba::jsa::Value(init.getObject(context));
  return alibaba::jsa::Value::undefined();
}

void JSWindow::invokeOnloadCallback(alibaba::jsa::JSContext *context) {
  //  alibaba::jsa::Value* callback;
  //  callbackData.get(callback);
  if (callback == nullptr) {
    KRAKEN_LOG(WARN) << "__bind_load__: callback is nullptr";
    return;
  }

  alibaba::jsa::Object funcObj = callback->asObject(*context);

  if (funcObj.isFunction(*context)) {
    funcObj.asFunction(*context).call(*context);
  } else {
    KRAKEN_LOG(VERBOSE) << "__bind_load__ callback is not a function";
  }
}

void JSWindow::initDevicePixelRatio(alibaba::jsa::JSContext *context, const int dp) {
  if (initDevicePixelRatioCallback == nullptr) {
    KRAKEN_LOG(WARN) << "__init_dip__: callback is nullptr";
    return;
  }

  alibaba::jsa::Object initObj = initDevicePixelRatioCallback->asObject(*context);

  if (initObj.isFunction(*context)) {
    initObj.asFunction(*context).call(*context, {alibaba::jsa::Value(dp)});
  } else {
    KRAKEN_LOG(VERBOSE) << "__init_dip__ callback is not a function";
  }
}


alibaba::jsa::Value JSWindow::get(alibaba::jsa::JSContext &context,
                                  const alibaba::jsa::PropNameID &name) {
  auto _name = name.utf8(context);
  using namespace alibaba::jsa;
  if (_name == "connect") {
    auto bindOnloadFunc = JSA_CREATE_HOST_FUNCTION_SIMPLIFIED(
        context, std::bind(&JSWindow::connect, this, std::placeholders::_1,
                           std::placeholders::_2, std::placeholders::_3,
                           std::placeholders::_4));
    return alibaba::jsa::Value(context, bindOnloadFunc);
  }
  return alibaba::jsa::Value::undefined();
}

void JSWindow::bind(alibaba::jsa::JSContext *context) {
  assert(context != nullptr);
  JSA_BINDING_GLOBAL_HOST_OBJECT(*context, "__kraken_window__", sharedSelf());
}
} // namespace binding
} // namespace kraken
