/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_BREAK_LOCATION_H
#define KRAKEN_DEBUGGER_BREAK_LOCATION_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "kraken_foundation.h"
#include "rapidjson/document.h"
#include <memory>
#include <string>
#include <vector>

namespace kraken::debugger {
class BreakLocation {
  KRAKEN_DISALLOW_COPY(BreakLocation);

public:
  static std::unique_ptr<BreakLocation> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~BreakLocation() {}

  std::string getScriptId() {
    return m_scriptId;
  }

  void setScriptId(const std::string &value) {
    m_scriptId = value;
  }

  int getLineNumber() {
    return m_lineNumber;
  }

  void setLineNumber(int value) {
    m_lineNumber = value;
  }

  bool hasColumnNumber() {
    return m_columnNumber.isJust();
  }

  int getColumnNumber(int defaultValue) {
    return m_columnNumber.isJust() ? m_columnNumber.fromJust() : defaultValue;
  }

  void setColumnNumber(int value) {
    m_columnNumber = value;
  }

  struct TypeEnum {
    static const char *DebuggerStatement;
    static const char *Call;
    static const char *Return;
  }; // TypeEnum

  bool hasType() {
    return m_type.isJust();
  }

  std::string getType(const std::string &defaultValue) {
    return m_type.isJust() ? m_type.fromJust() : defaultValue;
  }

  void setType(const std::string &value) {
    m_type = value;
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class BreakLocationBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      ScriptIdSet = 1 << 1,
      LineNumberSet = 1 << 2,
      AllFieldsSet = (ScriptIdSet | LineNumberSet | 0)
    };

    BreakLocationBuilder<STATE | ScriptIdSet> &setScriptId(const std::string &value) {
      static_assert(!(STATE & ScriptIdSet), "property scriptId should not be set yet");
      m_result->setScriptId(value);
      return castState<ScriptIdSet>();
    }

    BreakLocationBuilder<STATE | LineNumberSet> &setLineNumber(int value) {
      static_assert(!(STATE & LineNumberSet), "property lineNumber should not be set yet");
      m_result->setLineNumber(value);
      return castState<LineNumberSet>();
    }

    BreakLocationBuilder<STATE> &setColumnNumber(int value) {
      m_result->setColumnNumber(value);
      return *this;
    }

    BreakLocationBuilder<STATE> &setType(const std::string &value) {
      m_result->setType(value);
      return *this;
    }

    std::unique_ptr<BreakLocation> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class BreakLocation;

    BreakLocationBuilder() : m_result(new BreakLocation()) {}

    template <int STEP> BreakLocationBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<BreakLocationBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<BreakLocation> m_result;
  };

  static BreakLocationBuilder<0> create() {
    return BreakLocationBuilder<0>();
  }

private:
  BreakLocation() {
    m_lineNumber = 0;
  }

  std::string m_scriptId;
  int m_lineNumber;
  Maybe<int> m_columnNumber;
  Maybe<std::string> m_type;
};
} // namespace kraken

#endif // KRAKEN_DEBUGGER_BREAK_LOCATION_H
