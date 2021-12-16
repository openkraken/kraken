/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"

namespace kraken::debugger {
std::unique_ptr<Location> Location::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {

  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<Location> result(new Location());
  errors->push();
  errors->setName("scriptId");
  if (value->HasMember("scriptId") && (*value)["scriptId"].IsString()) {
    result->m_scriptId = (*value)["scriptId"].GetString();
  } else {
    errors->addError("scriptId not found");
  }
  errors->setName("lineNumber");
  if (value->HasMember("lineNumber") && (*value)["lineNumber"].IsInt()) {
    result->m_lineNumber = (*value)["lineNumber"].GetInt();
  } else {
    errors->addError("lineNumber not found");
  }

  if (value->HasMember("columnNumber")) {
    errors->setName("columnNumber");
    if ((*value)["columnNumber"].IsInt()) {
      result->m_columnNumber = (*value)["columnNumber"].GetInt();
    } else {
      errors->addError("columnNumber should be int");
    }
  }
  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value Location::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value value = rapidjson::Value(rapidjson::kObjectType);
  value.SetObject();
  value.AddMember("scriptId", m_scriptId, allocator);
  value.AddMember("lineNumber", m_lineNumber, allocator);
  if (m_columnNumber.isJust()) {
    value.AddMember("columnNumber", m_columnNumber.fromJust(), allocator);
  }
  return value;
}
} // namespace kraken
