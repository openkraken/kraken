/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_PROPERTY_PREVIEW_H
#define KRAKEN_DEBUGGER_PROPERTY_PREVIEW_H

#include <memory>
#include <string>

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "kraken_foundation.h"
#include <rapidjson/document.h>

namespace kraken {
namespace debugger {
class ObjectPreview;
class PropertyPreview {
  KRAKEN_DISALLOW_COPY(PropertyPreview);

public:
  static std::unique_ptr<PropertyPreview> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~PropertyPreview() {}

  std::string getName() {
    return m_name;
  }

  void setName(const std::string &value) {
    m_name = value;
  }

  struct TypeEnum {
    static const char *Object;
    static const char *Function;
    static const char *Undefined;
    static const char *String;
    static const char *Number;
    static const char *Boolean;
    static const char *Symbol;
    static const char *Accessor;
    static const char *Bigint;
  }; // TypeEnum

  std::string getType() {
    return m_type;
  }

  void setType(const std::string &value) {
    m_type = value;
  }

  bool hasValue() {
    return m_value.isJust();
  }

  std::string getValue(const std::string &defaultValue) {
    return m_value.isJust() ? m_value.fromJust() : defaultValue;
  }

  void setValue(const std::string &value) {
    m_value = value;
  }

  bool hasValuePreview() {
    return m_valuePreview.isJust();
  }

  ObjectPreview *getValuePreview(ObjectPreview *defaultValue) {
    return m_valuePreview.isJust() ? m_valuePreview.fromJust() : defaultValue;
  }

  void setValuePreview(std::unique_ptr<ObjectPreview> value) {
    m_valuePreview = std::move(value);
  }

  struct SubtypeEnum {
    static const char *Array;
    static const char *Null;
    static const char *Node;
    static const char *Regexp;
    static const char *Date;
    static const char *Map;
    static const char *Set;
    static const char *Weakmap;
    static const char *Weakset;
    static const char *Iterator;
    static const char *Generator;
    static const char *Error;
  }; // SubtypeEnum

  bool hasSubtype() {
    return m_subtype.isJust();
  }

  std::string getSubtype(const std::string &defaultValue) {
    return m_subtype.isJust() ? m_subtype.fromJust() : defaultValue;
  }

  void setSubtype(const std::string &value) {
    m_subtype = value;
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class PropertyPreviewBuilder {
  public:
    enum { NoFieldsSet = 0, NameSet = 1 << 1, TypeSet = 1 << 2, AllFieldsSet = (NameSet | TypeSet | 0) };

    PropertyPreviewBuilder<STATE | NameSet> &setName(const std::string &value) {
      static_assert(!(STATE & NameSet), "property name should not be set yet");
      m_result->setName(value);
      return castState<NameSet>();
    }

    PropertyPreviewBuilder<STATE | TypeSet> &setType(const std::string &value) {
      static_assert(!(STATE & TypeSet), "property type should not be set yet");
      m_result->setType(value);
      return castState<TypeSet>();
    }

    PropertyPreviewBuilder<STATE> &setValue(const std::string &value) {
      m_result->setValue(value);
      return *this;
    }

    PropertyPreviewBuilder<STATE> &setValuePreview(std::unique_ptr<ObjectPreview> value) {
      m_result->setValuePreview(std::move(value));
      return *this;
    }

    PropertyPreviewBuilder<STATE> &setSubtype(const std::string &value) {
      m_result->setSubtype(value);
      return *this;
    }

    std::unique_ptr<PropertyPreview> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class PropertyPreview;

    PropertyPreviewBuilder() : m_result(new PropertyPreview()) {}

    template <int STEP> PropertyPreviewBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<PropertyPreviewBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<PropertyPreview> m_result;
  };

  static PropertyPreviewBuilder<0> create() {
    return PropertyPreviewBuilder<0>();
  }

private:
  PropertyPreview() {}

  std::string m_name;
  std::string m_type;
  Maybe<std::string> m_value;
  Maybe<ObjectPreview> m_valuePreview;
  Maybe<std::string> m_subtype;
};

} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_PROPERTY_PREVIEW_H
