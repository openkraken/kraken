/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_IMAGE_ELEMENT_H
#define KRAKENBRIDGE_IMAGE_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {


void bindImageElement(std::unique_ptr<JSContext> &context);


class ImageElement : public Element {
public:
  ImageElement() = delete;
  explicit ImageElement(JSContext *context);
  JSValue instanceConstructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  OBJECT_INSTANCE(ImageElement);
private:

};
class ImageElementInstance : public ElementInstance {
public:
  ImageElementInstance() = delete;
  explicit ImageElementInstance(ImageElement *element);
  bool dispatchEvent(EventInstance *event);
  void protectImageInstance();
  void freeImageInstance();
private:
  DEFINE_HOST_CLASS_PROPERTY(6, width, height, naturalWidth, naturalHeight, src, loading)
};

}

#endif //KRAKENBRIDGE_IMAGE_ELEMENTT_H
