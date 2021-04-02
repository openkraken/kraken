/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_EXECUTION_CONTEXT_DESCRIPTION_H
#define KRAKEN_DEBUGGER_EXECUTION_CONTEXT_DESCRIPTION_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "kraken_foundation.h"
#include <memory>
#include <rapidjson/document.h>
#include <string>
#include <vector>

namespace kraken::debugger {
class ExecutionContextDescription {
  KRAKEN_DISALLOW_COPY(ExecutionContextDescription);

public:
  static std::unique_ptr<ExecutionContextDescription> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~ExecutionContextDescription() {}

  int getId() {
    return m_id;
  }

  void setId(int value) {
    m_id = value;
  }

  std::string getOrigin() {
    return m_origin;
  }

  void setOrigin(const std::string &value) {
    m_origin = value;
  }

  std::string getName() {
    return m_name;
  }

  void setName(const std::string &value) {
    m_name = value;
  }

  bool hasAuxData() {
    return m_auxData.isJust();
  }

  rapidjson::Value *getAuxData(rapidjson::Value *defaultValue) {
    return m_auxData.isJust() ? m_auxData.fromJust() : defaultValue;
  }

  void setAuxData(std::unique_ptr<rapidjson::Value> value) {
    m_auxData = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class ExecutionContextDescriptionBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      IdSet = 1 << 1,
      OriginSet = 1 << 2,
      NameSet = 1 << 3,
      AllFieldsSet = (IdSet | OriginSet | NameSet | 0)
    };

    ExecutionContextDescriptionBuilder<STATE | IdSet> &setId(int value) {
      static_assert(!(STATE & IdSet), "property id should not be set yet");
      m_result->setId(value);
      return castState<IdSet>();
    }

    ExecutionContextDescriptionBuilder<STATE | OriginSet> &setOrigin(const std::string &value) {
      static_assert(!(STATE & OriginSet), "property origin should not be set yet");
      m_result->setOrigin(value);
      return castState<OriginSet>();
    }

    ExecutionContextDescriptionBuilder<STATE | NameSet> &setName(const std::string &value) {
      static_assert(!(STATE & NameSet), "property name should not be set yet");
      m_result->setName(value);
      return castState<NameSet>();
    }

    ExecutionContextDescriptionBuilder<STATE> &setAuxData(std::unique_ptr<rapidjson::Value> value) {
      m_result->setAuxData(std::move(value));
      return *this;
    }

    std::unique_ptr<ExecutionContextDescription> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class ExecutionContextDescription;

    ExecutionContextDescriptionBuilder() : m_result(new ExecutionContextDescription()) {}

    template <int STEP> ExecutionContextDescriptionBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<ExecutionContextDescriptionBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<ExecutionContextDescription> m_result;
  };

  static ExecutionContextDescriptionBuilder<0> create() {
    return ExecutionContextDescriptionBuilder<0>();
  }

private:
  ExecutionContextDescription() {
    m_id = 0;
  }

  int m_id;
  std::string m_origin;
  std::string m_name;
  Maybe<rapidjson::Value> m_auxData;
  rapidjson::Document m_doc;
};
} // namespace kraken::debugger

#endif // KRAKEN_DEBUGGER_EXECUTION_CONTEXT_DESCRIPTION_H
