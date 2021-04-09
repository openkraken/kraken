/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/protocol/execution_context_description.h"

namespace kraken::debugger {

std::unique_ptr<ExecutionContextDescription>
ExecutionContextDescription::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<ExecutionContextDescription> result(new ExecutionContextDescription());
  errors->push();

  if (value->HasMember("id") && (*value)["id"].IsInt()) {
    result->m_id = (*value)["id"].GetInt();
  } else {
    errors->setName("id");
    errors->addError("id not found");
  }

  if (value->HasMember("origin") && (*value)["origin"].IsString()) {
    result->m_origin = (*value)["origin"].GetString();
  } else {
    errors->setName("origin");
    errors->addError("origin not found");
  }

  if (value->HasMember("name") && (*value)["name"].IsString()) {
    result->m_name = (*value)["name"].GetString();
  } else {
    errors->setName("name");
    errors->addError("name not found");
  }

  if (value->HasMember("auxData")) {
    result->m_auxData = std::make_unique<rapidjson::Value>((*value)["auxData"], result->m_doc.GetAllocator());
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value ExecutionContextDescription::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);
  result.AddMember("id", m_id, allocator);
  result.AddMember("origin", m_origin, allocator);
  result.AddMember("name", m_name, allocator);
  if (m_auxData.isJust()) result.AddMember("auxData", *m_auxData.fromJust(), allocator);
  return result;
}
} // namespace kraken::debugger
