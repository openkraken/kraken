/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_STACKTRACE_H
#define KRAKEN_DEBUGGER_STACKTRACE_H

#include "inspector/protocol/call_frame.h"
#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "inspector/protocol/stacktrace_id.h"
#include "kraken_foundation.h"
#include <vector>

namespace kraken {
namespace debugger {
class StackTrace {
  KRAKEN_DISALLOW_COPY(StackTrace);

public:
  static std::unique_ptr<StackTrace> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~StackTrace() {}

  bool hasDescription() {
    return m_description.isJust();
  }

  std::string getDescription(const std::string &defaultValue) {
    return m_description.isJust() ? m_description.fromJust() : defaultValue;
  }

  void setDescription(const std::string &value) {
    m_description = value;
  }

  std::vector<std::unique_ptr<CallFrame>> *getCallFrames() {
    return m_callFrames.get();
  }

  void setCallFrames(std::unique_ptr<std::vector<std::unique_ptr<CallFrame>>> value) {
    m_callFrames = std::move(value);
  }

  bool hasParent() {
    return m_parent.isJust();
  }

  StackTrace *getParent(StackTrace *defaultValue) {
    return m_parent.isJust() ? m_parent.fromJust() : defaultValue;
  }

  void setParent(std::unique_ptr<StackTrace> value) {
    m_parent = std::move(value);
  }

  bool hasParentId() {
    return m_parentId.isJust();
  }

  StackTraceId *getParentId(StackTraceId *defaultValue) {
    return m_parentId.isJust() ? m_parentId.fromJust() : defaultValue;
  }

  void setParentId(std::unique_ptr<StackTraceId> value) {
    m_parentId = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class StackTraceBuilder {
  public:
    enum { NoFieldsSet = 0, CallFramesSet = 1 << 1, AllFieldsSet = (CallFramesSet | 0) };

    StackTraceBuilder<STATE> &setDescription(const std::string &value) {
      m_result->setDescription(value);
      return *this;
    }

    StackTraceBuilder<STATE | CallFramesSet> &
    setCallFrames(std::unique_ptr<std::vector<std::unique_ptr<CallFrame>>> value) {
      static_assert(!(STATE & CallFramesSet), "property callFrames should not be set yet");
      m_result->setCallFrames(std::move(value));
      return castState<CallFramesSet>();
    }

    StackTraceBuilder<STATE> &setParent(std::unique_ptr<StackTrace> value) {
      m_result->setParent(std::move(value));
      return *this;
    }

    StackTraceBuilder<STATE> &setParentId(std::unique_ptr<StackTraceId> value) {
      m_result->setParentId(std::move(value));
      return *this;
    }

    std::unique_ptr<StackTrace> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class StackTrace;

    StackTraceBuilder() : m_result(new StackTrace()) {}

    template <int STEP> StackTraceBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<StackTraceBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<StackTrace> m_result;
  };

  static StackTraceBuilder<0> create() {
    return StackTraceBuilder<0>();
  }

private:
  StackTrace() {}

  Maybe<std::string> m_description;
  std::unique_ptr<std::vector<std::unique_ptr<CallFrame>>> m_callFrames;
  Maybe<StackTrace> m_parent;
  Maybe<StackTraceId> m_parentId;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_STACKTRACE_H
