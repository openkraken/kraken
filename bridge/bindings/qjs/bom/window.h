/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WINDOW_H
#define KRAKENBRIDGE_WINDOW_H

#include "bindings/qjs/js_context.h"
#include "bindings/qjs/dom/event_target.h"
#include "bindings/qjs/bom/location.h"
#include "bindings/qjs/bom/history.h"

namespace kraken::binding::qjs {

void bindWindow(std::unique_ptr<JSContext> &context);

class WindowInstance;

class Window : public EventTarget {
public:
  static JSClassID kWindowClassId;

  static JSClassID classId();

  static JSValue open(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue scrollTo(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue scrollBy(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

  Window() = delete;
  explicit Window(JSContext *context);

  OBJECT_INSTANCE(Window);
private:

  ObjectFunction m_open{m_context, m_prototypeObject, "open", open, 1};
  ObjectFunction m_scroll{m_context, m_prototypeObject, "scroll", scrollTo, 2};
  ObjectFunction m_scrollTo{m_context, m_prototypeObject, "scrollTo", scrollTo, 2};
  ObjectFunction m_scrollBy{m_context, m_prototypeObject, "scrollBy", scrollBy, 2};

  DEFINE_HOST_CLASS_PROTOTYPE_PROPERTY(8, devicePixelRatio, colorScheme, __location__, window, history, parent,  scrollX, scrollY);
  friend WindowInstance;
};

class WindowInstance : public EventTargetInstance {
public:
  WindowInstance() = delete;
  explicit WindowInstance(Window *window);
  ~WindowInstance() {
    JS_FreeValue(m_ctx, m_location->jsObject);
    JS_FreeValue(m_ctx, m_history->jsObject);
  }
private:

  Location *m_location{nullptr};
  History *m_history{nullptr};
  friend Window;
  friend JSContext;
};


}

#endif // KRAKENBRIDGE_WINDOW_H
