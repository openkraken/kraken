/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SCREEN_H
#define KRAKENBRIDGE_SCREEN_H

#include "core/dom/events/event_target.h"

namespace kraken {

class Window;

struct NativeScreen {};

class Screen : public EventTargetWithInlineData {
  DEFINE_WRAPPERTYPEINFO();
 public:
  using ImplType = Screen*;
  explicit Screen(Window* window, NativeBindingObject* binding_object);

 private:
};

}

#endif  // KRAKENBRIDGE_SCREEN_H
