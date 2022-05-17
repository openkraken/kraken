/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_
#define KRAKENBRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_

#include "bindings/qjs/cppgc/garbage_collected.h"
#include "frame_request_callback_collection.h"

namespace kraken {

class ScriptAnimationController {
 public:
  ScriptAnimationController() = delete;

  // Animation frame callbacks are used for requestAnimationFrame().
  uint32_t RegisterFrameCallback(const std::shared_ptr<FrameCallback>& callback);
  void CancelFrameCallback(uint32_t callbackId);

 private:
  FrameRequestCallbackCollection frame_request_callback_collection_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_BOM_SCRIPT_ANIMATION_CONTROLLER_H_
