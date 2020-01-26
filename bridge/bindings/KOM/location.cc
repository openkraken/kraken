/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include "logging.h"
#include "window.h"
#include "websocketpp/uri.hpp"
#include "dart_callbacks.h"

namespace kraken {
namespace binding {

std::string origin = "";
std::string protocol = "";
std::string host = "";
std::string hostname = "";
std::string port = "";
std::string pathname = "";
std::string search = "";
std::string hash = "";

void updateLocation(std::string url = "") {
  websocketpp::uri uri(url);
  if (uri.get_valid()) {
    origin = uri.get_host();
    protocol = uri.get_scheme() + "://";
    hostname = uri.get_host();
    port = uri.get_port_str();
    host = hostname + ":" + port;
    search = uri.get_query();
    pathname = uri.get_resource();
  }
}

Value JSLocation::get(JSContext &context, const PropNameID &name) {
  auto propertyName = name.utf8(context);
  if (propertyName == "reload") {
    auto reloadFunc = JSA_CREATE_HOST_FUNCTION_SIMPLIFIED(
        context, std::bind(&JSLocation::reload, this, std::placeholders::_1,
                           std::placeholders::_2, std::placeholders::_3,
                           std::placeholders::_4));
    return Value(context, reloadFunc);
  } else if (propertyName == "origin") {
    return alibaba::jsa::String::createFromUtf8(context, origin);
  } else if (propertyName == "protocol") {
    return alibaba::jsa::String::createFromUtf8(context, protocol);
  } else if (propertyName == "host") {
    return alibaba::jsa::String::createFromUtf8(context, host);
  } else if (propertyName == "hostname") {
    return alibaba::jsa::String::createFromUtf8(context, hostname);
  } else if (propertyName == "port") {
    return alibaba::jsa::String::createFromUtf8(context, port);
  } else if (propertyName == "pathname") {
    return alibaba::jsa::String::createFromUtf8(context, pathname);
  } else if (propertyName == "search") {
    return alibaba::jsa::String::createFromUtf8(context, search);
  } else if (propertyName == "hash") {
    return alibaba::jsa::String::createFromUtf8(context, hash);
  }

  return Value::undefined();
}

void JSLocation::set(JSContext &, const PropNameID &name, const Value &value) {}

Value JSLocation::reload(JSContext &context, const Value &thisVal,
                         const Value *args, size_t count) {
  if (getDartFunc()->reloadApp == nullptr) {
    KRAKEN_LOG(ERROR) << "[location.reload()] dart callback not register";
    return Value::undefined();
  }
  getDartFunc()->reloadApp();
  return Value::undefined();
}

void JSLocation::bind(JSContext *context, Object &window) {
  Object &&locationObject = alibaba::jsa::Object::createFromHostObject(*context, sharedSelf());
  JSA_SET_PROPERTY(*context, window, "location", locationObject);
}

void JSLocation::unbind(JSContext *context, Object &window) {
  JSA_SET_PROPERTY(
      *context, window, "location",
      Value::undefined()
  );
}

} // namespace binding
} // namespace kraken
