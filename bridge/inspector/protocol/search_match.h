/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_SEARCH_MATCH_H
#define KRAKEN_DEBUGGER_SEARCH_MATCH_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "kraken_foundation.h"
#include <memory>
#include <string>
#include <vector>
#include <rapidjson/document.h>

namespace kraken::debugger {
class SearchMatch {
  KRAKEN_DISALLOW_COPY(SearchMatch);

public:
  static std::unique_ptr<SearchMatch> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~SearchMatch() {}

  double getLineNumber() {
    return m_lineNumber;
  }

  void setLineNumber(double value) {
    m_lineNumber = value;
  }

  std::string getLineContent() {
    return m_lineContent;
  }

  void setLineContent(const std::string &value) {
    m_lineContent = value;
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class SearchMatchBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      LineNumberSet = 1 << 1,
      LineContentSet = 1 << 2,
      AllFieldsSet = (LineNumberSet | LineContentSet | 0)
    };

    SearchMatchBuilder<STATE | LineNumberSet> &setLineNumber(double value) {
      static_assert(!(STATE & LineNumberSet), "property lineNumber should not be set yet");
      m_result->setLineNumber(value);
      return castState<LineNumberSet>();
    }

    SearchMatchBuilder<STATE | LineContentSet> &setLineContent(const std::string &value) {
      static_assert(!(STATE & LineContentSet), "property lineContent should not be set yet");
      m_result->setLineContent(value);
      return castState<LineContentSet>();
    }

    std::unique_ptr<SearchMatch> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class SearchMatch;

    SearchMatchBuilder() : m_result(new SearchMatch()) {}

    template <int STEP> SearchMatchBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<SearchMatchBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<SearchMatch> m_result;
  };

  static SearchMatchBuilder<0> create() {
    return SearchMatchBuilder<0>();
  }

private:
  SearchMatch() {
    m_lineNumber = 0;
  }

  double m_lineNumber;
  std::string m_lineContent;
};

} // namespace kraken

#endif // KRAKEN_DEBUGGER_SEARCH_MATCH_H
