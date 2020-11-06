/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_JS_BINDINGS_WINDOW_H_
#define KRAKEN_JS_BINDINGS_WINDOW_H_

#include "bindings/jsc/js_context.h"
#include "bindings/jsc/DOM/eventTarget.h"
#include "location.h"

#include <array>
#include <memory>

#define JSWindowName "Window"

namespace kraken::binding::jsc {

class JSWindow : public JSEventTarget {
public:
  JSWindow(JSContext *context) : JSEventTarget(context, JSWindowName) {};
  ~JSWindow();

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) override;

  class WindowInstance : public EventTargetInstance {
  public:
    WindowInstance() = delete;
    explicit WindowInstance(JSWindow *window);
    ~WindowInstance();
    JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
  private:
    std::array<JSStringRef, 11> propertyNames {
        JSStringCreateWithUTF8CString("devicePixelRatio"),
        JSStringCreateWithUTF8CString("colorScheme"),
        JSStringCreateWithUTF8CString("location"),
        JSStringCreateWithUTF8CString("window"),
        JSStringCreateWithUTF8CString("history"),
        JSStringCreateWithUTF8CString("parent"),
        JSStringCreateWithUTF8CString("scroll"),
        JSStringCreateWithUTF8CString("scrollBy"),
        JSStringCreateWithUTF8CString("scrollTo"),
        JSStringCreateWithUTF8CString("scrollX"),
        JSStringCreateWithUTF8CString("scrollY"),
    };
    JSLocation *location_;
  };
};

void bindWindow(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif
