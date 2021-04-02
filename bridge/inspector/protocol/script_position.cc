/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_position.h"

namespace kraken {
namespace debugger {
std::unique_ptr<ScriptPosition> ScriptPosition::fromValue(rapidjson::Value *value,
                                                          kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<ScriptPosition> result(new ScriptPosition());

  errors->push();
  errors->setName("lineNumber");
  if (value->HasMember("lineNumber") && (*value)["lineNumber"].IsInt()) {
    result->m_lineNumber = (*value)["lineNumber"].GetInt();
  } else {
    errors->addError("lineNumber not found");
  }

  errors->setName("columnNumber");
  if (value->HasMember("columnNumber") && (*value)["columnNumber"].IsInt()) {
    result->m_columnNumber = (*value)["columnNumber"].GetInt();
  } else {
    errors->addError("columnNumber not found");
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value ScriptPosition::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.AddMember("lineNumber", m_lineNumber, allocator);
  result.AddMember("columnNumber", m_columnNumber, allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
