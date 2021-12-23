/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_IMAGE_ELEMENT_H
#define KRAKENBRIDGE_IMAGE_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {

void bindImageElement(std::unique_ptr<ExecutionContext>& context);

class ImageElementInstance;
class ImageElement : public Element {
 public:
  ImageElement() = delete;
  explicit ImageElement(ExecutionContext* context);
  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  OBJECT_INSTANCE(ImageElement);

 private:
  DEFINE_PROTOTYPE_READONLY_PROPERTY(naturalWidth);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(naturalHeight);

  DEFINE_PROTOTYPE_PROPERTY(width);
  DEFINE_PROTOTYPE_PROPERTY(height);
  DEFINE_PROTOTYPE_PROPERTY(src);
  DEFINE_PROTOTYPE_PROPERTY(loading);
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
