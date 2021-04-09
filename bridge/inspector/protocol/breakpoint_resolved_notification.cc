/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "breakpoint_resolved_notification.h"

namespace kraken::debugger {
std::unique_ptr<BreakpointResolvedNotification>
BreakpointResolvedNotification::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {

  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<BreakpointResolvedNotification> result(new BreakpointResolvedNotification());
  errors->push();

  if (value->HasMember("breakpointId") && (*value)["breakpointId"].IsString()) {
    result->m_breakpointId = (*value)["breakpointId"].GetString();
  } else {
    errors->setName("breakpointId");
    errors->addError("breakpointId not found");
  }

  if (value->HasMember("location") && (*value)["location"].IsObject()) {
    rapidjson::Value _location = rapidjson::Value((*value)["location"].GetObject());
    result->m_location = Location::fromValue(&_location, errors);
  } else {
    errors->setName("location");
    errors->addError("location not found");
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value BreakpointResolvedNotification::toValue(rapidjson::Document::AllocatorType &allocator) const {

  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();

  result.AddMember("breakpointId", m_breakpointId, allocator);
  result.AddMember("location", m_location->toValue(allocator), allocator);
  return result;
}
} // namespace kraken
