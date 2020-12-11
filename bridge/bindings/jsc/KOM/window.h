/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_JS_BINDINGS_WINDOW_H_
#define KRAKEN_JS_BINDINGS_WINDOW_H_

#include "bindings/jsc/DOM/event_target.h"
#include "bindings/jsc/js_context.h"
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

class WindowInstance : public JSEventTarget::EventTargetInstance {
public:
  enum class WindowProperty {
    kDevicePixelRatio,
    kColorScheme,
    kLocation,
    kWindow,
    kHistory,
    kParent,
    kScroll,
    kScrollBy,
    kScrollTo,
    kScrollX,
    kScrollY
  };

  static std::vector<JSStringRef> &getWindowPropertyNames();
  static std::unordered_map<std::string, WindowProperty> &getWindowPropertyMap();

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
