/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "call_argument.h"

namespace kraken {
namespace debugger {
std::unique_ptr<CallArgument> CallArgument::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<CallArgument> result(new CallArgument());
  errors->push();

  if (value->HasMember("value")) {
    result->m_value = std::make_unique<rapidjson::Value>((*value)["value"], result->m_holder.GetAllocator());
  }

  if (value->HasMember("unserializableValue")) {
    errors->setName("unserializableValue");
    if ((*value)["unserializableValue"].IsString()) {
      result->m_unserializableValue = (*value)["unserializableValue"].GetString();
    } else {
      errors->addError("unserializableValue should be string");
    }
  }

  if (value->HasMember("objectId")) {
    errors->setName("objectId");
    if ((*value)["objectId"].IsString()) {
      result->m_objectId = (*value)["objectId"].GetString();
    } else {
      errors->addError("objectId should be string");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value CallArgument::toValue(rapidjson::Document::AllocatorType &allocator) const {

  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();

  if (m_value.isJust()) result.AddMember("value", *m_value.fromJust(), allocator);
  if (m_unserializableValue.isJust())
    result.AddMember("unserializableValue", m_unserializableValue.fromJust(), allocator);
  if (m_objectId.isJust()) result.AddMember("objectId", m_objectId.fromJust(), allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
