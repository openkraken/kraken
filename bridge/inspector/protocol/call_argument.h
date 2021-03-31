/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_CALL_ARGUMENT_H
#define KRAKEN_DEBUGGER_CALL_ARGUMENT_H

#include "kraken_foundation.h"
#include "inspector/protocol/error_support.h"
#include "inspector/protocol/stacktrace.h"
#include <memory>
#include <string>
#include <vector>
#include <rapidjson/document.h>

namespace kraken::debugger {

class CallArgument {
  KRAKEN_DISALLOW_COPY(CallArgument);

public:
  static std::unique_ptr<CallArgument> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~CallArgument() {}

  bool hasValue() {
    return m_value.isJust();
  }

  rapidjson::Value *getValue(rapidjson::Value *defaultValue) {
    return m_value.isJust() ? m_value.fromJust() : defaultValue;
  }

  void setValue(std::unique_ptr<rapidjson::Value> value) {
    m_value = std::move(value);
  }

  bool hasUnserializableValue() {
    return m_unserializableValue.isJust();
  }

  std::string getUnserializableValue(const std::string &defaultValue) {
    return m_unserializableValue.isJust() ? m_unserializableValue.fromJust() : defaultValue;
  }

  void setUnserializableValue(const std::string &value) {
    m_unserializableValue = value;
  }

  bool hasObjectId() {
    return m_objectId.isJust();
  }

  std::string getObjectId(const std::string &defaultValue) {
    return m_objectId.isJust() ? m_objectId.fromJust() : defaultValue;
  }

  void setObjectId(const std::string &value) {
    m_objectId = value;
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class CallArgumentBuilder {
  public:
    enum { NoFieldsSet = 0, AllFieldsSet = (0) };

    CallArgumentBuilder<STATE> &setValue(std::unique_ptr<rapidjson::Value> value) {
      m_result->setValue(std::move(value));
      return *this;
    }

    CallArgumentBuilder<STATE> &setUnserializableValue(const std::string &value) {
      m_result->setUnserializableValue(value);
      return *this;
    }

    CallArgumentBuilder<STATE> &setObjectId(const std::string &value) {
      m_result->setObjectId(value);
      return *this;
    }

    std::unique_ptr<CallArgument> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class CallArgument;

    CallArgumentBuilder() : m_result(new CallArgument()) {}

    template <int STEP> CallArgumentBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<CallArgumentBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<CallArgument> m_result;
  };

  static CallArgumentBuilder<0> create() {
    return CallArgumentBuilder<0>();
  }

private:
  CallArgument() {}

  Maybe<rapidjson::Value> m_value;
  Maybe<std::string> m_unserializableValue;
  Maybe<std::string> m_objectId;
  rapidjson::Document m_holder;
};

} // namespace kraken

#endif // KRAKEN_DEBUGGER_CALL_ARGUMENT_H
