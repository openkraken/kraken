/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "screen.h"

namespace kraken::binding::qjs {

void bindScreen(ExecutionContext* context) {
  auto* screen = new Screen(context);
  context->defineGlobalProperty("screen", screen->jsObject);
}

IMPL_PROPERTY_GETTER(Screen, width)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->getScreen == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read screen: dart method (getScreen) is not registered.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  NativeScreen* screen = getDartMethod()->getScreen(context->getContextId());
  return JS_NewFloat64(ctx, screen->width);
}

IMPL_PROPERTY_GETTER(Screen, height)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->getScreen == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read screen: dart method (getScreen) is not registered.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  NativeScreen* screen = getDartMethod()->getScreen(context->getContextId());
  return JS_NewFloat64(ctx, screen->height);
}

// https://drafts.csswg.org/cssom-view/#dom-screen-availwidth
IMPL_PROPERTY_GETTER(Screen, availWidth)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->getScreen == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read screen: dart method (getScreen) is not registered.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  NativeScreen* screen = getDartMethod()->getScreen(context->getContextId());
  return JS_NewFloat64(ctx, screen->width);
}

// https://drafts.csswg.org/cssom-view/#dom-screen-availheight
IMPL_PROPERTY_GETTER(Screen, availHeight)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->getScreen == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read screen: dart method (getScreen) is not registered.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  NativeScreen* screen = getDartMethod()->getScreen(context->getContextId());
  return JS_NewFloat64(ctx, screen->height);
}

}  // namespace kraken::binding::qjs
