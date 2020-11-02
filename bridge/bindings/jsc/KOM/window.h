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
#define WINDOW_TARGET_ID -2

namespace kraken::binding::jsc {

class JSWindow : public JSEventTarget {
public:
  JSWindow(JSContext *context) : JSEventTarget(context, JSWindowName) {};
  ~JSWindow();

  JSObjectRef constructInstance(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) override;

  class WindowInstance : public EventTargetInstance {
  public:
    WindowInstance() = delete;
    explicit WindowInstance(JSWindow *window);
    ~WindowInstance();
    JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
  private:
    std::array<JSStringRef, 3> propertyNames {
        JSStringCreateWithUTF8CString("devicePixelRatio"),
        JSStringCreateWithUTF8CString("colorScheme"),
        JSStringCreateWithUTF8CString("location"),
    };
    JSLocation *location_;
  };

//  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
};

void bindWindow(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif
