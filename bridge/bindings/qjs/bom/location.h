/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_LOCATION_H
#define KRAKENBRIDGE_LOCATION_H

#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/wrapper_type_info.h"

namespace kraken::binding::qjs {

void bindLocation(std::unique_ptr<ExecutionContext>& context);

class Location : public GarbageCollected<Location> {
 public:
  static JSClassID classId;
  static Location* create(JSContext* ctx);

  DEFINE_FUNCTION(reload);

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;
};

auto locationCreator = [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) -> JSValue {
  auto* type = static_cast<const WrapperTypeInfo*>(JS_GetOpaque(func_obj, JSValueGetClassId(func_obj)));
  auto* location = Location::create(ctx);
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue prototype = context->contextData()->prototypeForType(type);

  // Let eventTarget instance inherit EventTarget prototype methods.
  JS_SetPrototype(ctx, location->toQuickJS(), prototype);
  return location->toQuickJS();
};

const WrapperTypeInfo locationTypeInfo = {"Location", nullptr, locationCreator};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_LOCATION_H
