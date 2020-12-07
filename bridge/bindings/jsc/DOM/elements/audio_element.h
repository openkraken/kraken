/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_AUDIO_ELEMENT_H
#define KRAKENBRIDGE_AUDIO_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

#include "media_element.h"

namespace kraken::binding::jsc {

struct NativeAudioElement {
  NativeAudioElement() = delete;
  NativeAudioElement(NativeMediaElement *nativeMediaElement) : nativeMediaElement(nativeMediaElement){};

  NativeMediaElement *nativeMediaElement;
};

class JSAudioElement : public JSMediaElement {
public:
  static JSAudioElement *instance(JSContext *context);
  static std::unordered_map<JSContext *, JSAudioElement *> &getInstanceMap();
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class AudioElementInstance : public MediaElementInstance {
  public:
    enum class AudioElementProperty {};
    static std::vector<JSStringRef> &getAudioElementPropertyNames();
    static const std::unordered_map<std::string, AudioElementProperty> &getAudioElementPropertyMap();

    AudioElementInstance() = delete;
    explicit AudioElementInstance(JSAudioElement *jsAudioElement);
    ~AudioElementInstance();

    NativeAudioElement *nativeAudioElement;
  private:
  };
protected:
  JSAudioElement() = delete;
  ~JSAudioElement();
  explicit JSAudioElement(JSContext *context);
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_AUDIO_ELEMENT_H
