/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_STACKTRACE_ID_H
#define KRAKEN_DEBUGGER_STACKTRACE_ID_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "kraken_foundation.h"
#include <rapidjson/document.h>

#include <string>

namespace kraken::debugger {
class StackTraceId {
  KRAKEN_DISALLOW_COPY(StackTraceId);

public:
  static std::unique_ptr<StackTraceId> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~StackTraceId() {}

  std::string getId() {
    return m_id;
  }

  void setId(const std::string &value) {
    m_id = value;
  }

  bool hasDebuggerId() {
    return m_debuggerId.isJust();
  }

  std::string getDebuggerId(const std::string &defaultValue) {
    return m_debuggerId.isJust() ? m_debuggerId.fromJust() : defaultValue;
  }

  void setDebuggerId(const std::string &value) {
    m_debuggerId = value;
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class StackTraceIdBuilder {
  public:
    enum { NoFieldsSet = 0, IdSet = 1 << 1, AllFieldsSet = (IdSet | 0) };

    StackTraceIdBuilder<STATE | IdSet> &setId(const std::string &value) {
      static_assert(!(STATE & IdSet), "property id should not be set yet");
      m_result->setId(value);
      return castState<IdSet>();
    }

    StackTraceIdBuilder<STATE> &setDebuggerId(const std::string &value) {
      m_result->setDebuggerId(value);
      return *this;
    }

    std::unique_ptr<StackTraceId> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class StackTraceId;

    StackTraceIdBuilder() : m_result(new StackTraceId()) {}

    template <int STEP> StackTraceIdBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<StackTraceIdBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<StackTraceId> m_result;
  };

  static StackTraceIdBuilder<0> create() {
    return StackTraceIdBuilder<0>();
  }

private:
  StackTraceId() {}

  std::string m_id;
  Maybe<std::string> m_debuggerId;
};
} // namespace kraken

#endif // KRAKEN_DEBUGGER_STACKTRACE_ID_H
