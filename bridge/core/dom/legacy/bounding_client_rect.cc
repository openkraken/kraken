/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "bounding_client_rect.h"
#include "core/executing_context.h"

namespace kraken {

BoundingClientRect* BoundingClientRect::Create(ExecutingContext* context,
                                               NativeBoundingClientRect* native_bounding_client_rect) {
  return MakeGarbageCollected<BoundingClientRect>(context, native_bounding_client_rect);
}

BoundingClientRect::BoundingClientRect(ExecutingContext* context, NativeBoundingClientRect* nativeBoundingClientRect)
    : ScriptWrappable(context->ctx()),
      x_(nativeBoundingClientRect->x),
      y_(nativeBoundingClientRect->y),
      width_(nativeBoundingClientRect->width),
      height_(nativeBoundingClientRect->height),
      top_(nativeBoundingClientRect->top),
      right_(nativeBoundingClientRect->right),
      left_(nativeBoundingClientRect->left),
      bottom_(nativeBoundingClientRect->bottom) {}

void BoundingClientRect::Trace(GCVisitor* visitor) const {}

}  // namespace kraken
