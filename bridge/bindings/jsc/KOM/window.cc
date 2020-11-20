/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "bindings/jsc/macros.h"
#include "dart_methods.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

JSWindow::WindowInstance::WindowInstance(JSWindow *window)
  : EventTargetInstance(window, WINDOW_TARGET_ID), nativeWindow(new NativeWindow(nativeEventTarget)) {
  location_ = new JSLocation(context);

  foundation::UICommandTaskMessageQueue::instance(window->context->getContextId())
    ->registerCommand(WINDOW_TARGET_ID, UI_COMMAND_INIT_WINDOW, nullptr, 0, nativeWindow);
}

JSWindow::WindowInstance::~WindowInstance() {
  for (auto &propertyName : propertyNames) {
    JSStringRelease(propertyName);
  }
  delete nativeWindow;
}

JSValueRef JSWindow::WindowInstance::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "devicePixelRatio") {
    if (getDartMethod()->devicePixelRatio == nullptr) {
      JSC_THROW_ERROR(context->context(),
                      "Failed to read devicePixelRatio: dart method (devicePixelRatio) is not register.", exception);
      return nullptr;
    }

    double devicePixelRatio = getDartMethod()->devicePixelRatio(_hostClass->contextId);
    return JSValueMakeNumber(context->context(), devicePixelRatio);
  } else if (name == "colorScheme") {
    if (getDartMethod()->platformBrightness == nullptr) {
      JSC_THROW_ERROR(context->context(),
                      "Failed to read colorScheme: dart method (platformBrightness) not register.", exception);
      return nullptr;
    }
    const NativeString *code = getDartMethod()->platformBrightness(_hostClass->contextId);
    JSStringRef resultRef = JSStringCreateWithCharacters(code->string, code->length);
    return JSValueMakeString(context->context(), resultRef);
  } else if (name == "location") {
    return location_->jsObject;
  } else if (name == "window") {
    return this->object;
  } else if (name == "history" || name == "parent") {
    // TODO: implement history API.
    return nullptr;
  } else if (name == "scroll") {
    // TODO: implement window.scroll();
  } else if (name == "scrollBy") {
    // TODO: implement window.scrollBy();
  } else if (name == "scrollTo") {
    // TODO: implement window.scrollTo();
  } else if (name == "scrollX") {
    // TODO: implement window.scrollX();
  } else if (name == "scrollY") {
    // TODO: implement window.scrollY();
  }

  return JSEventTarget::EventTargetInstance::getProperty(name, exception);
}

JSWindow::~JSWindow() {}

JSObjectRef JSWindow::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                          const JSValueRef *arguments, JSValueRef *exception) {
  auto window = new WindowInstance(this);
  return window->object;
}

JSWindow *JSWindow::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSWindow *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSWindow(context);
  }
  return instanceMap[context];
}

void bindWindow(std::unique_ptr<JSContext> &context) {
  auto window = JSWindow::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Window", window->classObject);
  auto windowInstance = window->instanceConstructor(window->ctx, window->classObject, 0, nullptr, nullptr);
  JSC_GLOBAL_SET_PROPERTY(context, "window", windowInstance);
}

} // namespace kraken::binding::jsc
