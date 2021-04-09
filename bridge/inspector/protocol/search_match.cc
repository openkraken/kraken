/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "search_match.h"

namespace kraken {
namespace debugger {
std::unique_ptr<SearchMatch> SearchMatch::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<SearchMatch> result(new SearchMatch());
  errors->push();

  if (value->HasMember("lineNumber") && (*value)["lineNumber"].IsDouble()) {
    result->m_lineNumber = (*value)["lineNumber"].GetDouble();
  } else {
    errors->setName("lineNumber");
    errors->addError("lineNumber not found");
  }

  if (value->HasMember("lineContent") && (*value)["lineContent"].IsString()) {
    result->m_lineContent = (*value)["lineContent"].GetString();
  } else {
    errors->setName("lineContent");
    errors->addError("lineContent not found");
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value SearchMatch::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();

  result.AddMember("lineNumber", m_lineNumber, allocator);
  result.AddMember("lineContent", m_lineContent, allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
