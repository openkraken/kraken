/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_PROPERTY_DESCRIPTOR_H
#define KRAKEN_DEBUGGER_PROPERTY_DESCRIPTOR_H

#include "inspector/protocol/remote_object.h"
#include "kraken_foundation.h"
#include <memory>
#include <string>

namespace kraken {
namespace debugger {
class PropertyDescriptor {
  KRAKEN_DISALLOW_COPY(PropertyDescriptor);

public:
  static std::unique_ptr<PropertyDescriptor> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~PropertyDescriptor() {}

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

  bool hasWritable() {
    return m_writable.isJust();
  }

  bool getWritable(bool defaultValue) {
    return m_writable.isJust() ? m_writable.fromJust() : defaultValue;
  }

  void setWritable(bool value) {
    m_writable = value;
  }

  bool hasGet() {
    return m_get.isJust();
  }

  RemoteObject *getGet(RemoteObject *defaultValue) {
    return m_get.isJust() ? m_get.fromJust() : defaultValue;
  }

  void setGet(std::unique_ptr<RemoteObject> value) {
    m_get = std::move(value);
  }

  bool hasSet() {
    return m_set.isJust();
  }

  RemoteObject *getSet(RemoteObject *defaultValue) {
    return m_set.isJust() ? m_set.fromJust() : defaultValue;
  }

  void setSet(std::unique_ptr<RemoteObject> value) {
    m_set = std::move(value);
  }

  bool getConfigurable() {
    return m_configurable;
  }

  void setConfigurable(bool value) {
    m_configurable = value;
  }

  bool getEnumerable() {
    return m_enumerable;
  }

  void setEnumerable(bool value) {
    m_enumerable = value;
  }

  bool hasWasThrown() {
    return m_wasThrown.isJust();
  }

  bool getWasThrown(bool defaultValue) {
    return m_wasThrown.isJust() ? m_wasThrown.fromJust() : defaultValue;
  }

  void setWasThrown(bool value) {
    m_wasThrown = value;
  }

  bool hasIsOwn() {
    return m_isOwn.isJust();
  }

  bool getIsOwn(bool defaultValue) {
    return m_isOwn.isJust() ? m_isOwn.fromJust() : defaultValue;
  }

  void setIsOwn(bool value) {
    m_isOwn = value;
  }

  bool hasSymbol() {
    return m_symbol.isJust();
  }

  RemoteObject *getSymbol(RemoteObject *defaultValue) {
    return m_symbol.isJust() ? m_symbol.fromJust() : defaultValue;
  }

  void setSymbol(std::unique_ptr<RemoteObject> value) {
    m_symbol = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class PropertyDescriptorBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      NameSet = 1 << 1,
      ConfigurableSet = 1 << 2,
      EnumerableSet = 1 << 3,
      AllFieldsSet = (NameSet | ConfigurableSet | EnumerableSet | 0)
    };

    PropertyDescriptorBuilder<STATE | NameSet> &setName(const std::string &value) {
      static_assert(!(STATE & NameSet), "property name should not be set yet");
      m_result->setName(value);
      return castState<NameSet>();
    }

    PropertyDescriptorBuilder<STATE> &setValue(std::unique_ptr<RemoteObject> value) {
      m_result->setValue(std::move(value));
      return *this;
    }

    PropertyDescriptorBuilder<STATE> &setWritable(bool value) {
      m_result->setWritable(value);
      return *this;
    }

    PropertyDescriptorBuilder<STATE> &setGet(std::unique_ptr<RemoteObject> value) {
      m_result->setGet(std::move(value));
      return *this;
    }

    PropertyDescriptorBuilder<STATE> &setSet(std::unique_ptr<RemoteObject> value) {
      m_result->setSet(std::move(value));
      return *this;
    }

    PropertyDescriptorBuilder<STATE | ConfigurableSet> &setConfigurable(bool value) {
      static_assert(!(STATE & ConfigurableSet), "property configurable should not be set yet");
      m_result->setConfigurable(value);
      return castState<ConfigurableSet>();
    }

    PropertyDescriptorBuilder<STATE | EnumerableSet> &setEnumerable(bool value) {
      static_assert(!(STATE & EnumerableSet), "property enumerable should not be set yet");
      m_result->setEnumerable(value);
      return castState<EnumerableSet>();
    }

    PropertyDescriptorBuilder<STATE> &setWasThrown(bool value) {
      m_result->setWasThrown(value);
      return *this;
    }

    PropertyDescriptorBuilder<STATE> &setIsOwn(bool value) {
      m_result->setIsOwn(value);
      return *this;
    }

    PropertyDescriptorBuilder<STATE> &setSymbol(std::unique_ptr<RemoteObject> value) {
      m_result->setSymbol(std::move(value));
      return *this;
    }

    std::unique_ptr<PropertyDescriptor> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class PropertyDescriptor;

    PropertyDescriptorBuilder() : m_result(new PropertyDescriptor()) {}

    template <int STEP> PropertyDescriptorBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<PropertyDescriptorBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<PropertyDescriptor> m_result;
  };

  static PropertyDescriptorBuilder<0> create() {
    return PropertyDescriptorBuilder<0>();
  }

private:
  PropertyDescriptor() {
    m_configurable = false;
    m_enumerable = false;
  }

  std::string m_name;
  Maybe<RemoteObject> m_value;
  Maybe<bool> m_writable;
  Maybe<RemoteObject> m_get;
  Maybe<RemoteObject> m_set;
  bool m_configurable;
  bool m_enumerable;
  Maybe<bool> m_wasThrown;
  Maybe<bool> m_isOwn;
  Maybe<RemoteObject> m_symbol;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_PROPERTY_DESCRIPTOR_H
