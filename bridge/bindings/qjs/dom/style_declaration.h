/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_STYLE_DECLARATION_H
#define KRAKENBRIDGE_STYLE_DECLARATION_H

#include "bindings/qjs/host_class.h"

namespace kraken::binding::qjs {

class EventTargetInstance;
void bindCSSStyleDeclaration(std::unique_ptr<JSContext>& context);

template <typename CharacterType>
inline bool isASCIILower(CharacterType character) {
  return character >= 'a' && character <= 'z';
}

template <typename CharacterType>
inline CharacterType toASCIIUpper(CharacterType character) {
  return character & ~(isASCIILower(character) << 5);
}

class CSSStyleDeclaration : public HostClass {
 public:
  OBJECT_INSTANCE(CSSStyleDeclaration);

  static JSClassID kCSSStyleDeclarationClassId;

  CSSStyleDeclaration() = delete;
  ~CSSStyleDeclaration(){};
  explicit CSSStyleDeclaration(JSContext* context);

  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  static JSValue setProperty(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue removeProperty(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getPropertyValue(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

 protected:
  DEFINE_PROTOTYPE_FUNCTION(setProperty, 2);
  DEFINE_PROTOTYPE_FUNCTION(getPropertyValue, 2);
  DEFINE_PROTOTYPE_FUNCTION(removeProperty, 2);
};

class StyleDeclarationInstance : public Instance {
 public:
  StyleDeclarationInstance() = delete;
  explicit StyleDeclarationInstance(CSSStyleDeclaration* cssStyleDeclaration, EventTargetInstance* ownerEventTarget);
  ~StyleDeclarationInstance();
  bool internalSetProperty(std::string& name, JSValue value);
  void internalRemoveProperty(std::string& name);
  JSValue internalGetPropertyValue(std::string& name);
  std::string toString();
  void copyWith(StyleDeclarationInstance* instance);

  void gcMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;

  const EventTargetInstance* ownerEventTarget;

 private:
  static int hasProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom);
  static int setProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);

  static JSValue getProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);

  static void finalize(JSRuntime* rt, JSValue val) {
    auto* instance = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(val, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
    delete instance;
  }

  static JSClassExoticMethods m_exoticMethods;

  std::unordered_map<std::string, std::string> properties;
  friend EventTargetInstance;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_STYLE_DECLARATION_H
