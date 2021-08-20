/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_JS_BINDINGS_WINDOW_H_
#define KRAKEN_JS_BINDINGS_WINDOW_H_

#include "bindings/jsc/DOM/event_target.h"
#include "bindings/jsc/js_context_internal.h"
#include "location.h"
#include "history.h"

#include <array>
#include <memory>

#define JSWindowName "Window"

namespace kraken::binding::jsc {

struct NativeWindow;

class JSWindow : public JSEventTarget {
public:
  static std::unordered_map<JSContext *, JSWindow *> instanceMap;
  static JSWindow *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;
  static JSValueRef open(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef scrollTo(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef postMessage(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);


private:
  JSWindow(JSContext *context) : JSEventTarget(context, JSWindowName){};
  ~JSWindow();

  JSFunctionHolder m_open{context, prototypeObject, this, "open", open};
  JSFunctionHolder m_scroll{context, prototypeObject, this, "scroll", scrollTo};
  JSFunctionHolder m_scrollTo{context, prototypeObject, this, "scrollTo", scrollTo};
  JSFunctionHolder m_scrollBy{context, prototypeObject, this, "scrollBy", scrollBy};
  JSFunctionHolder m_postMessage{context, prototypeObject, this, "postMessage", postMessage};
};

class WindowInstance : public EventTargetInstance {
public:
  DEFINE_OBJECT_PROPERTY(Window, 8, devicePixelRatio, colorScheme, __location__, window, history, parent,  scrollX, scrollY);
  DEFINE_PROTOTYPE_OBJECT_PROPERTY(Window, 5, open, scroll, scrollBy, scrollTo, postMessage);

  WindowInstance() = delete;
  explicit WindowInstance(JSWindow *window);
  ~WindowInstance();

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

  NativeWindow *nativeWindow;

  JSHistory *history_;

private:
  JSLocation *location_;
};

using Window_Open = void (*)(NativeWindow *nativeWindow, NativeString *url);
using Window_ScrollX = double (*)(NativeWindow *nativeWindow);
using Window_ScrollY = double (*)(NativeWindow *nativeWindow);
using Window_ScrollTo = void (*)(NativeWindow *nativeWindow, int32_t x, int32_t y);
using Window_ScrollBy = void (*)(NativeWindow *nativeWindow, int32_t x, int32_t y);

struct NativeWindow {
  NativeWindow() = delete;
  NativeWindow(NativeEventTarget *nativeEventTarget) : nativeEventTarget(nativeEventTarget){};

  NativeEventTarget *nativeEventTarget;

  Window_Open open{nullptr};
  Window_ScrollX scrollX{nullptr};
  Window_ScrollY scrollY{nullptr};
  Window_ScrollTo scrollTo{nullptr};
  Window_ScrollBy scrollBy{nullptr};
};

void bindWindow(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif
