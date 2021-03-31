/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_INTERNAL_PROPERTY_DESCRIPTOR_H
#define KRAKEN_DEBUGGER_INTERNAL_PROPERTY_DESCRIPTOR_H

#include "inspector/protocol/remote_object.h"
#include <string>

namespace kraken {
namespace debugger {
class InternalPropertyDescriptor {
  KRAKEN_DISALLOW_COPY(InternalPropertyDescriptor);

public:
  static std::unique_ptr<InternalPropertyDescriptor> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~InternalPropertyDescriptor() {}

  std::string getName() {
    return m_name;
  }

  void setName(const std::string &value) {
    m_name = value;
  }

  bool hasValue() {
    return m_value.isJust();
  }

  RemoteObject *getValue(RemoteObject *defaultValue) {
    return m_value.isJust() ? m_value.fromJust() : defaultValue;
  }

  void setValue(std::unique_ptr<RemoteObject> value) {
    m_value = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class InternalPropertyDescriptorBuilder {
  public:
    enum { NoFieldsSet = 0, NameSet = 1 << 1, AllFieldsSet = (NameSet | 0) };

    InternalPropertyDescriptorBuilder<STATE | NameSet> &setName(const std::string &value) {
      static_assert(!(STATE & NameSet), "property name should not be set yet");
      m_result->setName(value);
      return castState<NameSet>();
    }

    InternalPropertyDescriptorBuilder<STATE> &setValue(std::unique_ptr<RemoteObject> value) {
      m_result->setValue(std::move(value));
      return *this;
    }

    std::unique_ptr<InternalPropertyDescriptor> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class InternalPropertyDescriptor;

    InternalPropertyDescriptorBuilder() : m_result(new InternalPropertyDescriptor()) {}

    template <int STEP> InternalPropertyDescriptorBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<InternalPropertyDescriptorBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<InternalPropertyDescriptor> m_result;
  };

  static InternalPropertyDescriptorBuilder<0> create() {
    return InternalPropertyDescriptorBuilder<0>();
  }

private:
  InternalPropertyDescriptor() {}

  std::string m_name;
  Maybe<RemoteObject> m_value;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_INTERNAL_PROPERTY_DESCRIPTOR_H
