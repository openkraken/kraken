/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_REMOTE_OBJECT_H
#define KRAKEN_DEBUGGER_REMOTE_OBJECT_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "inspector/protocol/object_preview.h"
#include "kraken_foundation.h"
#include <rapidjson/document.h>
#include <string>

namespace kraken {
namespace debugger {
class RemoteObject {
  KRAKEN_DISALLOW_COPY(RemoteObject);

public:
  static std::unique_ptr<RemoteObject> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~RemoteObject() {}

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
    static const char *Proxy;
    static const char *Promise;
    static const char *Typedarray;
    static const char *Arraybuffer;
    static const char *Dataview;
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

  bool hasClassName() {
    return m_className.isJust();
  }

  std::string getClassName(const std::string &defaultValue) {
    return m_className.isJust() ? m_className.fromJust() : defaultValue;
  }

  void setClassName(const std::string &value) {
    m_className = value;
  }

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

  bool hasDescription() {
    return m_description.isJust();
  }

  std::string getDescription(const std::string &defaultValue) {
    return m_description.isJust() ? m_description.fromJust() : defaultValue;
  }

  void setDescription(const std::string &value) {
    m_description = value;
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

  bool hasPreview() {
    return m_preview.isJust();
  }

  ObjectPreview *getPreview(ObjectPreview *defaultValue) {
    return m_preview.isJust() ? m_preview.fromJust() : defaultValue;
  }

  void setPreview(std::unique_ptr<ObjectPreview> value) {
    m_preview = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class RemoteObjectBuilder {
  public:
    enum { NoFieldsSet = 0, TypeSet = 1 << 1, AllFieldsSet = (TypeSet | 0) };

    RemoteObjectBuilder<STATE | TypeSet> &setType(const std::string &value) {
      static_assert(!(STATE & TypeSet), "property type should not be set yet");
      m_result->setType(value);
      return castState<TypeSet>();
    }

    RemoteObjectBuilder<STATE> &setSubtype(const std::string &value) {
      m_result->setSubtype(value);
      return *this;
    }

    RemoteObjectBuilder<STATE> &setClassName(const std::string &value) {
      m_result->setClassName(value);
      return *this;
    }

    RemoteObjectBuilder<STATE> &setValue(std::unique_ptr<rapidjson::Value> value) {
      m_result->setValue(std::move(value));
      return *this;
    }

    RemoteObjectBuilder<STATE> &setUnserializableValue(const std::string &value) {
      m_result->setUnserializableValue(value);
      return *this;
    }

    RemoteObjectBuilder<STATE> &setDescription(const std::string &value) {
      m_result->setDescription(value);
      return *this;
    }

    RemoteObjectBuilder<STATE> &setObjectId(const std::string &value) {
      m_result->setObjectId(value);
      return *this;
    }

    RemoteObjectBuilder<STATE> &setPreview(std::unique_ptr<ObjectPreview> value) {
      m_result->setPreview(std::move(value));
      return *this;
    }

    std::unique_ptr<RemoteObject> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class RemoteObject;

    RemoteObjectBuilder() : m_result(new RemoteObject()) {}

    template <int STEP> RemoteObjectBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<RemoteObjectBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<RemoteObject> m_result;
  };

  static RemoteObjectBuilder<0> create() {
    return RemoteObjectBuilder<0>();
  }

private:
  RemoteObject() {}

  std::string m_type;
  Maybe<std::string> m_subtype;
  Maybe<std::string> m_className;
  Maybe<rapidjson::Value> m_value;
  Maybe<std::string> m_unserializableValue;
  Maybe<std::string> m_description;
  Maybe<std::string> m_objectId;
  rapidjson::Document m_holder;
  Maybe<ObjectPreview> m_preview;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_REMOTE_OBJECT_H
