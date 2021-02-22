/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ANIMATION_PLAYER_ELEMENT_H
#define KRAKENBRIDGE_ANIMATION_PLAYER_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

struct NativeAnimationPlayerElement;

class JSAnimationPlayerElement : public JSElement {
public:
  OBJECT_INSTANCE(JSAnimationPlayerElement)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  static JSValueRef play(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);

  class AnimationPlayerElementInstance : public ElementInstance {
  public:
    DEFINE_OBJECT_PROPERTY(AnimationPlayer, 2, src, type)
    DEFINE_STATIC_OBJECT_PROPERTY(AnimationPlayer, 1, play)

    AnimationPlayerElementInstance() = delete;
    ~AnimationPlayerElementInstance();
    explicit AnimationPlayerElementInstance(JSAnimationPlayerElement *jsAnchorElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeAnimationPlayerElement *nativeAnimationPlayerElement;

  private:
    JSStringHolder m_src{context, ""};
    JSStringHolder m_type{context, ""};
    JSFunctionHolder m_play{context, object, this, "play", play};
  };
protected:
  JSAnimationPlayerElement() = delete;
  ~JSAnimationPlayerElement() override;
  static std::unordered_map<JSContext *, JSAnimationPlayerElement*> instanceMap;
  explicit JSAnimationPlayerElement(JSContext *context);
};

using PlayAnimation = void(*)(NativeAnimationPlayerElement *nativePtr, NativeString *name, double mix, double mixSeconds);

struct NativeAnimationPlayerElement {
  NativeAnimationPlayerElement() = delete;
  explicit NativeAnimationPlayerElement(NativeElement *nativeElement) : nativeElement(nativeElement) {};

  NativeElement *nativeElement;

  PlayAnimation play;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_ANIMATION_PLAYER_ELEMENT_H
