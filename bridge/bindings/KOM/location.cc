/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include "logging.h"
#include "window.h"
#include <kraken_dart_export.h>

namespace kraken {
namespace binding {

Value JSLocation::get(JSContext &context, const PropNameID &name) {
  auto _name = name.utf8(context);
  if (_name == "reload") {
    auto reloadFunc = JSA_CREATE_HOST_FUNCTION_SIMPLIFIED(
        context, std::bind(&JSLocation::reload, this, std::placeholders::_1,
                           std::placeholders::_2, std::placeholders::_3,
                           std::placeholders::_4));
    return Value(context, reloadFunc);
  }

  return Value::undefined();
}

void JSLocation::set(JSContext &, const PropNameID &name, const Value &value) {}

Value JSLocation::reload(JSContext &context, const Value &thisVal,
                         const Value *args, size_t count) {
  KRAKEN_LOG(VERBOSE) << "reload function called" << std::endl;

  KrakenInvokeDartFromCpp("reload", "");

  return Value::undefined();
}

void JSLocation::bind(JSContext *context, Object &window) {
  JSA_SET_PROPERTY(
      *context, window, "location",
      alibaba::jsa::Object::createFromHostObject(*context, sharedSelf()));
}

} // namespace binding
} // namespace kraken
