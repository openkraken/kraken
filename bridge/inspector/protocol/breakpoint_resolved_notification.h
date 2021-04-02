/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_RESOLVED_NOTIFICATION_H
#define KRAKEN_DEBUGGER_RESOLVED_NOTIFICATION_H

#include "kraken_foundation.h"
#include "inspector/protocol/error_support.h"
#include "inspector/protocol/location.h"
#include <rapidjson/document.h>
#include <memory>
#include <string>

namespace kraken::debugger {

class BreakpointResolvedNotification {
  KRAKEN_DISALLOW_COPY(BreakpointResolvedNotification);

public:
  static std::unique_ptr<BreakpointResolvedNotification> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~BreakpointResolvedNotification() {}

  std::string getBreakpointId() {
    return m_breakpointId;
  }

  void setBreakpointId(const std::string &value) {
    m_breakpointId = value;
  }

  Location *getLocation() {
    return m_location.get();
  }

  void setLocation(std::unique_ptr<Location> value) {
    m_location = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class BreakpointResolvedNotificationBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      BreakpointIdSet = 1 << 1,
      LocationSet = 1 << 2,
      AllFieldsSet = (BreakpointIdSet | LocationSet | 0)
    };

    BreakpointResolvedNotificationBuilder<STATE | BreakpointIdSet> &setBreakpointId(const std::string &value) {
      static_assert(!(STATE & BreakpointIdSet), "property breakpointId should not be set yet");
      m_result->setBreakpointId(value);
      return castState<BreakpointIdSet>();
    }

    BreakpointResolvedNotificationBuilder<STATE | LocationSet> &setLocation(std::unique_ptr<Location> value) {
      static_assert(!(STATE & LocationSet), "property location should not be set yet");
      m_result->setLocation(std::move(value));
      return castState<LocationSet>();
    }

    std::unique_ptr<BreakpointResolvedNotification> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class BreakpointResolvedNotification;

    BreakpointResolvedNotificationBuilder() : m_result(new BreakpointResolvedNotification()) {}

    template <int STEP> BreakpointResolvedNotificationBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<BreakpointResolvedNotificationBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<BreakpointResolvedNotification> m_result;
  };

  static BreakpointResolvedNotificationBuilder<0> create() {
    return BreakpointResolvedNotificationBuilder<0>();
  }

private:
  BreakpointResolvedNotification() {}

  std::string m_breakpointId;
  std::unique_ptr<Location> m_location;
};

} // namespace kraken

#endif // KRAKEN_DEBUGGER_RESOLVED_NOTIFICATION_H
