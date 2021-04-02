/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_DOMAIN_H
#define KRAKEN_DEBUGGER_DOMAIN_H

#include <string>

namespace kraken {
namespace debugger {

class Domain {
  KRAKEN_DISALLOW_COPY(Domain);

public:
  ~Domain() {}

  std::string getName() {
    return m_name;
  }

  void setName(const std::string &value) {
    m_name = value;
  }

  std::string getVersion() {
    return m_version;
  }

  void setVersion(const std::string &value) {
    m_version = value;
  }

  template <int STATE> class DomainBuilder {
  public:
    enum { NoFieldsSet = 0, NameSet = 1 << 1, VersionSet = 1 << 2, AllFieldsSet = (NameSet | VersionSet | 0) };

    DomainBuilder<STATE | NameSet> &setName(const std::string &value) {
      static_assert(!(STATE & NameSet), "property name should not be set yet");
      m_result->setName(value);
      return castState<NameSet>();
    }

    DomainBuilder<STATE | VersionSet> &setVersion(const std::string &value) {
      static_assert(!(STATE & VersionSet), "property version should not be set yet");
      m_result->setVersion(value);
      return castState<VersionSet>();
    }

    std::unique_ptr<Domain> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class Domain;

    DomainBuilder() : m_result(new Domain()) {}

    template <int STEP> DomainBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<DomainBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<Domain> m_result;
  };

  static DomainBuilder<0> create() {
    return DomainBuilder<0>();
  }

private:
  Domain() {}

  std::string m_name;
  std::string m_version;
};

} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_DOMAIN_H
