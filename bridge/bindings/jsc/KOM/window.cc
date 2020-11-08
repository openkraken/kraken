/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "bindings/jsc/macros.h"
#include "dart_methods.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

JSWindow::WindowInstance::WindowInstance(JSWindow *window) : EventTargetInstance(window, WINDOW_TARGET_ID) {
  location_ = new JSLocation(_hostClass->context);

  foundation::UICommandTaskMessageQueue::instance(window->context->getContextId())
    ->registerCommand(WINDOW_TARGET_ID, UICommandType::initWindow, nullptr, 0, nativeEventTarget);
}

JSWindow::WindowInstance::~WindowInstance() {
  for (auto &propertyName : propertyNames) {
    JSStringRelease(propertyName);
  }
}

JSValueRef JSWindow::WindowInstance::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  JSValueRef result = EventTargetInstance::getProperty(nameRef, exception);
  if (result != nullptr) return result;

  std::string name = JSStringToStdString(nameRef);

  if (name == "devicePixelRatio") {
    if (getDartMethod()->devicePixelRatio == nullptr) {
      JSC_THROW_ERROR(_hostClass->context->context(),
                      "Failed to read devicePixelRatio: dart method (devicePixelRatio) is not register.", exception);
      return nullptr;
    }

    double devicePixelRatio = getDartMethod()->devicePixelRatio(_hostClass->contextId);
    return JSValueMakeNumber(_hostClass->context->context(), devicePixelRatio);
  } else if (name == "colorScheme") {
    if (getDartMethod()->platformBrightness == nullptr) {
      JSC_THROW_ERROR(_hostClass->context->context(),
                      "Failed to read colorScheme: dart method (platformBrightness) not register.", exception);
      return nullptr;
    }
    const NativeString *code = getDartMethod()->platformBrightness(_hostClass->contextId);
    JSStringRef resultRef = JSStringCreateWithCharacters(code->string, code->length);
    return JSValueMakeString(_hostClass->context->context(), resultRef);
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

  return nullptr;
}

JSWindow::~JSWindow() {}

JSObjectRef JSWindow::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                        const JSValueRef *arguments, JSValueRef *exception) {
  auto window = new WindowInstance(this);
  return window->object;
}

void bindWindow(std::unique_ptr<JSContext> &context) {
  auto window = new JSWindow(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Window", window->classObject);
  auto windowInstance = window->instanceConstructor(window->ctx, window->classObject, 0, nullptr, nullptr);
  JSC_GLOBAL_SET_PROPERTY(context, "window", windowInstance);
}

} // namespace kraken::binding::jsc
