/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "internal_property_descriptor.h"

namespace kraken {
namespace debugger {
std::unique_ptr<InternalPropertyDescriptor>
InternalPropertyDescriptor::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<InternalPropertyDescriptor> result(new InternalPropertyDescriptor());
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

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value InternalPropertyDescriptor::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);

  result.AddMember("name", m_name, allocator);
  if (m_value.isJust()) result.AddMember("value", m_value.fromJust()->toValue(allocator), allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
