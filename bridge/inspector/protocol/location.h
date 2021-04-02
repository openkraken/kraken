/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_LOCATION_H
#define KRAKEN_DEBUGGER_LOCATION_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "kraken_foundation.h"
#include <memory>
#include <string>
#include <type_traits>
#include <rapidjson/document.h>

namespace kraken::debugger {

class Location {
  KRAKEN_DISALLOW_COPY(Location);

public:
  static std::unique_ptr<Location> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~Location() {}

  std::string getScriptId() {
    return m_scriptId;
  }

  void setScriptId(const std::string &value) {
    m_scriptId = value;
  }

  int getLineNumber() {
    return m_lineNumber;
  }

  void setLineNumber(int value) {
    m_lineNumber = value;
  }

  bool hasColumnNumber() {
    return m_columnNumber.isJust();
  }

  int getColumnNumber(int defaultValue) {
    return m_columnNumber.isJust() ? m_columnNumber.fromJust() : defaultValue;
  }

  void setColumnNumber(int value) {
    m_columnNumber = value;
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  //            String serializeToJSON() override { return toValue()->serializeToJSON(); }
  //            std::vector<uint8_t> serializeToBinary() override { return toValue()->serializeToBinary(); }
  //            String toJSON() const { return toValue()->toJSONString(); }
  //            std::unique_ptr<Location> clone() const;

  template <int STATE> class LocationBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      ScriptIdSet = 1 << 1,
      LineNumberSet = 1 << 2,
      AllFieldsSet = (ScriptIdSet | LineNumberSet | 0)
    };

    LocationBuilder<STATE | ScriptIdSet> &setScriptId(const std::string &value) {
      static_assert(!(STATE & ScriptIdSet), "property scriptId should not be set yet");
      m_result->setScriptId(value);
      return castState<ScriptIdSet>();
    }

    LocationBuilder<STATE | LineNumberSet> &setLineNumber(int value) {
      static_assert(!(STATE & LineNumberSet), "property lineNumber should not be set yet");
      m_result->setLineNumber(value);
      return castState<LineNumberSet>();
    }

    LocationBuilder<STATE> &setColumnNumber(int value) {
      m_result->setColumnNumber(value);
      return *this;
    }

    std::unique_ptr<Location> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class Location;

    LocationBuilder() : m_result(new Location()) {}

    template <int STEP> LocationBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<LocationBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<Location> m_result;
  };

  static LocationBuilder<0> create() {
    return LocationBuilder<0>();
  }

private:
  Location() {
    m_lineNumber = 0;
  }

  std::string m_scriptId;
  int m_lineNumber;
  Maybe<int> m_columnNumber;
};
} // namespace kraken::debugger

#endif // KRAKEN_DEBUGGER_LOCATION_H
