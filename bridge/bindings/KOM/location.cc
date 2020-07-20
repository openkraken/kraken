/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include "dart_methods.h"
#include "foundation/logging.h"

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

std::string href = "";

void updateLocation(std::string url = "") {
  href = url;
}

Value JSLocation::get(JSContext &context, const PropNameID &name) {
  auto propertyName = name.utf8(context);
  if (propertyName == "reload") {
    auto reloadFunc =
      JSA_CREATE_HOST_FUNCTION(context, "reload", 4,
                               std::bind(&JSLocation::reload, this, std::placeholders::_1, std::placeholders::_2,
                                         std::placeholders::_3, std::placeholders::_4));
    return Value(context, reloadFunc);
  } else if (propertyName == "href") {
    return Value(context, String::createFromUtf8(context, href));
  }

  return Value::undefined();
}

void JSLocation::set(JSContext &, const PropNameID &name, const Value &value) {}

Value JSLocation::reload(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (getDartMethod()->reloadApp == nullptr) {
    throw JSError(context, "Failed to execute 'reload': dart method (reloadApp) is not registered.");
  }

  getDartMethod()->reloadApp(context.getContextId());
  return Value::undefined();
}

void JSLocation::bind(std::unique_ptr<JSContext> &context, Object &window) {
  Object &&locationObject = Object::createFromHostObject(*context, sharedSelf());
  JSA_SET_PROPERTY(*context, window, "location", locationObject);
}

void JSLocation::unbind(std::unique_ptr<JSContext> &context, Object &window) {
  JSA_SET_PROPERTY(*context, window, "location", Value::undefined());
}

std::vector<PropNameID> JSLocation::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> names;
  names.emplace_back(PropNameID::forAscii(context, "href"));
  return names;
}

} // namespace binding
} // namespace kraken
