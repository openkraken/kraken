/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WINDOW_H
#define KRAKENBRIDGE_WINDOW_H

#include "bindings/qjs/wrapper_type_info.h"
#include "core/dom/events/event_target.h"

namespace kraken {

class Window : public EventTargetWithInlineData {
 public:
  Window() = delete;
  Window(ExecutingContext* context);

  //  DEFINE_FUNCTION(open);
  //  DEFINE_FUNCTION(scrollTo);
  //  DEFINE_FUNCTION(scrollBy);
  //  DEFINE_FUNCTION(postMessage);
  //  DEFINE_FUNCTION(requestAnimationFrame);
  //  DEFINE_FUNCTION(cancelAnimationFrame);
  //
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(devicePixelRatio);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(colorScheme);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(__location__);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(location);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(window);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(parent);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(scrollX);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(scrollY);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(self);
  //  DEFINE_PROTOTYPE_PROPERTY(onerror);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_WINDOW_H
