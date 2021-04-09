/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "stacktrace_id.h"

namespace kraken::debugger {
std::unique_ptr<StackTraceId> StackTraceId::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<StackTraceId> result(new StackTraceId());

  errors->push();

  if (value->HasMember("id") && (*value)["id"].IsString()) {
    result->m_id = (*value)["id"].GetString();
  } else {
    errors->setName("id");
    errors->addError("id not found");
  }

  if (value->HasMember("debuggerId")) {
    errors->setName("debuggerId");
    if ((*value)["debuggerId"].IsString()) {
      result->m_debuggerId = (*value)["debuggerId"].GetString();
    } else {
      errors->addError("debuggerId should be string");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value StackTraceId::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.AddMember("id", m_id, allocator);
  if (m_debuggerId.isJust()) {
    result.AddMember("debuggerId", m_debuggerId.fromJust(), allocator);
  }
  return result;
}
} // namespace kraken::debugger
