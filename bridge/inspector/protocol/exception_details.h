/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_EXCEPTION_DETAILS_H
#define KRAKEN_DEBUGGER_EXCEPTION_DETAILS_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/remote_object.h"
#include "inspector/protocol/stacktrace.h"
#include <memory>
#include <string>
#include <vector>

namespace kraken::debugger {

class ExceptionDetails {
  KRAKEN_DISALLOW_COPY(ExceptionDetails);

public:
  static std::unique_ptr<ExceptionDetails> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~ExceptionDetails() {}

  int getExceptionId() {
    return m_exceptionId;
  }

  void setExceptionId(int value) {
    m_exceptionId = value;
  }

  std::string getText() {
    return m_text;
  }

  void setText(const std::string &value) {
    m_text = value;
  }

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

  bool hasScriptId() {
    return m_scriptId.isJust();
  }

  std::string getScriptId(const std::string &defaultValue) {
    return m_scriptId.isJust() ? m_scriptId.fromJust() : defaultValue;
  }

  void setScriptId(const std::string &value) {
    m_scriptId = value;
  }

  bool hasUrl() {
    return m_url.isJust();
  }

  std::string getUrl(const std::string &defaultValue) {
    return m_url.isJust() ? m_url.fromJust() : defaultValue;
  }

  void setUrl(const std::string &value) {
    m_url = value;
  }

  bool hasStackTrace() {
    return m_stackTrace.isJust();
  }

  StackTrace *getStackTrace(StackTrace *defaultValue) {
    return m_stackTrace.isJust() ? m_stackTrace.fromJust() : defaultValue;
  }

  void setStackTrace(std::unique_ptr<StackTrace> value) {
    m_stackTrace = std::move(value);
  }

  bool hasException() {
    return m_exception.isJust();
  }

  RemoteObject *getException(RemoteObject *defaultValue) {
    return m_exception.isJust() ? m_exception.fromJust() : defaultValue;
  }

  void setException(std::unique_ptr<RemoteObject> value) {
    m_exception = std::move(value);
  }

  bool hasExecutionContextId() {
    return m_executionContextId.isJust();
  }

  int getExecutionContextId(int defaultValue) {
    return m_executionContextId.isJust() ? m_executionContextId.fromJust() : defaultValue;
  }

  void setExecutionContextId(int value) {
    m_executionContextId = value;
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class ExceptionDetailsBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      ExceptionIdSet = 1 << 1,
      TextSet = 1 << 2,
      LineNumberSet = 1 << 3,
      ColumnNumberSet = 1 << 4,
      AllFieldsSet = (ExceptionIdSet | TextSet | LineNumberSet | ColumnNumberSet | 0)
    };

    ExceptionDetailsBuilder<STATE | ExceptionIdSet> &setExceptionId(int value) {
      static_assert(!(STATE & ExceptionIdSet), "property exceptionId should not be set yet");
      m_result->setExceptionId(value);
      return castState<ExceptionIdSet>();
    }

    ExceptionDetailsBuilder<STATE | TextSet> &setText(const std::string &value) {
      static_assert(!(STATE & TextSet), "property text should not be set yet");
      m_result->setText(value);
      return castState<TextSet>();
    }

    ExceptionDetailsBuilder<STATE | LineNumberSet> &setLineNumber(int value) {
      static_assert(!(STATE & LineNumberSet), "property lineNumber should not be set yet");
      m_result->setLineNumber(value);
      return castState<LineNumberSet>();
    }

    ExceptionDetailsBuilder<STATE | ColumnNumberSet> &setColumnNumber(int value) {
      static_assert(!(STATE & ColumnNumberSet), "property columnNumber should not be set yet");
      m_result->setColumnNumber(value);
      return castState<ColumnNumberSet>();
    }

    ExceptionDetailsBuilder<STATE> &setScriptId(const std::string &value) {
      m_result->setScriptId(value);
      return *this;
    }

    ExceptionDetailsBuilder<STATE> &setUrl(const std::string &value) {
      m_result->setUrl(value);
      return *this;
    }

    ExceptionDetailsBuilder<STATE> &setStackTrace(std::unique_ptr<StackTrace> value) {
      m_result->setStackTrace(std::move(value));
      return *this;
    }

    ExceptionDetailsBuilder<STATE> &setException(std::unique_ptr<RemoteObject> value) {
      m_result->setException(std::move(value));
      return *this;
    }

    ExceptionDetailsBuilder<STATE> &setExecutionContextId(int value) {
      m_result->setExecutionContextId(value);
      return *this;
    }

    std::unique_ptr<ExceptionDetails> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class ExceptionDetails;

    ExceptionDetailsBuilder() : m_result(new ExceptionDetails()) {}

    template <int STEP> ExceptionDetailsBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<ExceptionDetailsBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<ExceptionDetails> m_result;
  };

  static ExceptionDetailsBuilder<0> create() {
    return ExceptionDetailsBuilder<0>();
  }

private:
  ExceptionDetails() {
    m_exceptionId = 0;
    m_lineNumber = 0;
    m_columnNumber = 0;
  }

  int m_exceptionId;
  std::string m_text;
  int m_lineNumber;
  int m_columnNumber;
  Maybe<std::string> m_scriptId;
  Maybe<std::string> m_url;
  Maybe<StackTrace> m_stackTrace;
  Maybe<RemoteObject> m_exception;
  Maybe<int> m_executionContextId;
};

} // namespace kraken

#endif // KRAKEN_DEBUGGER_EXCEPTION_DETAILS_H
