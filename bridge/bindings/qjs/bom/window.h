/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WINDOW_H
#define KRAKENBRIDGE_WINDOW_H

#include "bindings/qjs/bom/location.h"
#include "bindings/qjs/dom/event_target.h"
#include "bindings/qjs/js_context.h"

namespace kraken::binding::qjs {

void bindWindow(std::unique_ptr<JSContext>& context);

class WindowInstance;

class Window : public EventTarget {
 public:
  static JSClassID kWindowClassId;

  static JSClassID classId();

  static JSValue open(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue scrollTo(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue scrollBy(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue postMessage(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  Window() = delete;
  explicit Window(JSContext* context);

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

  friend WindowInstance;
};

class WindowInstance : public EventTargetInstance {
 public:
  WindowInstance() = delete;
  explicit WindowInstance(Window* window);
  ~WindowInstance() {}

 private:
  void gcMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;

  ObjectProperty m_location{m_context, jsObject, "m_location", (new Location(m_context))->jsObject};
  ObjectProperty m_onerror{m_context, jsObject, "m_onerror", JS_NULL};
  JSValue onerror{JS_NULL};
  friend Window;
  friend JSContext;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_WINDOW_H
