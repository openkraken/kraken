/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "screen.h"

namespace kraken::binding::qjs {

void bindScreen(std::unique_ptr<JSContext>& context) {
  auto* screen = new Screen(context.get());
  context->defineGlobalProperty("screen", screen->jsObject);
}

PROP_GETTER(Screen, width)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->getScreen == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read screen: dart method (getScreen) is not registered.");
  }

  auto context = static_cast<JSContext*>(JS_GetContextOpaque(ctx));
  NativeScreen* screen = getDartMethod()->getScreen(context->getContextId());
  return JS_NewFloat64(ctx, screen->width);
}
PROP_SETTER(Screen, width)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_UNDEFINED;
}

PROP_GETTER(Screen, height)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->getScreen == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read screen: dart method (getScreen) is not registered.");
  }

  auto context = static_cast<JSContext*>(JS_GetContextOpaque(ctx));
  NativeScreen* screen = getDartMethod()->getScreen(context->getContextId());
  return JS_NewFloat64(ctx, screen->height);
}
PROP_SETTER(Screen, height)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_UNDEFINED;
}

}  // namespace kraken::binding::qjs
