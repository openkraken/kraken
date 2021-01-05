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

JSValueRef WindowInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getWindowPropertyMap();

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
    case WindowProperty::scrollTo:
    case WindowProperty::scroll:
      return m_scroll.function();
    case WindowProperty::scrollBy:
      return m_scrollBy.function();
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
  getDartMethod()->flushUICommand();
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
