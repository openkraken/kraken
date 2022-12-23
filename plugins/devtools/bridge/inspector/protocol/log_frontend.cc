/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

#include "log_frontend.h"
#include "inspector/protocol/entry_added_notification.h"

namespace kraken {
namespace debugger {

void LogFrontend::entryAdded(std::unique_ptr<kraken::debugger::LogEntry> entry) {
  if (!m_frontendChannel) return;
  std::unique_ptr<EntryAddedNotification> messageData =
    EntryAddedNotification::create().setEntry(std::move(entry)).build();
  rapidjson::Document doc;
  m_frontendChannel->sendProtocolNotification({"Log.entryAdded", messageData->toValue(doc.GetAllocator())});
}
} // namespace debugger
} // namespace kraken
