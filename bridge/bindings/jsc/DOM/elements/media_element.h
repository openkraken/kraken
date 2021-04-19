/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MEDIA_ELEMENT_H
#define KRAKENBRIDGE_MEDIA_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

struct NativeMediaElement;

using Play = void (*)(NativeMediaElement *mediaElement);
using Pause = void (*)(NativeMediaElement *mediaElement);
using FastSeek = void (*)(NativeMediaElement *mediaElement, double duration);

class JSMediaElement : public JSElement {
public:
  static std::unordered_map<JSContext *, JSMediaElement *> instanceMap;
  OBJECT_INSTANCE(JSMediaElement)
  class MediaElementInstance : public ElementInstance {
  public:
    DEFINE_OBJECT_PROPERTY(MediaElement, 4, src, autoPlay, loop, currentSrc);
    DEFINE_PROTOTYPE_OBJECT_PROPERTY(MediaElement, 3, play, pause, fastSeek);

    MediaElementInstance() = delete;
    explicit MediaElementInstance(JSMediaElement *jsMediaElement, const char *tagName);
    ~MediaElementInstance();
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeMediaElement *nativeMediaElement;

  private:
    JSStringRef _src{JSStringCreateWithUTF8CString("")};
    bool _autoPlay{false};
    bool _loop{false};
  };

protected:
  JSMediaElement() = delete;
  ~JSMediaElement();
  explicit JSMediaElement(JSContext *context);

  static JSValueRef play(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef pause(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                          const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef fastSeek(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);

  JSFunctionHolder m_play{context, prototypeObject, this, "play", play};
  JSFunctionHolder m_pause{context, prototypeObject, this, "pause", pause};
  JSFunctionHolder m_fastSeek{context, prototypeObject, this, "fastSeek", fastSeek};
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
