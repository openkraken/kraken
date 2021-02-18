/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_STYLE_DECLARATION_H
#define KRAKENBRIDGE_STYLE_DECLARATION_H

#include "bindings/jsc/DOM/event_target.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context.h"
#include <map>

namespace kraken::binding::jsc {

void bindCSSStyleDeclaration(std::unique_ptr<JSContext> &context);

template <typename CharacterType> inline bool isASCIILower(CharacterType character) {
  return character >= 'a' && character <= 'z';
}

template <typename CharacterType> inline CharacterType toASCIIUpper(CharacterType character) {
  return character & ~(isASCIILower(character) << 5);
}

class CSSStyleDeclaration : public HostClass {
public:

  static std::unordered_map<JSContext *, CSSStyleDeclaration *> instanceMap;
  static CSSStyleDeclaration *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class StyleDeclarationInstance : public Instance {
  public:
    DEFINE_STATIC_OBJECT_PROPERTY(CSSStyleDeclaration, 3, setProperty, removeProperty, getPropertyValue)

    StyleDeclarationInstance() = delete;
    StyleDeclarationInstance(CSSStyleDeclaration *cssStyleDeclaration,
                             JSEventTarget::EventTargetInstance *ownerEventTarget);
    ~StyleDeclarationInstance();

    static JSValueRef setProperty(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);
    static JSValueRef removeProperty(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
    static JSValueRef getPropertyValue(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                       size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    bool internalSetProperty(std::string &name, JSValueRef value, JSValueRef *exception);
    void internalRemoveProperty(JSStringRef name, JSValueRef *exception);
    JSValueRef internalGetPropertyValue(JSStringRef name, JSValueRef *exception);

  private:
    std::unordered_map<std::string, JSStringRef> properties;
    const JSEventTarget::EventTargetInstance *ownerEventTarget;

    JSFunctionHolder m_setProperty{context, object, this, "setProperty", setProperty};
    JSFunctionHolder m_getPropertyValue{context, object, this, "getPropertyValue", getPropertyValue};
    JSFunctionHolder m_removeProperty{context, object, this, "removeProperty", removeProperty};
  };

protected:
  CSSStyleDeclaration() = delete;
  ~CSSStyleDeclaration();
  explicit CSSStyleDeclaration(JSContext *context);
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_STYLE_DECLARATION_H
