/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "screen.h"
#include "jsa.h"
#include "logging.h"
#include "thread_safe_data.h"
#include <kraken_dart_export.h>

struct Screen {
  int availHeight;
  int availWidth;
  int colorDepth;
  int height;
  int width;
};

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

Screen screen;

void bindScreen(JSContext *context) {
  // flutter screen is not initialized when this constructor called.
  // so we do nothing(nothing can do) at this constructor and waiting for
  // flutter to invoke a callback to initialize the screen javascript object.
  Object screen = JSA_CREATE_OBJECT(*context);
  screen.setProperty(*context, "width", Value(0));
  screen.setProperty(*context, "height", Value(0));
  screen.setProperty(*context, "availWidth", Value(0));
  screen.setProperty(*context, "availHeight", Value(0));
  context->global().setProperty(*context, "screen", screen);
}

void invokeUpdateScreen(alibaba::jsa::JSContext *context, int width, int height,
                        int availWidth, int availHeight) {
  //  Object &screen = JSA_GLOBAL_GET_PROPERTY(*context, "screen");
  Value &&screen = context->global().getProperty(*context, "screen");
  Object &&screenObject = screen.asObject(*context);

  screenObject.setProperty(*context, "width", Value(width));
  screenObject.setProperty(*context, "height", Value(height));
  screenObject.setProperty(*context, "availWidth", Value(availWidth));
  screenObject.setProperty(*context, "availHeight", Value(availHeight));

  // TODO trigger window resize event here
}

} // namespace binding
} // namespace kraken
