/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_ENTRY_PREVIEW_H
#define KRAKEN_DEBUGGER_ENTRY_PREVIEW_H

#include <memory>
#include <string>

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/maybe.h"
#include "kraken_foundation.h"
#include <rapidjson/document.h>

namespace kraken {
namespace debugger {
class ObjectPreview;
class EntryPreview {
  KRAKEN_DISALLOW_COPY(EntryPreview);

public:
  static std::unique_ptr<EntryPreview> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~EntryPreview() {}

  bool hasKey() {
    return m_key.isJust();
  }

  ObjectPreview *getKey(ObjectPreview *defaultValue) {
    return m_key.isJust() ? m_key.fromJust() : defaultValue;
  }

  void setKey(std::unique_ptr<ObjectPreview> value) {
    m_key = std::move(value);
  }

  ObjectPreview *getValue() {
    return m_value.get();
  }

  void setValue(std::unique_ptr<ObjectPreview> value) {
    m_value = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class EntryPreviewBuilder {
  public:
    enum { NoFieldsSet = 0, ValueSet = 1 << 1, AllFieldsSet = (ValueSet | 0) };

    EntryPreviewBuilder<STATE> &setKey(std::unique_ptr<ObjectPreview> value) {
      m_result->setKey(std::move(value));
      return *this;
    }

    EntryPreviewBuilder<STATE | ValueSet> &setValue(std::unique_ptr<ObjectPreview> value) {
      static_assert(!(STATE & ValueSet), "property value should not be set yet");
      m_result->setValue(std::move(value));
      return castState<ValueSet>();
    }

    std::unique_ptr<EntryPreview> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class EntryPreview;

    EntryPreviewBuilder() : m_result(new EntryPreview()) {}

    template <int STEP> EntryPreviewBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<EntryPreviewBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<EntryPreview> m_result;
  };

  static EntryPreviewBuilder<0> create() {
    return EntryPreviewBuilder<0>();
  }

private:
  EntryPreview() {}

  Maybe<ObjectPreview> m_key;
  std::unique_ptr<ObjectPreview> m_value;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_ENTRY_PREVIEW_H
