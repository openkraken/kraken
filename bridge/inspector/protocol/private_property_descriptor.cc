/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "private_property_descriptor.h"

namespace kraken {
namespace debugger {
std::unique_ptr<PrivatePropertyDescriptor>
PrivatePropertyDescriptor::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<PrivatePropertyDescriptor> result(new PrivatePropertyDescriptor());
  errors->push();

  if (value->HasMember("name") && (*value)["name"].IsString()) {
    result->m_name = (*value)["name"].GetString();
  } else {
    errors->setName("name");
    errors->addError("name not found");
  }

  if (value->HasMember("value") && (*value)["value"].IsObject()) {
    rapidjson::Value _value = (*value)["value"].GetObject();
    result->m_value = RemoteObject::fromValue(&_value, errors);
  } else {
    errors->setName("value");
    errors->addError("value not found");
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value PrivatePropertyDescriptor::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);
  result.AddMember("name", m_name, allocator);
  result.AddMember("value", m_value->toValue(allocator), allocator);
  return result;
}
} // namespace debugger
}; // namespace kraken
