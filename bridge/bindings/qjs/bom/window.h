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
  ObjectFunction m_open{m_context, m_prototypeObject, "open", open, 1};
  ObjectFunction m_scroll{m_context, m_prototypeObject, "scroll", scrollTo, 2};
  ObjectFunction m_scrollTo{m_context, m_prototypeObject, "scrollTo", scrollTo, 2};
  ObjectFunction m_scrollBy{m_context, m_prototypeObject, "scrollBy", scrollBy, 2};
  ObjectFunction m_postMessage{m_context, m_prototypeObject, "postMessage", postMessage, 3};

  DEFINE_HOST_CLASS_PROTOTYPE_PROPERTY(10, devicePixelRatio, colorScheme, __location__, location, window, parent, scrollX, scrollY, onerror, self);
  friend WindowInstance;
};

class WindowInstance : public EventTargetInstance {
 public:
  WindowInstance() = delete;
  explicit WindowInstance(Window* window);
  ~WindowInstance() {}

 private:
  void gcMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;

  ObjectProperty m_location{m_context, instanceObject, "m_location", (new Location(m_context))->jsObject};
  ObjectProperty m_onerror{m_context, instanceObject, "m_onerror", JS_NULL};
  JSValue onerror{JS_NULL};
  friend Window;
  friend JSContext;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_WINDOW_H
