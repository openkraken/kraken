/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_SCOPE_H
#define KRAKEN_DEBUGGER_SCOPE_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/location.h"
#include "inspector/protocol/remote_object.h"
#include "kraken_foundation.h"
#include <memory>
#include <string>
#include <type_traits>

namespace kraken::debugger {
class Scope {
  KRAKEN_DISALLOW_COPY(Scope);

public:
  static std::unique_ptr<Scope> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~Scope() {}

  struct TypeEnum {
    static const char *Global;
    static const char *Local;
    static const char *With;
    static const char *Closure;
    static const char *Catch;
    static const char *Block;
    static const char *Script;
    static const char *Eval;
    static const char *Module;
  }; // TypeEnum

  std::string getType() {
    return m_type;
  }
  void setType(const std::string &value) {
    m_type = value;
  }

  RemoteObject *getObject() {
    return m_object.get();
  }
  void setObject(std::unique_ptr<RemoteObject> value) {
    m_object = std::move(value);
  }

  bool hasName() {
    return m_name.isJust();
  }
  std::string getName(const std::string &defaultValue) {
    return m_name.isJust() ? m_name.fromJust() : defaultValue;
  }
  void setName(const std::string &value) {
    m_name = value;
  }

  bool hasStartLocation() {
    return m_startLocation.isJust();
  }
  Location *getStartLocation(Location *defaultValue) {
    return m_startLocation.isJust() ? m_startLocation.fromJust() : defaultValue;
  }
  void setStartLocation(std::unique_ptr<Location> value) {
    m_startLocation = std::move(value);
  }

  bool hasEndLocation() {
    return m_endLocation.isJust();
  }
  Location *getEndLocation(Location *defaultValue) {
    return m_endLocation.isJust() ? m_endLocation.fromJust() : defaultValue;
  }
  void setEndLocation(std::unique_ptr<Location> value) {
    m_endLocation = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class ScopeBuilder {
  public:
    enum { NoFieldsSet = 0, TypeSet = 1 << 1, ObjectSet = 1 << 2, AllFieldsSet = (TypeSet | ObjectSet | 0) };

    ScopeBuilder<STATE | TypeSet> &setType(const std::string &value) {
      static_assert(!(STATE & TypeSet), "property type should not be set yet");
      m_result->setType(value);
      return castState<TypeSet>();
    }

    ScopeBuilder<STATE | ObjectSet> &setObject(std::unique_ptr<RemoteObject> value) {
      static_assert(!(STATE & ObjectSet), "property object should not be set yet");
      m_result->setObject(std::move(value));
      return castState<ObjectSet>();
    }

    ScopeBuilder<STATE> &setName(const std::string &value) {
      m_result->setName(value);
      return *this;
    }

    ScopeBuilder<STATE> &setStartLocation(std::unique_ptr<Location> value) {
      m_result->setStartLocation(std::move(value));
      return *this;
    }

    ScopeBuilder<STATE> &setEndLocation(std::unique_ptr<Location> value) {
      m_result->setEndLocation(std::move(value));
      return *this;
    }

    std::unique_ptr<Scope> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class Scope;
    ScopeBuilder() : m_result(new Scope()) {}

    template <int STEP> ScopeBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<ScopeBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<Scope> m_result;
  };

  static ScopeBuilder<0> create() {
    return ScopeBuilder<0>();
  }

private:
  Scope() {}

  std::string m_type;
  std::unique_ptr<RemoteObject> m_object;
  Maybe<std::string> m_name;
  Maybe<Location> m_startLocation;
  Maybe<Location> m_endLocation;
};

} // namespace kraken

#endif // KRAKEN_DEBUGGER_SCOPE_H
