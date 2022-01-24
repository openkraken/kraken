/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include <utility>
#include "dart_methods.h"

namespace kraken::binding::qjs {

void bindLocation(std::unique_ptr<ExecutionContext>& context) {
  auto* contextData = context->contextData();
  JSValue classObject = contextData->constructorForType(&locationTypeInfo);
  JSValue prototypeObject = contextData->prototypeForType(&locationTypeInfo);

  // Install methods
  INSTALL_FUNCTION(Location, prototypeObject, reload, 0);

  context->defineGlobalProperty("Location", classObject);
}

JSClassID Location::classId{0};

Location* Location::create(JSContext* ctx) {
  return makeGarbageCollected<Location>()->initialize<Location>(ctx, &classId);
}

IMPL_FUNCTION(Location, reload)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* location = static_cast<Location*>(JS_GetOpaque(this_val, ExecutionContext::kHostObjectClassId));
  if (getDartMethod()->reloadApp == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'reload': dart method (reloadApp) is not registered.");
  }

  getDartMethod()->flushUICommand();
  getDartMethod()->reloadApp(location->context()->getContextId());

  return JS_NULL;
}

void Location::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {}

void Location::dispose() const {}

}  // namespace kraken::binding::qjs
