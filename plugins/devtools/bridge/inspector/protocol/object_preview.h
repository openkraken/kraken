/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_OBJECT_PREVIEW_H
#define KRAKEN_DEBUGGER_OBJECT_PREVIEW_H

#include <memory>
#include <string>

#include "inspector/protocol/entry_preview.h"
#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "inspector/protocol/property_preview.h"
#include "kraken_foundation.h"
#include <rapidjson/document.h>

namespace kraken {
namespace debugger {

class ObjectPreview {
  KRAKEN_DISALLOW_COPY(ObjectPreview);

public:
  static std::unique_ptr<ObjectPreview> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~ObjectPreview() {}

  struct TypeEnum {
    static const char *Object;
    static const char *Function;
    static const char *Undefined;
    static const char *String;
    static const char *Number;
    static const char *Boolean;
    static const char *Symbol;
    static const char *Bigint;
  }; // TypeEnum

  std::string getType() {
    return m_type;
  }

  void setType(const std::string &value) {
    m_type = value;
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

  bool hasDescription() {
    return m_description.isJust();
  }

  std::string getDescription(const std::string &defaultValue) {
    return m_description.isJust() ? m_description.fromJust() : defaultValue;
  }

  void setDescription(const std::string &value) {
    m_description = value;
  }

  bool getOverflow() {
    return m_overflow;
  }

  void setOverflow(bool value) {
    m_overflow = value;
  }

  std::vector<std::unique_ptr<PropertyPreview>> *getProperties() {
    return m_properties.get();
  }

  void setProperties(std::unique_ptr<std::vector<std::unique_ptr<PropertyPreview>>> value) {
    m_properties = std::move(value);
  }

  bool hasEntries() {
    return m_entries.isJust();
  }

  std::vector<std::unique_ptr<EntryPreview>> *getEntries(std::vector<std::unique_ptr<EntryPreview>> *defaultValue) {
    return m_entries.isJust() ? m_entries.fromJust() : defaultValue;
  }

  void setEntries(std::unique_ptr<std::vector<std::unique_ptr<EntryPreview>>> value) {
    m_entries = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class ObjectPreviewBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      TypeSet = 1 << 1,
      OverflowSet = 1 << 2,
      PropertiesSet = 1 << 3,
      AllFieldsSet = (TypeSet | OverflowSet | PropertiesSet | 0)
    };

    ObjectPreviewBuilder<STATE | TypeSet> &setType(const std::string &value) {
      static_assert(!(STATE & TypeSet), "property type should not be set yet");
      m_result->setType(value);
      return castState<TypeSet>();
    }

    ObjectPreviewBuilder<STATE> &setSubtype(const std::string &value) {
      m_result->setSubtype(value);
      return *this;
    }

    ObjectPreviewBuilder<STATE> &setDescription(const std::string &value) {
      m_result->setDescription(value);
      return *this;
    }

    ObjectPreviewBuilder<STATE | OverflowSet> &setOverflow(bool value) {
      static_assert(!(STATE & OverflowSet), "property overflow should not be set yet");
      m_result->setOverflow(value);
      return castState<OverflowSet>();
    }

    ObjectPreviewBuilder<STATE | PropertiesSet> &
    setProperties(std::unique_ptr<std::vector<std::unique_ptr<PropertyPreview>>> value) {
      static_assert(!(STATE & PropertiesSet), "property properties should not be set yet");
      m_result->setProperties(std::move(value));
      return castState<PropertiesSet>();
    }

    ObjectPreviewBuilder<STATE> &setEntries(std::unique_ptr<std::vector<std::unique_ptr<EntryPreview>>> value) {
      m_result->setEntries(std::move(value));
      return *this;
    }

    std::unique_ptr<ObjectPreview> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class ObjectPreview;

    ObjectPreviewBuilder() : m_result(new ObjectPreview()) {}

    template <int STEP> ObjectPreviewBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<ObjectPreviewBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<ObjectPreview> m_result;
  };

  static ObjectPreviewBuilder<0> create() {
    return ObjectPreviewBuilder<0>();
  }

private:
  ObjectPreview() {
    m_overflow = false;
  }

  std::string m_type;
  Maybe<std::string> m_subtype;
  Maybe<std::string> m_description;
  bool m_overflow;
  std::unique_ptr<std::vector<std::unique_ptr<PropertyPreview>>> m_properties;
  Maybe<std::vector<std::unique_ptr<EntryPreview>>> m_entries;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_OBJECT_PREVIEW_H
