/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "bindings/jsc/DOM/document.h"
#include "bindings/jsc/macros.h"
#include "dart_methods.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

WindowInstance::WindowInstance(JSWindow *window)
  : EventTargetInstance(window, WINDOW_TARGET_ID), nativeWindow(new NativeWindow(nativeEventTarget)) {
  location_ = new JSLocation(context);

  getDartMethod()->initWindow(window->contextId, nativeWindow);
}

WindowInstance::~WindowInstance() {
  delete nativeWindow;
}

std::unordered_map<std::string, WindowInstance::WindowProperty> &WindowInstance::getWindowPropertyMap() {
  static std::unordered_map<std::string, WindowProperty> propertyMap{
    {"devicePixelRatio", WindowProperty::kDevicePixelRatio},
    {"colorScheme", WindowProperty::kColorScheme},
    {"location", WindowProperty::kLocation},
    {"window", WindowProperty::kWindow},
    {"history", WindowProperty::kHistory},
    {"parent", WindowProperty::kParent},
    {"scroll", WindowProperty::kScroll},
    {"scrollBy", WindowProperty::kScrollBy},
    {"scrollTo", WindowProperty::kScrollTo},
    {"scrollX", WindowProperty::kScrollX},
    {"scrollY", WindowProperty::kScrollY}};
  return propertyMap;
}

std::vector<JSStringRef> &WindowInstance::getWindowPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("devicePixelRatio"), JSStringCreateWithUTF8CString("colorScheme"),
    JSStringCreateWithUTF8CString("location"),         JSStringCreateWithUTF8CString("window"),
    JSStringCreateWithUTF8CString("history"),          JSStringCreateWithUTF8CString("parent"),
    JSStringCreateWithUTF8CString("scroll"),           JSStringCreateWithUTF8CString("scrollBy"),
    JSStringCreateWithUTF8CString("scrollTo"),         JSStringCreateWithUTF8CString("scrollX"),
    JSStringCreateWithUTF8CString("scrollY"),
  };
  return propertyNames;
}

JSValueRef WindowInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getWindowPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    switch (property) {
    case WindowProperty::kDevicePixelRatio: {
      if (getDartMethod()->devicePixelRatio == nullptr) {
        JSC_THROW_ERROR(context->context(),
                        "Failed to read devicePixelRatio: dart method (devicePixelRatio) is not register.", exception);
        return nullptr;
      }

      double devicePixelRatio = getDartMethod()->devicePixelRatio(_hostClass->contextId);
      return JSValueMakeNumber(context->context(), devicePixelRatio);
    }
    case WindowProperty::kColorScheme: {
      if (getDartMethod()->platformBrightness == nullptr) {
        JSC_THROW_ERROR(context->context(),
                        "Failed to read colorScheme: dart method (platformBrightness) not register.", exception);
        return nullptr;
      }
      const NativeString *code = getDartMethod()->platformBrightness(_hostClass->contextId);
      JSStringRef resultRef = JSStringCreateWithCharacters(code->string, code->length);
      return JSValueMakeString(context->context(), resultRef);
    }
    case WindowProperty::kLocation:
      return location_->jsObject;
    case WindowProperty::kParent:
    case WindowProperty::kWindow:
      return this->object;
    case WindowProperty::kHistory: {
      JSStringRef key = JSStringCreateWithUTF8CString("__history__");
      JSValueRef history = JSObjectGetProperty(_hostClass->ctx, _hostClass->context->global(), key, exception);
      JSStringRelease(key);
      return history;
    }
    case WindowProperty::kScrollTo:
    case WindowProperty::kScroll:
      return m_scroll.function();
    case WindowProperty::kScrollBy:
      return m_scrollBy.function();
    case WindowProperty::kScrollX: {
      getDartMethod()->requestUpdateFrame();
      auto document = DocumentInstance::instance(_hostClass->context);
      assert_m( document->body->nativeElement->getScrollLeft != nullptr, "Failed to execute getScrollLeft(): dart method is nullptr.");
      return JSValueMakeNumber(_hostClass->ctx,
                               document->body->nativeElement->getScrollLeft(document->body->nativeElement));
    }
    case WindowProperty::kScrollY: {
      getDartMethod()->requestUpdateFrame();
      auto document = DocumentInstance::instance(_hostClass->context);
      assert_m( document->body->nativeElement->getScrollTop != nullptr, "Failed to execute getScrollTop(): dart method is nullptr.");
      return JSValueMakeNumber(_hostClass->ctx,
                               document->body->nativeElement->getScrollTop(document->body->nativeElement));
    }
    }
  }

  JSValueRef eventTargetRet = JSEventTarget::EventTargetInstance::getProperty(name, exception);
  if (eventTargetRet != nullptr) return eventTargetRet;

  JSStringRef keyStringRef = JSStringCreateWithUTF8CString(name.c_str());
  return JSObjectGetProperty(_hostClass->ctx, _hostClass->context->global(), keyStringRef, exception);
}

void WindowInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventTargetInstance::getPropertyNames(accumulator);

  for (auto &property : getWindowPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSValueRef WindowInstance::scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef xValueRef = arguments[0];
  const JSValueRef yValueRef = arguments[1];

  double x = 0.0;
  double y = 0.0;

  if (argumentCount > 0 && JSValueIsNumber(ctx, xValueRef)) {
    x = JSValueToNumber(ctx, xValueRef, exception);
  }

  if (argumentCount > 1 && JSValueIsNumber(ctx, yValueRef)) {
    y = JSValueToNumber(ctx, yValueRef, exception);
  }

  auto window = reinterpret_cast<WindowInstance *>(JSObjectGetPrivate(function));
  getDartMethod()->requestUpdateFrame();
  auto document = DocumentInstance::instance(window->context);
  assert_m( document->body->nativeElement->scroll != nullptr, "Failed to execute scroll(): dart method is nullptr.");
  document->body->nativeElement->scroll(document->body->nativeElement, x, y);

  return nullptr;
}

JSValueRef WindowInstance::scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef xValueRef = arguments[0];
  const JSValueRef yValueRef = arguments[1];

  double x = 0.0;
  double y = 0.0;

  if (argumentCount > 0 && JSValueIsNumber(ctx, xValueRef)) {
    x = JSValueToNumber(ctx, xValueRef, exception);
  }

  if (argumentCount > 1 && JSValueIsNumber(ctx, yValueRef)) {
    y = JSValueToNumber(ctx, yValueRef, exception);
  }

  auto window = reinterpret_cast<WindowInstance *>(JSObjectGetPrivate(function));
  getDartMethod()->requestUpdateFrame();
  auto document = DocumentInstance::instance(window->context);
  assert_m( document->body->nativeElement->scrollBy != nullptr, "Failed to execute scroll(): dart method is nullptr.");
  document->body->nativeElement->scrollBy(document->body->nativeElement, x, y);

  return nullptr;
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
