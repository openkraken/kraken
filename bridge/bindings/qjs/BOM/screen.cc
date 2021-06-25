/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "screen.h"

namespace kraken::binding::qjs {

void bindScreen(std::unique_ptr<JSContext> &context) {}

JSValue WidthPropertyDescriptor::getter(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (getDartMethod()->getScreen == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read screen: dart method (getScreen) is not registered.");
  }

  auto context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  Screen *screen = getDartMethod()->getScreen(context->getContextId());
  return JS_NewFloat64(ctx, screen->width);
}

JSValue WidthPropertyDescriptor::setter(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_UNDEFINED;
}

JSValue HeightPropertyDescriptor::getter(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (getDartMethod()->getScreen == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read screen: dart method (getScreen) is not registered.");
  }

  auto context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  Screen *screen = getDartMethod()->getScreen(context->getContextId());
  return JS_NewFloat64(ctx, screen->height);
}

JSValue HeightPropertyDescriptor::setter(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_UNDEFINED;
}

}
