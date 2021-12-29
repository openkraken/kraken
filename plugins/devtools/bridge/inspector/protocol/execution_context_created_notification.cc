/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "execution_context_created_notification.h"

namespace kraken {
namespace debugger {
std::unique_ptr<ExecutionContextCreatedNotification>
ExecutionContextCreatedNotification::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<ExecutionContextCreatedNotification> result(new ExecutionContextCreatedNotification());
  errors->push();

  if (value->HasMember("context") && (*value)["context"].IsObject()) {
    rapidjson::Value val = (*value)["context"].GetObject();
    result->m_context = ExecutionContextDescription::fromValue(&val, errors);
  } else {
    errors->setName("context");
    errors->addError("context not found");
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value ExecutionContextCreatedNotification::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);
  result.AddMember("context", m_context->toValue(allocator), allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
