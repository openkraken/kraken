/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_EXECUTION_CONTEXT_CREATED_NOTIFICATION_H
#define KRAKEN_DEBUGGER_EXECUTION_CONTEXT_CREATED_NOTIFICATION_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/execution_context_description.h"
#include "inspector/protocol/maybe.h"
#include <memory>
#include <string>

namespace kraken {
namespace debugger {
class ExecutionContextCreatedNotification {
  KRAKEN_DISALLOW_COPY(ExecutionContextCreatedNotification);

public:
  static std::unique_ptr<ExecutionContextCreatedNotification> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~ExecutionContextCreatedNotification() {}

  ExecutionContextDescription *getContext() {
    return m_context.get();
  }

  void setContext(std::unique_ptr<ExecutionContextDescription> value) {
    m_context = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class ExecutionContextCreatedNotificationBuilder {
  public:
    enum { NoFieldsSet = 0, ContextSet = 1 << 1, AllFieldsSet = (ContextSet | 0) };

    ExecutionContextCreatedNotificationBuilder<STATE | ContextSet> &
    setContext(std::unique_ptr<ExecutionContextDescription> value) {
      static_assert(!(STATE & ContextSet), "property context should not be set yet");
      m_result->setContext(std::move(value));
      return castState<ContextSet>();
    }

    std::unique_ptr<ExecutionContextCreatedNotification> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class ExecutionContextCreatedNotification;

    ExecutionContextCreatedNotificationBuilder() : m_result(new ExecutionContextCreatedNotification()) {}

    template <int STEP> ExecutionContextCreatedNotificationBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<ExecutionContextCreatedNotificationBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<ExecutionContextCreatedNotification> m_result;
  };

  static ExecutionContextCreatedNotificationBuilder<0> create() {
    return ExecutionContextCreatedNotificationBuilder<0>();
  }

private:
  ExecutionContextCreatedNotification() {}

  std::unique_ptr<ExecutionContextDescription> m_context;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_EXECUTION_CONTEXT_CREATED_NOTIFICATION_H
