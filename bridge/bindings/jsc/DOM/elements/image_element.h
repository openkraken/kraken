/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_IMAGE_ELEMENT_H
#define KRAKENBRIDGE_IMAGE_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

struct NativeImageElement;

void bindImageElement(std::unique_ptr<JSContext> &context);

class JSImageElement : public JSElement {
public:
  static std::unordered_map<JSContext *, JSImageElement *> instanceMap;
  OBJECT_INSTANCE(JSImageElement)
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class ImageElementInstance : public ElementInstance {
  public:
    DEFINE_OBJECT_PROPERTY(ImageElement, 6, width, height, naturalWidth, naturalHeight, src, loading)

    ImageElementInstance() = delete;
    ~ImageElementInstance();
    explicit ImageElementInstance(JSImageElement *JSImageElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeImageElement *nativeImageElement;

  private:
    JSStringHolder m_src{context, ""};
    JSStringHolder m_loading{context, ""};
  };
protected:
  JSImageElement() = delete;
  explicit JSImageElement(JSContext *context);
  ~JSImageElement();
};

using GetImageWidth = double(*)(NativeImageElement *nativeImageElement);
using GetImageHeight = double(*)(NativeImageElement *nativeImageElement);
using GetImageNaturalWidth = double(*)(NativeImageElement *nativeImageElement);
using GetImageNaturalHeight = double(*)(NativeImageElement *nativeImageElement);

struct NativeImageElement {
  NativeImageElement() = delete;
  explicit NativeImageElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;

  GetImageWidth getImageWidth{nullptr};
  GetImageHeight getImageHeight{nullptr};
  GetImageNaturalWidth getImageNaturalWidth{nullptr};
  GetImageNaturalHeight getImageNaturalHeight{nullptr};
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_IMAGE_ELEMENT_H
