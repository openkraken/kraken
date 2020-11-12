/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ANIMATION_PLAYER_ELEMENT_H
#define KRAKENBRIDGE_ANIMATION_PLAYER_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

class JSAnimationPlayerElement : public JSElement {
public:
  static JSAnimationPlayerElement *instance(JSContext *context);

  JSAnimationPlayerElement() = delete;
  explicit JSAnimationPlayerElement(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class AnimationPlayerElementInstance : public ElementInstance {
  public:
    enum class AnimationPlayerProperty {
      kSrc,
      kType
    };

    static std::vector<JSStringRef> &getAnimationPlayerElementPropertyNames();
    static const std::unordered_map<std::string, AnimationPlayerProperty> &getAnimationPlayerElementPropertyMap();

    AnimationPlayerElementInstance() = delete;
    explicit AnimationPlayerElementInstance(JSAnimationPlayerElement *jsAnchorElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

  private:
    JSStringRef _src;
    JSStringRef _type;
  };
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_ANIMATION_PLAYER_ELEMENT_H
