/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_PRIVATE_PROPERTY_DESCRIPTOR_H
#define KRAKEN_DEBUGGER_PRIVATE_PROPERTY_DESCRIPTOR_H

#include "inspector/protocol/remote_object.h"
#include "kraken_foundation.h"
#include <string>

namespace kraken {
namespace debugger {
class PrivatePropertyDescriptor {
  KRAKEN_DISALLOW_COPY(PrivatePropertyDescriptor);

public:
  static std::unique_ptr<PrivatePropertyDescriptor> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~PrivatePropertyDescriptor() {}

  std::string getName() {
    return m_name;
  }

  void setName(const std::string &value) {
    m_name = value;
  }

  RemoteObject *getValue() {
    return m_value.get();
  }

  void setValue(std::unique_ptr<RemoteObject> value) {
    m_value = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class PrivatePropertyDescriptorBuilder {
  public:
    enum { NoFieldsSet = 0, NameSet = 1 << 1, ValueSet = 1 << 2, AllFieldsSet = (NameSet | ValueSet | 0) };

    PrivatePropertyDescriptorBuilder<STATE | NameSet> &setName(const std::string &value) {
      static_assert(!(STATE & NameSet), "property name should not be set yet");
      m_result->setName(value);
      return castState<NameSet>();
    }

    PrivatePropertyDescriptorBuilder<STATE | ValueSet> &setValue(std::unique_ptr<RemoteObject> value) {
      static_assert(!(STATE & ValueSet), "property value should not be set yet");
      m_result->setValue(std::move(value));
      return castState<ValueSet>();
    }

    std::unique_ptr<PrivatePropertyDescriptor> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class PrivatePropertyDescriptor;

    PrivatePropertyDescriptorBuilder() : m_result(new PrivatePropertyDescriptor()) {}

    template <int STEP> PrivatePropertyDescriptorBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<PrivatePropertyDescriptorBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<PrivatePropertyDescriptor> m_result;
  };

  static PrivatePropertyDescriptorBuilder<0> create() {
    return PrivatePropertyDescriptorBuilder<0>();
  }

private:
  PrivatePropertyDescriptor() {}

  std::string m_name;
  std::unique_ptr<RemoteObject> m_value;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_PRIVATE_PROPERTY_DESCRIPTOR_H
