/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_LOG_ENTRY_H
#define KRAKEN_DEBUGGER_LOG_ENTRY_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "inspector/protocol/stacktrace.h"
#include "kraken_foundation.h"

#include <string>

namespace kraken::debugger {
class LogEntry {
  KRAKEN_DISALLOW_COPY(LogEntry);

public:
  static std::unique_ptr<LogEntry> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~LogEntry() {}

  struct SourceEnum {
    static const char *Xml;
    static const char *Javascript;
    static const char *Network;
    static const char *Storage;
    static const char *Appcache;
    static const char *Rendering;
    static const char *Security;
    static const char *Deprecation;
    static const char *Worker;
    static const char *Violation;
    static const char *Intervention;
    static const char *Recommendation;
    static const char *Other;
  }; // SourceEnum

  std::string getSource() {
    return m_source;
  }

  void setSource(const std::string &value) {
    m_source = value;
  }

  struct LevelEnum {
    static const char *Verbose;
    static const char *Info;
    static const char *Warning;
    static const char *Error;
  }; // LevelEnum

  std::string getLevel() {
    return m_level;
  }

  void setLevel(const std::string &value) {
    m_level = value;
  }

  std::string getText() {
    return m_text;
  }

  void setText(const std::string &value) {
    m_text = value;
  }

  double getTimestamp() {
    return m_timestamp;
  }

  void setTimestamp(double value) {
    m_timestamp = value;
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

  bool hasLineNumber() {
    return m_lineNumber.isJust();
  }

  int getLineNumber(int defaultValue) {
    return m_lineNumber.isJust() ? m_lineNumber.fromJust() : defaultValue;
  }

  void setLineNumber(int value) {
    m_lineNumber = value;
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

  bool hasNetworkRequestId() {
    return m_networkRequestId.isJust();
  }

  std::string getNetworkRequestId(const std::string &defaultValue) {
    return m_networkRequestId.isJust() ? m_networkRequestId.fromJust() : defaultValue;
  }

  void setNetworkRequestId(const std::string &value) {
    m_networkRequestId = value;
  }

  bool hasWorkerId() {
    return m_workerId.isJust();
  }

  std::string getWorkerId(const std::string &defaultValue) {
    return m_workerId.isJust() ? m_workerId.fromJust() : defaultValue;
  }

  void setWorkerId(const std::string &value) {
    m_workerId = value;
  }

  //            bool hasArgs() { return m_args.isJust(); }
  //
  //            std::vector<RemoteObject> *
  //            getArgs(std::vector<RemoteObject> *defaultValue) {
  //                return m_args.isJust() ? m_args.fromJust() : defaultValue;
  //            }
  //
  //            void setArgs(std::unique_ptr<std::vector<RemoteObject>> value) {
  //                m_args = std::move(value);
  //            }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class LogEntryBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      SourceSet = 1 << 1,
      LevelSet = 1 << 2,
      TextSet = 1 << 3,
      TimestampSet = 1 << 4,
      AllFieldsSet = (SourceSet | LevelSet | TextSet | TimestampSet | 0)
    };

    LogEntryBuilder<STATE | SourceSet> &setSource(const std::string &value) {
      static_assert(!(STATE & SourceSet), "property source should not be set yet");
      m_result->setSource(value);
      return castState<SourceSet>();
    }

    LogEntryBuilder<STATE | LevelSet> &setLevel(const std::string &value) {
      static_assert(!(STATE & LevelSet), "property level should not be set yet");
      m_result->setLevel(value);
      return castState<LevelSet>();
    }

    LogEntryBuilder<STATE | TextSet> &setText(const std::string &value) {
      static_assert(!(STATE & TextSet), "property text should not be set yet");
      m_result->setText(value);
      return castState<TextSet>();
    }

    LogEntryBuilder<STATE | TimestampSet> &setTimestamp(double value) {
      static_assert(!(STATE & TimestampSet), "property timestamp should not be set yet");
      m_result->setTimestamp(value);
      return castState<TimestampSet>();
    }

    LogEntryBuilder<STATE> &setUrl(const std::string &value) {
      m_result->setUrl(value);
      return *this;
    }

    LogEntryBuilder<STATE> &setLineNumber(int value) {
      m_result->setLineNumber(value);
      return *this;
    }

    LogEntryBuilder<STATE> &setStackTrace(std::unique_ptr<StackTrace> value) {
      m_result->setStackTrace(std::move(value));
      return *this;
    }

    LogEntryBuilder<STATE> &setNetworkRequestId(const std::string &value) {
      m_result->setNetworkRequestId(value);
      return *this;
    }

    LogEntryBuilder<STATE> &setWorkerId(const std::string &value) {
      m_result->setWorkerId(value);
      return *this;
    }

    //                LogEntryBuilder<STATE> &
    //                setArgs(std::unique_ptr<std::vector<RemoteObject>> value) {
    //                    m_result->setArgs(std::move(value));
    //                    return *this;
    //                }

    std::unique_ptr<LogEntry> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class LogEntry;

    LogEntryBuilder() : m_result(new LogEntry()) {}

    template <int STEP> LogEntryBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<LogEntryBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<LogEntry> m_result;
  };

  static LogEntryBuilder<0> create() {
    return LogEntryBuilder<0>();
  }

private:
  LogEntry() {
    m_timestamp = 0;
  }

  std::string m_source;
  std::string m_level;
  std::string m_text;
  double m_timestamp;
  Maybe<std::string> m_url;
  Maybe<int> m_lineNumber;
  Maybe<StackTrace> m_stackTrace;
  Maybe<std::string> m_networkRequestId;
  Maybe<std::string> m_workerId;
  //            Maybe<std::vector<RemoteObject>> m_args;
};
} // namespace kraken::debugger

#endif // KRAKEN_DEBUGGER_LOG_ENTRY_H
