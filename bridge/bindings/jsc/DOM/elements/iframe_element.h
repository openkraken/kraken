/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_IFRAME_ELEMENT_H
#define KRAKENBRIDGE_IFRAME_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

struct NativeIframeElement;

class JSIframeElement : public JSElement {
public:
  static std::unordered_map<JSContext *, JSIframeElement *> instanceMap;
  OBJECT_INSTANCE(JSIframeElement)
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class IframeElementInstance : public ElementInstance {
  public:
    DEFINE_OBJECT_PROPERTY(IFrameElement, 3, width, height, contentWindow)
    DEFINE_STATIC_OBJECT_PROPERTY(IFrameElement, 1, postMessage)

    static JSValueRef postMessage(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

    IframeElementInstance() = delete;
    ~IframeElementInstance();
    explicit IframeElementInstance(JSIframeElement *jsIframeElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeIframeElement *nativeIframeElement;

  private:
    double _width;
    double _height;

    JSFunctionHolder m_postMessage{context, object, this, "postMessage", postMessage};
  };
protected:
  JSIframeElement() = delete;
  explicit JSIframeElement(JSContext *context);
  ~JSIframeElement();
};

using IframePostMessage = void (*)(NativeIframeElement *nativePtr, NativeString *message);

struct NativeIframeElement {
  NativeIframeElement() = delete;
  explicit NativeIframeElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;

  IframePostMessage postMessage;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_IFRAME_ELEMENT_H
