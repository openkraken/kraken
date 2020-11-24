/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MEDIA_ELEMENT_H
#define KRAKENBRIDGE_MEDIA_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

struct NativeMediaElement;

using Play = void (*)(NativeMediaElement *mediaElement);
using Pause = void (*)(NativeMediaElement *mediaElement);
using FastSeek = void (*)(NativeMediaElement *mediaElement, double duration);

class JSMediaElement : public JSElement {
public:
  static JSMediaElement *instance(JSContext *context);
  class MediaElementInstance : public ElementInstance {
  public:
    enum class MediaElementProperty { kSrc, kAutoPlay, kLoop, kPlay, kPause, kFastSeek, kCurrentSrc };

    static std::vector<JSStringRef> &getMediaElementPropertyNames();
    static const std::unordered_map<std::string, MediaElementProperty> &getMediaElementPropertyMap();

    static JSValueRef play(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);

    static JSValueRef pause(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception);

    static JSValueRef fastSeek(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);

    MediaElementInstance() = delete;
    explicit MediaElementInstance(JSMediaElement *jsMediaElement, const char *tagName);
    ~MediaElementInstance();
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeMediaElement *nativeMediaElement;

  private:
    JSStringRef _src{JSStringCreateWithUTF8CString("")};
    bool _autoPlay{false};
    bool _loop{false};
    JSFunctionHolder m_play{context, this, "play", play};
    JSFunctionHolder m_pause{context, this, "pause", pause};
    JSFunctionHolder m_fastSeek{context, this, "fastSeek", fastSeek};
  };

protected:
  JSMediaElement() = delete;
  explicit JSMediaElement(JSContext *context);
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
