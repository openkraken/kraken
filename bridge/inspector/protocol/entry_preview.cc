/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "entry_preview.h"
#include "inspector/protocol/object_preview.h"
#include "remote_object.h"

namespace kraken {
namespace debugger {
std::unique_ptr<EntryPreview> EntryPreview::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<EntryPreview> result(new EntryPreview());
  errors->push();

  if (value->HasMember("key")) {
    errors->setName("key");
    if ((*value)["key"].IsObject()) {
      rapidjson::Value _key = (*value)["key"].GetObject();
      result->m_key = ObjectPreview::fromValue(&_key, errors);
    } else {
      errors->addError("key should be object");
    }
  }

  if (value->HasMember("value") && (*value)["value"].IsObject()) {
    rapidjson::Value _value = (*value)["value"].GetObject();
    result->m_value = ObjectPreview::fromValue(&_value, errors);
  } else {
    errors->setName("value");
    errors->addError("value not found");
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value EntryPreview::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);
  if (m_key.isJust()) result.AddMember("key", m_key.fromJust()->toValue(allocator), allocator);
  result.AddMember("value", m_value.get()->toValue(allocator), allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
