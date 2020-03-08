/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include "dart_methods.h"
#include "websocketpp/uri.hpp"

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

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
    auto reloadFunc =
      JSA_CREATE_HOST_FUNCTION(context, "reload", 4,
                               std::bind(&JSLocation::reload, this, std::placeholders::_1, std::placeholders::_2,
                                         std::placeholders::_3, std::placeholders::_4));
    return Value(context, reloadFunc);
  } else if (propertyName == "origin") {
    return String::createFromUtf8(context, origin);
  } else if (propertyName == "protocol") {
    return String::createFromUtf8(context, protocol);
  } else if (propertyName == "host") {
    return String::createFromUtf8(context, host);
  } else if (propertyName == "hostname") {
    return String::createFromUtf8(context, hostname);
  } else if (propertyName == "port") {
    return String::createFromUtf8(context, port);
  } else if (propertyName == "pathname") {
    return String::createFromUtf8(context, pathname);
  } else if (propertyName == "search") {
    return String::createFromUtf8(context, search);
  } else if (propertyName == "hash") {
    return String::createFromUtf8(context, hash);
  }

  return Value::undefined();
}

void JSLocation::set(JSContext &, const PropNameID &name, const Value &value) {}

Value JSLocation::reload(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (getDartMethod()->reloadApp == nullptr) {
    throw JSError(context, "Failed to execute 'reload': dart method (reloadApp) is not registered.");
  }
  getDartMethod()->reloadApp();
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
  names.emplace_back(PropNameID::forAscii(context, "origin"));
  names.emplace_back(PropNameID::forAscii(context, "protocol"));
  names.emplace_back(PropNameID::forAscii(context, "host"));
  names.emplace_back(PropNameID::forAscii(context, "hostname"));
  names.emplace_back(PropNameID::forAscii(context, "port"));
  names.emplace_back(PropNameID::forAscii(context, "pathname"));
  names.emplace_back(PropNameID::forAscii(context, "search"));
  names.emplace_back(PropNameID::forAscii(context, "hash"));
  names.emplace_back(PropNameID::forAscii(context, "reload"));
  return names;
}

} // namespace binding
} // namespace kraken
