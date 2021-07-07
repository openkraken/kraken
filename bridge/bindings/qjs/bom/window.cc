/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "dart_methods.h"
#include "bindings/qjs/qjs_patch.h"

namespace kraken::binding::qjs {

OBJECT_INSTANCE_IMPL(Window);

void bindWindow(std::unique_ptr<JSContext> &context) {
  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  auto *windowConstructor = new Window(context.get());
  JS_SetPrototype(context->ctx(), context->global(), windowConstructor->prototype());
  context->defineGlobalProperty("Window", windowConstructor->classObject);

  auto *windowInstance = new WindowInstance(windowConstructor);
  context->defineGlobalProperty("window", windowInstance->instanceObject);
  JS_SetOpaque(context->global(), windowInstance);
}

JSValue Window::open(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  JSValue &url = argv[0];
  auto window = static_cast<WindowInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  //
//  const JSValueRef urlValueRef = arguments[0];
//  JSStringRef url = JSValueToStringCopy(ctx, urlValueRef, exception);
//  auto window = reinterpret_cast<WindowInstance *>(JSObjectGetPrivate(thisObject));
//  window->nativeWindow->open(window->nativeWindow, stringRefToNativeString(url));
//  return nullptr;
  return JS_NULL;
}
JSValue Window::scrollTo(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}
JSValue Window::scrollBy(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}

PROP_GETTER(Window, devicePixelRatio)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (getDartMethod()->devicePixelRatio == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read devicePixelRatio: dart method (devicePixelRatio) is not register.");
  }
  auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));

  double devicePixelRatio = getDartMethod()->devicePixelRatio(context->getContextId());
  return JS_NewFloat64(ctx, devicePixelRatio);
}
PROP_SETTER(Window, devicePixelRatio)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, colorScheme)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (getDartMethod()->platformBrightness == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read colorScheme: dart method (platformBrightness) not register.");
  }
  auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));

  const NativeString *code = getDartMethod()->platformBrightness(context->getContextId());
  return JS_NewUnicodeString(context->runtime(), ctx, code->string, code->length);
}
PROP_SETTER(Window, colorScheme)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, __location__)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *windowInstance = static_cast<WindowInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  if (windowInstance == nullptr) return JS_UNDEFINED;
  return windowInstance->m_location->jsObject;
}
PROP_SETTER(Window, __location__)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, window)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *windowInstance = static_cast<WindowInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  if (windowInstance == nullptr) return JS_UNDEFINED;
  return windowInstance->instanceObject;
}
PROP_SETTER(Window, window)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}
PROP_GETTER(Window, parent)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *windowInstance = static_cast<WindowInstance *>(JS_GetOpaque(this_val, kHostClassInstanceClassId));
  if (windowInstance == nullptr) return JS_UNDEFINED;
  return windowInstance->instanceObject;
}
PROP_SETTER(Window, parent)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, history)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  return JS_GetPropertyStr(ctx, context->global(), "__history__");
}
PROP_SETTER(Window, history)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, scrollX)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
// @TODO: implement scrollX;
  auto *windowInstance = static_cast<WindowInstance *>(JS_GetOpaque(this_val, 1));
  if (windowInstance == nullptr) return JS_UNDEFINED;
  std::u16string testString = u"helloworld";
  NativeString method{
    reinterpret_cast<const uint16_t *>(testString.c_str()),
    static_cast<int32_t>(testString.size())
  };

  NativeValue arguments[] = {
    Native_NewBool(true),
    Native_NewFloat64(1.24),
    Native_NewInt32(111),
    Native_NewString(&method)
  };

  return windowInstance->callNativeMethods(&method, 4, arguments);
}
PROP_SETTER(Window, scrollX)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, scrollY)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
// @TODO: implement scrollY
  return JS_NULL;
}
PROP_SETTER(Window, scrollY)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

WindowInstance::WindowInstance(Window *window): EventTargetInstance(window) {
  getDartMethod()->initWindow(context()->getContextId(), &nativeEventTarget);
}

}
