/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_STYLE_DECLARATION_H
#define KRAKENBRIDGE_STYLE_DECLARATION_H

#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/context_macros.h"
#include "bindings/qjs/dom/event_target.h"

namespace kraken::binding::qjs {

void bindCSSStyleDeclaration(std::unique_ptr<ExecutionContext>& context);

template <typename CharacterType>
inline bool isASCIILower(CharacterType character) {
  return character >= 'a' && character <= 'z';
}

template <typename CharacterType>
inline CharacterType toASCIIUpper(CharacterType character) {
  return character & ~(isASCIILower(character) << 5);
}

class CSSStyleDeclaration : public GarbageCollected<CSSStyleDeclaration> {
 public:
  static JSClassID classId;
  static CSSStyleDeclaration* create(JSContext* ctx);
  static JSValue constructor(ExecutionContext* context);
  static JSValue prototype(ExecutionContext* context);

  CSSStyleDeclaration();

  bool internalSetProperty(std::string& name, JSValue value);
  void internalRemoveProperty(std::string& name);
  JSValue internalGetPropertyValue(std::string& name);
  std::string toString();
  void copyWith(CSSStyleDeclaration* instance);

  DEFINE_FUNCTION(setProperty);
  DEFINE_FUNCTION(removeProperty);
  DEFINE_FUNCTION(getPropertyValue);

 private:

  static int hasProperty(JSContext* ctx, JSValueConst obj, JSAtom atom);
  static int setProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);
  static JSValue getProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);

  std::unordered_map<std::string, std::string> properties;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_STYLE_DECLARATION_H
