/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_IMAGE_ELEMENT_H
#define KRAKENBRIDGE_IMAGE_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {

void bindImageElement(std::unique_ptr<JSContext>& context);

class ImageElementInstance;
class ImageElement : public Element {
 public:
  ImageElement() = delete;
  explicit ImageElement(JSContext* context);
  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  OBJECT_INSTANCE(ImageElement);
 private:
  DEFINE_HOST_CLASS_PROTOTYPE_GETTER_PROPERTY(2, naturalWidth, naturalHeight)
  DEFINE_HOST_CLASS_PROTOTYPE_PROPERTY(4, width, height,  src, loading)
  friend ImageElementInstance;
};

class ImageElementInstance : public ElementInstance {
 public:
  ImageElementInstance() = delete;
  explicit ImageElementInstance(ImageElement* element);
  bool dispatchEvent(EventInstance* event);

 private:
  bool freed{false};
  friend ImageElement;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_IMAGE_ELEMENTT_H
