/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CSS_STYLE_DECLARATION_H
#define KRAKENBRIDGE_CSS_STYLE_DECLARATION_H

#include <unordered_map>
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/script_wrappable.h"

namespace kraken {

class Element;

class CSSStyleDeclaration : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CSSStyleDeclaration*;
  static CSSStyleDeclaration* Create(ExecutingContext* context, ExceptionState& exception_state);
  explicit CSSStyleDeclaration(ExecutingContext* context, int64_t owner_element_target_id);

  AtomicString item(const AtomicString& key, ExceptionState& exception_state);
  bool SetItem(const AtomicString& key, const AtomicString& value, ExceptionState& exception_state);
  int64_t length() const;

  AtomicString getPropertyValue(const AtomicString& key, ExceptionState& exception_state);
  void setProperty(const AtomicString& key, const AtomicString& value, ExceptionState& exception_state);
  AtomicString removeProperty(const AtomicString& key, ExceptionState& exception_state);

  void CopyWith(CSSStyleDeclaration* attributes);

 private:
  AtomicString InternalGetPropertyValue(std::string& name);
  bool InternalSetProperty(std::string& name, const AtomicString& value);
  AtomicString InternalRemoveProperty(std::string& name);
  std::unordered_map<std::string, AtomicString> properties_;
  int32_t owner_element_target_id_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CSS_STYLE_DECLARATION_H
