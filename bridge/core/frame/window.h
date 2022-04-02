/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WINDOW_H
#define KRAKENBRIDGE_WINDOW_H

#include "bindings/qjs/bom/location.h"
#include "bindings/qjs/dom/event_target.h"
#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/wrapper_type_info.h"

namespace kraken {

void bindWindow(ExecutionContext* context);

class Window : public EventTarget {
 public:
  Window();

  static JSClassID classId;
  static Window* create(JSContext* ctx);

  DEFINE_FUNCTION(open);
  DEFINE_FUNCTION(scrollTo);
  DEFINE_FUNCTION(scrollBy);
  DEFINE_FUNCTION(postMessage);
  DEFINE_FUNCTION(requestAnimationFrame);
  DEFINE_FUNCTION(cancelAnimationFrame);

  DEFINE_PROTOTYPE_READONLY_PROPERTY(devicePixelRatio);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(colorScheme);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(__location__);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(location);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(window);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(parent);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(scrollX);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(scrollY);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(self);

  DEFINE_PROTOTYPE_PROPERTY(onerror);

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;

 private:
  Document* document();

  Location* m_location{nullptr};
  JSValue onerror{JS_NULL};
  friend ExecutionContext;
};

auto windowCreator =
    [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags)
    -> JSValue {
  auto* window = Window::create(ctx);
  return window->toQuickJS();
};

const WrapperTypeInfo windowTypeInfo = {"Window", &eventTargetTypeInfo, windowCreator};

}  // namespace kraken

#endif  // KRAKENBRIDGE_WINDOW_H
