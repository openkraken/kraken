/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_manager.h"
#include "bindings/jsc/macros.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

JSValueRef requestBatchUpdate(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                 const JSValueRef arguments[], JSValueRef *exception) {
  if (getDartMethod()->requestUpdateFrame == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to execute '__kraken_request_update_frame__': dart method (requestUpdateFrame) is not registered.", exception);
    return nullptr;
  }
  getDartMethod()->requestUpdateFrame();
  return nullptr;
}

void bindUIManager(std::unique_ptr<JSContext> &context) {
  JSC_BINDING_FUNCTION(context, "__kraken_request_update_frame__", requestBatchUpdate);
}

}
