/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "break_location.h"

namespace kraken {
namespace debugger {
std::unique_ptr<BreakLocation> BreakLocation::fromValue(rapidjson::Value *value,
                                                        kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<BreakLocation> result(new BreakLocation());
  errors->push();

  if (value->HasMember("scriptId") && (*value)["scriptId"].IsString()) {
    result->m_scriptId = (*value)["scriptId"].GetString();
  } else {
    errors->setName("scriptId");
    errors->addError("scriptId not found");
  }

  if (value->HasMember("lineNumber") && (*value)["lineNumber"].IsInt()) {
    result->m_lineNumber = (*value)["lineNumber"].GetInt();
  } else {
    errors->setName("lineNumber");
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

  if (value->HasMember("type")) {
    errors->setName("type");
    if ((*value)["type"].IsString()) {
      result->m_type = (*value)["type"].GetString();
    } else {
      errors->addError("type should be string");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value BreakLocation::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();
  result.AddMember("scriptId", m_scriptId, allocator);
  result.AddMember("lineNumber", m_lineNumber, allocator);
  if (m_columnNumber.isJust()) result.AddMember("columnNumber", m_columnNumber.fromJust(), allocator);
  if (m_type.isJust()) result.AddMember("type", m_type.fromJust(), allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
