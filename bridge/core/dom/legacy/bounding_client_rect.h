/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_LEGACY_BOUNDING_CLIENT_RECT_H_
#define KRAKENBRIDGE_CORE_DOM_LEGACY_BOUNDING_CLIENT_RECT_H_

#include "bindings/qjs/script_wrappable.h"

namespace kraken {

class ExecutingContext;

struct NativeBoundingClientRect {
  double x;
  double y;
  double width;
  double height;
  double top;
  double right;
  double bottom;
  double left;
};

class BoundingClientRect : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();
 public:
  BoundingClientRect() = delete;
  static BoundingClientRect* Create(ExecutingContext* context, NativeBoundingClientRect* native_bounding_client_rect);
  explicit BoundingClientRect(ExecutingContext* context, NativeBoundingClientRect* nativeBoundingClientRect);

  FORCE_INLINE const char* GetHumanReadableName() const override { return "BoundingClientRect"; }
  void Trace(GCVisitor* visitor) const override;

 private:
  double x_;
  double y_;
  double width_;
  double height_;
  double top_;
  double right_;
  double bottom_;
  double left_;
};

}

#endif  // KRAKENBRIDGE_CORE_DOM_LEGACY_BOUNDING_CLIENT_RECT_H_
