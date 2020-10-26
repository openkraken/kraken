/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "toBlob.h"
#include "bindings/jsc/macros.h"
#include "blob.h"
#include "bridge_jsc.h"
#include "dart_methods.h"
#include "foundation/bridge_callback.h"
#include <vector>

namespace kraken::binding::jsc {

using namespace kraken::foundation;

JSValueRef toBlob(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                  const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef &idValueRef = arguments[0];
  const JSValueRef &devicePixelRatioValueRef = arguments[1];
  const JSValueRef &callbackValueRef = arguments[2];

  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));

  if (!JSValueIsNumber(ctx, idValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: missing element's id.", exception);
    return nullptr;
  }

  if (!JSValueIsNumber(ctx, devicePixelRatioValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: parameter 2 (devicePixelRatio) is not an number.", exception);
    return nullptr;
  }

  if (!JSValueIsObject(ctx, callbackValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackValueRef, exception);

  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob': parameter 1 (callback) must be a function.", exception);
    return nullptr;
  }

  if (getDartMethod()->toBlob == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: dart method (toBlob) is not registered.", exception);
    return nullptr;
  }

  double id = JSValueToNumber(ctx, idValueRef, exception);
  double devicePixelRatio = JSValueToNumber(ctx, devicePixelRatioValueRef, exception);

  auto callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackObjectRef, exception);
  auto bridge = static_cast<JSBridge *>(context->getOwner());
  bridge->bridgeCallback->registerCallback<void>(
    std::move(callbackContext),
    [id, devicePixelRatio](BridgeCallback::Context *callbackContext, int32_t contextId) {
      getDartMethod()->toBlob(
        callbackContext, contextId,
        [](void *ptr, int32_t contextId, const char *error, uint8_t *bytes, int32_t length) {
          auto callbackContext = static_cast<BridgeCallback::Context *>(ptr);
          JSContext &_context = callbackContext->_context;
          JSContextRef ctx = callbackContext->_context.context();

          if (!checkContext(contextId, &_context)) return;
          if (error != nullptr) {
            JSStringRef errorStringRef = JSStringCreateWithUTF8CString(error);
            const JSValueRef arguments[] = {JSValueMakeString(ctx, errorStringRef)};
            JSObjectRef callbackObjectRef = JSValueToObject(ctx,
                                                            callbackContext->_callback, callbackContext->exception);
            JSObjectCallAsFunction(ctx, callbackObjectRef,
                                   callbackContext->_context.global(), 1, arguments, callbackContext->exception);
          } else {
            std::vector<uint8_t> vec(bytes, bytes + length);
            JSObjectRef callbackObjectRef = JSValueToObject(callbackContext->_context.context(),
                                                            callbackContext->_callback, callbackContext->exception);
            auto blob = new JSBlob(&callbackContext->_context, std::move(vec));
            const JSValueRef arguments[] = {
              JSValueMakeNull(callbackContext->_context.context()),
              blob->jsObject
            };

            JSObjectCallAsFunction(ctx, callbackObjectRef, callbackContext->_context.global(), 1, arguments, callbackContext->exception);
          }
        },
        id, devicePixelRatio);
    });
  return nullptr;
}

void bindToBlob(std::unique_ptr<JSContext> &context) {
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_to_blob__", toBlob);
}

} // namespace kraken::binding::jsc
