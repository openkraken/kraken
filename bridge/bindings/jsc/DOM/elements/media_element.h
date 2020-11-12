/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MEDIA_ELEMENT_H
#define KRAKENBRIDGE_MEDIA_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

using Play = void(*)(int32_t contextId, int64_t targetId);
using Pause = void(*)(int32_t contextId, int64_t targetId);
using FastSeek = void(*)(int32_t contextId, int64_t targetId);

class JSMediaElement : public JSElement {
public:
  static JSMediaElement *instance(JSContext *context);

  JSMediaElement() = delete;
  explicit JSMediaElement(JSContext *context);

  class MediaElementInstance : public ElementInstance {
  public:
    enum class MediaElementProperty {
      kSrc,
      kAutoPlay,
      kLoop,
      kPlay,
      kPause,
      kFastSeek,
      kCurrentSrc,
      kCurrentTime
    };

    static std::vector<JSStringRef> &getMediaElementPropertyNames();
    static const std::unordered_map<std::string, MediaElementProperty> &getMediaElementPropertyMap();

    MediaElementInstance() = delete;
    explicit MediaElementInstance(JSMediaElement *jsMediaElement, const char* tagName);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

  private:
    JSStringRef _src;
    bool _autoPlay {false};
    bool _loop {false};
    JSObjectRef _play;
    JSObjectRef _pause;
    JSObjectRef _fastSeek;
  };
};

struct NativeMediaElement {
  NativeMediaElement() = delete;
  NativeMediaElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;

  Play play;
  Pause pause;
  FastSeek fastSeek;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_MEDIA_ELEMENT_H
