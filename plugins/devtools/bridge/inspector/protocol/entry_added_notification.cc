/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "entry_added_notification.h"

namespace kraken {
namespace debugger {
std::unique_ptr<EntryAddedNotification> EntryAddedNotification::fromValue(rapidjson::Value *value,
                                                                          kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<EntryAddedNotification> result(new EntryAddedNotification());
  errors->push();

  if (value->HasMember("entry") && (*value)["entry"].IsObject()) {
    rapidjson::Value _entry = (*value)["entry"].GetObject();
    result->m_entry = LogEntry::fromValue(&_entry, errors);
  } else {
    errors->setName("entry");
    errors->addError("entry not found");
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value EntryAddedNotification::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);
  result.AddMember("entry", m_entry.get()->toValue(allocator), allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
