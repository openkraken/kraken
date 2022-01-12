/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include <utility>
#include "dart_methods.h"

namespace kraken::binding::qjs {

JSValue Location::reload(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* location = static_cast<Location*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  if (getDartMethod()->reloadApp == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'reload': dart method (reloadApp) is not registered.");
  }

  getDartMethod()->flushUICommand();
  getDartMethod()->reloadApp(location->m_context->getContextId());

  return JS_NULL;
}

}  // namespace kraken::binding::qjs
