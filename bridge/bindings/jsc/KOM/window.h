/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_JS_BINDINGS_WINDOW_H_
#define KRAKEN_JS_BINDINGS_WINDOW_H_

#include "bindings/jsc/DOM/event_target.h"
#include "bindings/jsc/js_context_internal.h"
#include "location.h"

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

private:
  JSWindow(JSContext *context) : JSEventTarget(context, JSWindowName){};
  ~JSWindow();
};

class WindowInstance : public EventTargetInstance {
public:
  DEFINE_OBJECT_PROPERTY(Window, 11, devicePixelRatio, colorScheme, __location__, window, history, parent, scroll,
                         scrollBy, scrollTo, scrollX, scrollY)

  WindowInstance() = delete;
  explicit WindowInstance(JSWindow *window);
  ~WindowInstance();

  static JSValueRef scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

  NativeWindow *nativeWindow;

private:
  JSLocation *location_;

  JSFunctionHolder m_scroll{context, this, "scroll", scroll};
  JSFunctionHolder m_scrollBy{context, this, "scrollBy", scrollBy};
};

struct NativeWindow {
  NativeWindow() = delete;
  NativeWindow(NativeEventTarget *nativeEventTarget) : nativeEventTarget(nativeEventTarget){};

  NativeEventTarget *nativeEventTarget;
};

void bindWindow(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif
