/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_IMAGE_ELEMENT_H
#define BRIDGE_IMAGE_ELEMENT_H

#include "bindings/qjs/dom/element.h"

namespace webf::binding::qjs {

void bindImageElement(ExecutionContext* context);

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
  DEFINE_PROTOTYPE_PROPERTY(scaling);
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

}  // namespace webf::binding::qjs

#endif  // BRIDGE_IMAGE_ELEMENTT_H
