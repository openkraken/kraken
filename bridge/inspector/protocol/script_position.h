/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_SCRIPT_POSITION_H
#define KRAKEN_DEBUGGER_SCRIPT_POSITION_H

#include "inspector/protocol/error_support.h"
#include "kraken_foundation.h"
#include <memory>
#include <string>
#include <rapidjson/document.h>

namespace kraken::debugger {
class ScriptPosition {
  KRAKEN_DISALLOW_COPY(ScriptPosition);

public:
  static std::unique_ptr<ScriptPosition> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~ScriptPosition() {}

  int getLineNumber() {
    return m_lineNumber;
  }

  void setLineNumber(int value) {
    m_lineNumber = value;
  }

  int getColumnNumber() {
    return m_columnNumber;
  }

  void setColumnNumber(int value) {
    m_columnNumber = value;
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class ScriptPositionBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      LineNumberSet = 1 << 1,
      ColumnNumberSet = 1 << 2,
      AllFieldsSet = (LineNumberSet | ColumnNumberSet | 0)
    };

    ScriptPositionBuilder<STATE | LineNumberSet> &setLineNumber(int value) {
      static_assert(!(STATE & LineNumberSet), "property lineNumber should not be set yet");
      m_result->setLineNumber(value);
      return castState<LineNumberSet>();
    }

    ScriptPositionBuilder<STATE | ColumnNumberSet> &setColumnNumber(int value) {
      static_assert(!(STATE & ColumnNumberSet), "property columnNumber should not be set yet");
      m_result->setColumnNumber(value);
      return castState<ColumnNumberSet>();
    }

    std::unique_ptr<ScriptPosition> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class ScriptPosition;

    ScriptPositionBuilder() : m_result(new ScriptPosition()) {}

    template <int STEP> ScriptPositionBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<ScriptPositionBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<ScriptPosition> m_result;
  };

  static ScriptPositionBuilder<0> create() {
    return ScriptPositionBuilder<0>();
  }

private:
  ScriptPosition() {
    m_lineNumber = 0;
    m_columnNumber = 0;
  }

  int m_lineNumber;
  int m_columnNumber;
};

} // namespace kraken

#endif // KRAKEN_DEBUGGER_SCRIPT_POSITION_H
