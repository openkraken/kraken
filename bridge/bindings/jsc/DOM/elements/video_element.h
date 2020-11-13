/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_VIDEO_ELEMENT_H
#define KRAKENBRIDGE_VIDEO_ELEMENT_H

#include "bindings/jsc/DOM/elements/media_element.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

struct NativeVideoElement {
  NativeVideoElement() = delete;
  NativeVideoElement(NativeMediaElement *nativeMediaElement) : nativeMediaElement(nativeMediaElement){};

  NativeMediaElement *nativeMediaElement;
};

class JSVideoElement : public JSMediaElement {
public:
  static JSVideoElement *instance(JSContext *context);

  JSVideoElement() = delete;
  explicit JSVideoElement(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class VideoElementInstance : public MediaElementInstance {
  public:
    enum class AudioElementProperty {};
    static std::vector<JSStringRef> &getAudioElementPropertyNames();
    static const std::unordered_map<std::string, AudioElementProperty> &getAudioElementPropertyMap();

    VideoElementInstance() = delete;
    explicit VideoElementInstance(JSVideoElement *JSVideoElement);
    ~VideoElementInstance();

    NativeVideoElement *nativeVideoElement;

  private:
  };
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_VIDEO_ELEMENT_H
