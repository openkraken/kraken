/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "kraken_dart_export.h"
#include "logging.h"
#include <cassert>

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

void JSWindow::invokeOnloadCallback(alibaba::jsa::JSContext *context) {
  if (_onloadCallback.isUndefined()) {
    return;
  }

  KRAKEN_LOG(VERBOSE ) << "invoke onload" << std::endl;

  auto funcObject = _onloadCallback.getObject(*context);

  if (funcObject.isFunction(*context)) {
    funcObject.asFunction(*context).call(*context);
  } else {
    KRAKEN_LOG(VERBOSE) << "__bind_load__ callback is not a function";
  }
}

void JSWindow::initDevicePixelRatio(alibaba::jsa::JSContext *context, int dp) {
  _devicePixelRatio = dp;
}

alibaba::jsa::Value JSWindow::get(alibaba::jsa::JSContext &context,
                                  const alibaba::jsa::PropNameID &name) {
  auto _name = name.utf8(context);
  if (_name == "devicePixelRatio") {
    return Value(_devicePixelRatio);
  } else if (_name == "location") {
    return Value(context, alibaba::jsa::Object::createFromHostObject(context, location_->shared_from_this()));
  }

  return alibaba::jsa::Value::undefined();
}

void JSWindow::set(JSContext &context, const PropNameID &name, const Value &value) {
  auto _name = name.utf8(context);
  if (_name == "onload") {
    _onloadCallback = Value(context, value);
  }
}

void JSWindow::bind(alibaba::jsa::JSContext *context) {
  assert(context != nullptr);

  Object&& window =
      alibaba::jsa::Object::createFromHostObject(*context, sharedSelf());
  location_->bind(context, window);
  JSA_GLOBAL_SET_PROPERTY(*context, "__kraken_window__", window);
}

void JSWindow::unbind(JSContext *context) {
  Value &&window = JSA_GLOBAL_GET_PROPERTY(*context, "__kraken_window__");
  Object &&object = window.getObject(*context);
  location_->unbind(context, object);
  _onloadCallback = Value::undefined();
  JSA_GLOBAL_SET_PROPERTY(*context, "__kraken_window__", Value::undefined());
}

} // namespace binding
} // namespace kraken
