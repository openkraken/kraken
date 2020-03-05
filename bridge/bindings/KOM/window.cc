/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include <cassert>
#include "dart_methods.h"

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

void JSWindow::invokeOnloadCallback(std::unique_ptr<JSContext> &context) {
  if (_onLoadCallback.isUndefined()) {
    return;
  }

  auto funcObject = _onLoadCallback.getObject(*context);

  if (funcObject.isFunction(*context)) {
    funcObject.asFunction(*context).call(*context);
  } else {
    throw JSError(*context, "onLoad callback is not a function");
  }
}

void JSWindow::invokeOnPlatformBrightnessChangedCallback(std::unique_ptr<JSContext> &context) {
  if (_onPlatformBrightnessChanged.isUndefined()) {
    return;
  }

  auto funcObject = _onPlatformBrightnessChanged.getObject(*context);

  if (funcObject.isFunction(*context)) {
    funcObject.asFunction(*context).call(*context);
  } else {
    throw JSError(*context, "onPlatformBrightnessChanged callback is not a function");
  }
}

Value JSWindow::get(JSContext &context,
                                  const PropNameID &name) {
  auto _name = name.utf8(context);
  if (_name == "devicePixelRatio") {
    if (getDartMethod()->devicePixelRatio == nullptr) {
      throw JSError(context, "devicePixelRatio dart callback not register");
    }

    double devicePixelRatio = getDartMethod()->devicePixelRatio();
    return Value(devicePixelRatio);
  } else if (_name == "colorScheme") {
    if (getDartMethod()->platformBrightness == nullptr) {
      throw JSError(context, "platformBrightness dart callback not register");
    }

    return String::createFromUtf8(context, getDartMethod()->platformBrightness());
  } else if (_name == "location") {
    return Value(context, Object::createFromHostObject(context, location_->shared_from_this()));
  }

  return Value::undefined();
}

void JSWindow::set(JSContext &context, const PropNameID &name, const Value &value) {
  auto _name = name.utf8(context);
  if (_name == "onLoad") {
    _onLoadCallback = Value(context, value);
  } else if (_name == "onColorSchemeChange") {
    if (getDartMethod()->onPlatformBrightnessChanged == nullptr) {
      throw JSError(context, "onPlatformBrightnessChanged dart callback not register");
    }
    _onPlatformBrightnessChanged = Value(context, value);
    getDartMethod()->onPlatformBrightnessChanged();
  }
}

void JSWindow::bind(std::unique_ptr<JSContext> &context) {
  assert(context != nullptr);

  Object&& window =
      Object::createFromHostObject(*context, sharedSelf());
  location_->bind(context, window);
  JSA_SET_PROPERTY(*context, context->global(), "__kraken_window__", window);
}

void JSWindow::unbind(std::unique_ptr<JSContext> &context) {
  Value &&window = JSA_GET_PROPERTY(*context, context->global(), "__kraken_window__");
  Object &&object = window.getObject(*context);
  location_->unbind(context, object);
  _onLoadCallback = Value::undefined();
  _onPlatformBrightnessChanged = Value::undefined();
  JSA_SET_PROPERTY(*context, context->global(), "__kraken_window__", Value::undefined());
}

std::vector<PropNameID> JSWindow::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> names;
  names.emplace_back(PropNameID::forUtf8(context, "colorScheme"));
  names.emplace_back(PropNameID::forUtf8(context, "devicePixelRatio"));
  names.emplace_back(PropNameID::forUtf8(context, "location"));
  names.emplace_back(PropNameID::forUtf8(context, "onColorSchemeChange"));
  names.emplace_back(PropNameID::forUtf8(context, "onLoad"));
  return names;
}

} // namespace binding
} // namespace kraken
