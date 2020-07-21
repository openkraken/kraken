/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "toBlob.h"
#include "blob.h"
#include "bridge.h"
#include "dart_methods.h"
#include "foundation/bridge_callback.h"
#include <vector>

namespace kraken {
namespace binding {

using namespace kraken::foundation;

Value toBlob(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  const Value &id = args[0];
  const Value &devicePixelRatio = args[1];
  const Value &callback = args[2];

  if (!id.isNumber()) {
    throw JSError(context, "Failed to export blob: missing element's id.");
  }

  if (!devicePixelRatio.isNumber()) {
    throw JSError(context, "Failed to export blob: parameter 2 (devicePixelRatio) is not an number.");
  }

  if (!callback.isObject() && !callback.getObject(context).isFunction(context)) {
    throw JSError(context, "Failed to export blob: callback should be a function type.");
  }

  if (getDartMethod()->toBlob == nullptr) {
    throw JSError(context, "Failed to export blob: dart method (toBlob) is not registered.");
  }

  std::shared_ptr<Value> func = std::make_shared<Value>(Value(context, callback));

  auto callbackContext = std::make_unique<BridgeCallback::Context>(context, func);
  auto bridge = static_cast<JSBridge*>(context.getOwner());
  bridge->bridgeCallback.registerCallback<void>(std::move(callbackContext), [&id, &devicePixelRatio](BridgeCallback::Context *callbackContext, int32_t contextId) {
    getDartMethod()->toBlob(callbackContext, contextId,
      [](void *calbackContext, int32_t contextId, const char *error, uint8_t *bytes, int32_t length) {
        auto ctx = static_cast<BridgeCallback::Context *>(calbackContext);
        JSContext &_context = ctx->_context;

        if (error != nullptr) {
          ctx->_callback->getObject(_context).getFunction(_context).call(
            _context, {Value(_context, String::createFromAscii(_context, error))});
        } else {
          std::vector<uint8_t> vec(bytes, bytes + length);
          ctx->_callback->getObject(_context).getFunction(_context).call(
            _context,
            {Value::null(), Value(_context, Object::createFromHostObject(_context, std::make_shared<JSBlob>(vec)))});
        }
      },
      id.getNumber(), devicePixelRatio.getNumber());
  });
  return Value::undefined();
}

void bindToBlob(std::unique_ptr<JSContext> &context) {
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_to_blob__", 0, toBlob);
}

} // namespace binding
} // namespace kraken
