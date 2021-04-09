/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "property_descriptor.h"

namespace kraken {
namespace debugger {
std::unique_ptr<PropertyDescriptor> PropertyDescriptor::fromValue(rapidjson::Value *value,
                                                                  kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<PropertyDescriptor> result(new PropertyDescriptor());
  errors->push();

  if (value->HasMember("name") && (*value)["name"].IsString()) {
    result->m_name = (*value)["name"].GetString();
  } else {
    errors->setName("name");
    errors->addError("name not found");
  }

  if (value->HasMember("value")) {
    errors->setName("value");
    if ((*value)["value"].IsObject()) {
      rapidjson::Value _value = (*value)["value"].GetObject();
      result->m_value = RemoteObject::fromValue(&_value, errors);
    } else {
      errors->addError("value should be object");
    }
  }

  if (value->HasMember("writable")) {
    errors->setName("writable");
    if ((*value)["writable"].IsBool()) {
      result->m_writable = (*value)["writable"].GetBool();
    } else {
      errors->addError("writable should be bool");
    }
  }

  if (value->HasMember("get")) {
    errors->setName("get");
    if ((*value)["get"].IsObject()) {
      rapidjson::Value _get = (*value)["get"].GetObject();
      result->m_get = RemoteObject::fromValue(&_get, errors);
    } else {
      errors->addError("get should be object");
    }
  }

  if (value->HasMember("set")) {
    errors->setName("set");
    if ((*value)["set"].IsObject()) {
      rapidjson::Value _set = (*value)["set"].GetObject();
      result->m_set = RemoteObject::fromValue(&_set, errors);
    } else {
      errors->addError("set should be object");
    }
  }

  if (value->HasMember("configurable") && (*value)["configurable"].IsBool()) {
    result->m_configurable = (*value)["configurable"].GetBool();
  } else {
    errors->setName("configurable");
    errors->addError("configurable not found");
  }

  if (value->HasMember("enumerable") && (*value)["enumerable"].IsBool()) {
    result->m_enumerable = (*value)["enumerable"].GetBool();
  } else {
    errors->setName("enumerable");
    errors->addError("enumerable not found");
  }

  if (value->HasMember("wasThrown")) {
    errors->setName("wasThrown");
    if ((*value)["wasThrown"].IsBool()) {
      result->m_wasThrown = (*value)["wasThrown"].GetBool();
    } else {
      errors->addError("wasThrown should be bool");
    }
  }

  if (value->HasMember("isOwn")) {
    errors->setName("isOwn");
    if ((*value)["isOwn"].IsBool()) {
      result->m_isOwn = (*value)["isOwn"].GetBool();
    } else {
      errors->addError("isOwn should be bool");
    }
  }

  if (value->HasMember("symbol")) {
    errors->setName("symbol");
    if ((*value)["symbol"].IsObject()) {
      rapidjson::Value _symbol = (*value)["symbol"].GetObject();
      result->m_symbol = RemoteObject::fromValue(&_symbol, errors);
    } else {
      errors->addError("symbol should be object");
    }
  }
  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value PropertyDescriptor::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);
  result.AddMember("name", m_name, allocator);
  if (m_value.isJust()) result.AddMember("value", m_value.fromJust()->toValue(allocator), allocator);
  if (m_writable.isJust()) result.AddMember("writable", m_writable.fromJust(), allocator);
  if (m_get.isJust()) result.AddMember("get", m_get.fromJust()->toValue(allocator), allocator);
  if (m_set.isJust()) result.AddMember("set", m_set.fromJust()->toValue(allocator), allocator);
  result.AddMember("configurable", m_configurable, allocator);
  result.AddMember("enumerable", m_enumerable, allocator);
  if (m_wasThrown.isJust()) result.AddMember("wasThrown", m_wasThrown.fromJust(), allocator);
  if (m_isOwn.isJust()) result.AddMember("isOwn", m_isOwn.fromJust(), allocator);
  if (m_symbol.isJust()) result.AddMember("symbol", m_symbol.fromJust()->toValue(allocator), allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
