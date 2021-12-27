/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WINDOW_H
#define KRAKENBRIDGE_WINDOW_H

#include "bindings/qjs/bom/location.h"
#include "bindings/qjs/dom/event_target.h"
#include "bindings/qjs/executing_context.h"

namespace kraken::binding::qjs {

void bindWindow(std::unique_ptr<ExecutionContext>& context);

class WindowInstance;

class Window : public EventTarget {
 public:
  static JSClassID kWindowClassId;

  static JSClassID classId();

  static JSValue open(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue scrollTo(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue scrollBy(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue postMessage(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue requestAnimationFrame(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue cancelAnimationFrame(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  Window() = delete;
  explicit Window(ExecutionContext* context);

  OBJECT_INSTANCE(Window);

 private:
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

  DEFINE_PROTOTYPE_FUNCTION(open, 1);
  // ScrollTo is same as scroll which reuse scroll functions. Macro expand is not support here.
  ObjectFunction m_scroll{m_context, m_prototypeObject, "scroll", scrollTo, 2};
  DEFINE_PROTOTYPE_FUNCTION(scrollTo, 2);
  DEFINE_PROTOTYPE_FUNCTION(scrollBy, 2);
  DEFINE_PROTOTYPE_FUNCTION(postMessage, 3);
  DEFINE_PROTOTYPE_FUNCTION(requestAnimationFrame, 1);
  DEFINE_PROTOTYPE_FUNCTION(cancelAnimationFrame, 1);

  friend WindowInstance;
};

class WindowInstance : public EventTargetInstance {
 public:
  WindowInstance() = delete;
  explicit WindowInstance(Window* window);
  ~WindowInstance() {}

 private:
  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;
  DocumentInstance* document();

  ObjectProperty m_location{m_context, jsObject, "m_location", (new Location(m_context))->jsObject};
  JSValue onerror{JS_NULL};
  friend Window;
  friend ExecutionContext;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_WINDOW_H
