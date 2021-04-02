/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_PAUSED_NOTIFICATION_H
#define KRAKEN_DEBUGGER_PAUSED_NOTIFICATION_H

#include "inspector/protocol/call_frame.h"
#include "inspector/protocol/error_support.h"
#include "inspector/protocol/stacktrace.h"
#include "inspector/protocol/stacktrace_id.h"
#include <memory>
#include <string>
#include <vector>

namespace kraken {
namespace debugger {
class PausedNotification {
  KRAKEN_DISALLOW_COPY(PausedNotification);

public:
  static std::unique_ptr<PausedNotification> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~PausedNotification() {}

  std::vector<std::unique_ptr<CallFrame>> *getCallFrames() {
    return m_callFrames.get();
  }
  void setCallFrames(std::unique_ptr<std::vector<std::unique_ptr<CallFrame>>> value) {
    m_callFrames = std::move(value);
  }

  struct ReasonEnum {
    static const char *XHR;
    static const char *DOM;
    static const char *EventListener;
    static const char *Exception;
    static const char *Assert;
    static const char *DebugCommand;
    static const char *PromiseRejection;
    static const char *OOM;
    static const char *Other;
    static const char *Ambiguous;
  }; // ReasonEnum

  std::string getReason() {
    return m_reason;
  }
  void setReason(const std::string &value) {
    m_reason = value;
  }

  bool hasData() {
    return m_data.isJust();
  }
  rapidjson::Value *getData(rapidjson::Value *defaultValue) {
    return m_data.isJust() ? m_data.fromJust() : defaultValue;
  }
  void setData(std::unique_ptr<rapidjson::Value> value) {
    m_data = std::move(value);
  }

  bool hasHitBreakpoints() {
    return m_hitBreakpoints.isJust();
  }
  std::vector<std::string> *getHitBreakpoints(std::vector<std::string> *defaultValue) {
    return m_hitBreakpoints.isJust() ? m_hitBreakpoints.fromJust() : defaultValue;
  }
  void setHitBreakpoints(std::unique_ptr<std::vector<std::string>> value) {
    m_hitBreakpoints = std::move(value);
  }

  bool hasAsyncStackTrace() {
    return m_asyncStackTrace.isJust();
  }
  StackTrace *getAsyncStackTrace(StackTrace *defaultValue) {
    return m_asyncStackTrace.isJust() ? m_asyncStackTrace.fromJust() : defaultValue;
  }
  void setAsyncStackTrace(std::unique_ptr<StackTrace> value) {
    m_asyncStackTrace = std::move(value);
  }

  bool hasAsyncStackTraceId() {
    return m_asyncStackTraceId.isJust();
  }
  StackTraceId *getAsyncStackTraceId(StackTraceId *defaultValue) {
    return m_asyncStackTraceId.isJust() ? m_asyncStackTraceId.fromJust() : defaultValue;
  }
  void setAsyncStackTraceId(std::unique_ptr<StackTraceId> value) {
    m_asyncStackTraceId = std::move(value);
  }

  bool hasAsyncCallStackTraceId() {
    return m_asyncCallStackTraceId.isJust();
  }
  StackTraceId *getAsyncCallStackTraceId(StackTraceId *defaultValue) {
    return m_asyncCallStackTraceId.isJust() ? m_asyncCallStackTraceId.fromJust() : defaultValue;
  }
  void setAsyncCallStackTraceId(std::unique_ptr<StackTraceId> value) {
    m_asyncCallStackTraceId = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class PausedNotificationBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      CallFramesSet = 1 << 1,
      ReasonSet = 1 << 2,
      AllFieldsSet = (CallFramesSet | ReasonSet | 0)
    };

    PausedNotificationBuilder<STATE | CallFramesSet> &
    setCallFrames(std::unique_ptr<std::vector<std::unique_ptr<CallFrame>>> value) {
      static_assert(!(STATE & CallFramesSet), "property callFrames should not be set yet");
      m_result->setCallFrames(std::move(value));
      return castState<CallFramesSet>();
    }

    PausedNotificationBuilder<STATE | ReasonSet> &setReason(const std::string &value) {
      static_assert(!(STATE & ReasonSet), "property reason should not be set yet");
      m_result->setReason(value);
      return castState<ReasonSet>();
    }

    PausedNotificationBuilder<STATE> &setData(std::unique_ptr<rapidjson::Value> value) {
      m_result->setData(std::move(value));
      return *this;
    }

    PausedNotificationBuilder<STATE> &setHitBreakpoints(std::unique_ptr<std::vector<std::string>> value) {
      m_result->setHitBreakpoints(std::move(value));
      return *this;
    }

    PausedNotificationBuilder<STATE> &setAsyncStackTrace(std::unique_ptr<StackTrace> value) {
      m_result->setAsyncStackTrace(std::move(value));
      return *this;
    }

    PausedNotificationBuilder<STATE> &setAsyncStackTraceId(std::unique_ptr<StackTraceId> value) {
      m_result->setAsyncStackTraceId(std::move(value));
      return *this;
    }

    PausedNotificationBuilder<STATE> &setAsyncCallStackTraceId(std::unique_ptr<StackTraceId> value) {
      m_result->setAsyncCallStackTraceId(std::move(value));
      return *this;
    }

    std::unique_ptr<PausedNotification> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class PausedNotification;
    PausedNotificationBuilder() : m_result(new PausedNotification()) {}

    template <int STEP> PausedNotificationBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<PausedNotificationBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<PausedNotification> m_result;
  };

  static PausedNotificationBuilder<0> create() {
    return PausedNotificationBuilder<0>();
  }

private:
  PausedNotification() {}

  std::unique_ptr<std::vector<std::unique_ptr<CallFrame>>> m_callFrames;
  std::string m_reason;
  Maybe<rapidjson::Value> m_data;
  Maybe<std::vector<std::string>> m_hitBreakpoints;
  Maybe<StackTrace> m_asyncStackTrace;
  Maybe<StackTraceId> m_asyncStackTraceId;
  Maybe<StackTraceId> m_asyncCallStackTraceId;
  rapidjson::Document m_holder;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_PAUSED_NOTIFICATION_H
