/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "bindings/jsc/DOM/document.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

WindowInstance::WindowInstance(JSWindow *window)
  : EventTargetInstance(window, WINDOW_TARGET_ID), nativeWindow(new NativeWindow(nativeEventTarget)) {
  location_ = new JSLocation(context);

  getDartMethod()->initWindow(window->contextId, nativeWindow);
}

WindowInstance::~WindowInstance() {
  delete nativeWindow;
}

JSValueRef WindowInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getWindowPropertyMap();
  auto prototypePropertyMap = getWindowPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSWindow>()->prototypeObject, nameStringHolder.getString(), exception);
  }

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case WindowProperty::devicePixelRatio: {
      if (getDartMethod()->devicePixelRatio == nullptr) {
        throwJSError(context->context(),
                        "Failed to read devicePixelRatio: dart method (devicePixelRatio) is not register.", exception);
        return nullptr;
      }

      double devicePixelRatio = getDartMethod()->devicePixelRatio(_hostClass->contextId);
      return JSValueMakeNumber(context->context(), devicePixelRatio);
    }
    case WindowProperty::colorScheme: {
      if (getDartMethod()->platformBrightness == nullptr) {
        throwJSError(context->context(),
                        "Failed to read colorScheme: dart method (platformBrightness) not register.", exception);
        return nullptr;
      }
      const NativeString *code = getDartMethod()->platformBrightness(_hostClass->contextId);
      JSStringRef resultRef = JSStringCreateWithCharacters(code->string, code->length);
      return JSValueMakeString(context->context(), resultRef);
    }
    case WindowProperty::__location__:
      return location_->jsObject;
    case WindowProperty::parent:
    case WindowProperty::window:
      return this->object;
    case WindowProperty::history: {
      JSStringRef key = JSStringCreateWithUTF8CString("__history__");
      JSValueRef history = JSObjectGetProperty(_hostClass->ctx, _hostClass->context->global(), key, exception);
      JSStringRelease(key);
      return history;
    }
    case WindowProperty::scrollX: {
      getDartMethod()->flushUICommand();
      auto document = DocumentInstance::instance(_hostClass->context);
      assert_m(document->body->nativeElement->getViewModuleProperty != nullptr, "Failed to execute getViewModuleProperty(): dart method is nullptr.");
      return JSValueMakeNumber(_hostClass->ctx,
                               document->body->nativeElement->getViewModuleProperty(document->body->nativeElement, static_cast<int64_t>(ViewModuleProperty::scrollLeft)));
    }
    case WindowProperty::scrollY: {
      getDartMethod()->flushUICommand();
      auto document = DocumentInstance::instance(_hostClass->context);
      assert_m(document->body->nativeElement->getViewModuleProperty != nullptr, "Failed to execute getViewModuleProperty(): dart method is nullptr.");
      return JSValueMakeNumber(_hostClass->ctx,
                               document->body->nativeElement->getViewModuleProperty(document->body->nativeElement, static_cast<int64_t>(ViewModuleProperty::scrollTop)));
    }
    }
  }

  JSValueRef eventTargetRet = EventTargetInstance::getProperty(name, exception);
  if (eventTargetRet != nullptr) return eventTargetRet;

  JSStringHolder keyStringHolder = JSStringHolder(context, name);
  if (JSObjectHasProperty(ctx, _hostClass->context->global(), keyStringHolder.getString())) {
    return JSObjectGetProperty(_hostClass->ctx, _hostClass->context->global(), keyStringHolder.getString(), exception);
  }

  return nullptr;
}

bool WindowInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getWindowPropertyMap();
  auto prototypePropertyMap = getWindowPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  // Key is prototype property, return false to handled by engine itself.
  if (prototypePropertyMap.count(name) > 0) {
    return false;
  }

  // Key is window's built-in property. return true to do nothing because this properties are readonly.
  if (propertyMap.count(name) > 0) {
    return true;
  }

  JSObjectSetProperty(_hostClass->ctx, _hostClass->context->global(), nameStringHolder.getString(), value, kJSPropertyAttributeNone, exception);

  return EventTargetInstance::setProperty(name, value, exception);
}

void WindowInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  EventTargetInstance::getPropertyNames(accumulator);

  for (auto &property : getWindowPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSValueRef JSWindow::open(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef urlValueRef = arguments[0];
  JSStringRef url = JSValueToStringCopy(ctx, urlValueRef, exception);
  auto window = reinterpret_cast<WindowInstance *>(JSObjectGetPrivate(thisObject));
  window->nativeWindow->open(window->nativeWindow, stringRefToNativeString(url));
  return nullptr;
}

JSValueRef JSWindow::scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
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

  auto window = reinterpret_cast<WindowInstance *>(JSObjectGetPrivate(thisObject));
  getDartMethod()->flushUICommand();
  auto document = DocumentInstance::instance(window->context);
  assert_m( document->body->nativeElement->scroll != nullptr, "Failed to execute scroll(): dart method is nullptr.");
  document->body->nativeElement->scroll(document->body->nativeElement, x, y);

  return nullptr;
}

JSValueRef JSWindow::scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
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

  auto window = reinterpret_cast<WindowInstance *>(JSObjectGetPrivate(thisObject));
  getDartMethod()->flushUICommand();
  auto document = DocumentInstance::instance(window->context);
  assert_m( document->body->nativeElement->scrollBy != nullptr, "Failed to execute scroll(): dart method is nullptr.");
  document->body->nativeElement->scrollBy(document->body->nativeElement, x, y);

  return nullptr;
}

JSWindow::~JSWindow() {
  instanceMap.erase(context);
}

JSObjectRef JSWindow::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                          const JSValueRef *arguments, JSValueRef *exception) {
  auto window = new WindowInstance(this);
  return window->object;
}

std::unordered_map<JSContext *, JSWindow *> JSWindow::instanceMap{};

JSWindow *JSWindow::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
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
