/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include <utility>
#include "dart_methods.h"

namespace kraken::binding::qjs {

std::string href;

void updateLocation(std::string url) {
  href = std::move(url);
}

PROP_GETTER(Location, href)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NewString(ctx, href.c_str());
}
PROP_SETTER(Location, href)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

JSValue Location::reload(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *location = static_cast<Location *>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  if (getDartMethod()->reloadApp == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'reload': dart method (reloadApp) is not registered.");
  }

  getDartMethod()->flushUICommand();
  getDartMethod()->reloadApp(location->m_context->getContextId());

  return JS_NULL;
}

}
