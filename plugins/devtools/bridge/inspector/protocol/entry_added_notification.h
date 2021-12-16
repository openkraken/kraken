/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_ENTRY_ADDED_NOTIFICATION_H
#define KRAKEN_DEBUGGER_ENTRY_ADDED_NOTIFICATION_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/log_entry.h"

namespace kraken {
namespace debugger {
class EntryAddedNotification {
  KRAKEN_DISALLOW_COPY(EntryAddedNotification);

public:
  static std::unique_ptr<EntryAddedNotification> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~EntryAddedNotification() {}

  LogEntry *getEntry() {
    return m_entry.get();
  }

  void setEntry(std::unique_ptr<LogEntry> value) {
    m_entry = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class EntryAddedNotificationBuilder {
  public:
    enum { NoFieldsSet = 0, EntrySet = 1 << 1, AllFieldsSet = (EntrySet | 0) };

    EntryAddedNotificationBuilder<STATE | EntrySet> &setEntry(std::unique_ptr<LogEntry> value) {
      static_assert(!(STATE & EntrySet), "property entry should not be set yet");
      m_result->setEntry(std::move(value));
      return castState<EntrySet>();
    }

    std::unique_ptr<EntryAddedNotification> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class EntryAddedNotification;

    EntryAddedNotificationBuilder() : m_result(new EntryAddedNotification()) {}

    template <int STEP> EntryAddedNotificationBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<EntryAddedNotificationBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<EntryAddedNotification> m_result;
  };

  static EntryAddedNotificationBuilder<0> create() {
    return EntryAddedNotificationBuilder<0>();
  }

private:
  EntryAddedNotification() {}

  std::unique_ptr<LogEntry> m_entry;
};

} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_ENTRY_ADDED_NOTIFICATION_H
