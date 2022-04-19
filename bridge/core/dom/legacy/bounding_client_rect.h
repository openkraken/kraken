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

  void Trace(GCVisitor* visitor) const override;

  double x() const { return x_; }
  double y() const { return y_; }
  double width() const { return width_; }
  double height() const { return height_; }
  double top() const { return top_; }
  double right() const { return right_; }
  double bottom() const { return bottom_; }
  double left() const { return left_; }

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

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_LEGACY_BOUNDING_CLIENT_RECT_H_
