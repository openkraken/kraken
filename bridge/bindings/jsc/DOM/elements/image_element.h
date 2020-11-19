/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_IMAGE_ELEMENT_H
#define KRAKENBRIDGE_IMAGE_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

struct NativeImageElement;

class JSImageElement : public JSElement {
public:
  static JSImageElement *instance(JSContext *context);
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class ImageElementInstance : public ElementInstance {
  public:
    enum class ImageProperty {
      kWidth, kHeight,
      kSrc,
      kLoading
    };

    static std::vector<JSStringRef> &getImageElementPropertyNames();
    static const std::unordered_map<std::string, ImageProperty> &getImageElementPropertyMap();

    ImageElementInstance() = delete;
    ~ImageElementInstance();
    explicit ImageElementInstance(JSImageElement *JSImageElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeImageElement *nativeImageElement;

  private:
    double _width;
    double _height;

    JSStringRef _src{JSStringCreateWithUTF8CString("")};
    JSStringRef _loading{JSStringCreateWithUTF8CString("")};
  };
protected:
  JSImageElement() = delete;
  explicit JSImageElement(JSContext *context);
};

struct NativeImageElement {
  NativeImageElement() = delete;
  explicit NativeImageElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_IMAGE_ELEMENT_H
