/*
* Copyright (C) 2020-present Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include "toBlob.h"
#include "foundation/logging.h"
#include "dart_methods.h"
#include "blob.h"
#include "foundation/callback_context.h"
#include <vector>

namespace kraken {
namespace binding {

using namespace kraken::foundation;

Value toBlob(JSContext &context, const Value &thisVal, const Value *args,
             size_t count) {
  const Value &id = args[0];
  const Value &callback = args[1];

  if (!id.isNumber()) {
    KRAKEN_LOG(ERROR) << "Failed to export blob: missing element's id" << std::endl;
    return Value::undefined();
  }

  if (!callback.isObject() && !callback.getObject(context).isFunction(context)) {
    KRAKEN_LOG(ERROR) << "Failed to export blob: callback should be a function type" << std::endl;
    return Value::undefined();
  }

  if (getDartMethod()->toBlob == nullptr) {
    KRAKEN_LOG(ERROR) << "[toBlob] dart callback not register." << std::endl;
    return Value::undefined();
  }

  std::shared_ptr<Value> func = std::make_shared<Value>(Value(context, callback));

  auto ctx = new CallbackContext(context, func);

  getDartMethod()->toBlob([](void *ptr, const char *error, uint8_t *bytes, int32_t length) {
    auto ctx = static_cast<CallbackContext *>(ptr);
    JSContext &context = ctx->_context;

    if (error != nullptr) {
      ctx->_callback->getObject(context).getFunction(context).call(context, {
          String::createFromAscii(context, error)
      });
    } else {
      std::vector<uint8_t> vec(bytes, bytes + length);
      ctx->_callback->getObject(context).getFunction(context).call(context, {
          Value::null(),
          Object::createFromHostObject(context, std::make_shared<JSBlob>(vec))
      });
    }

    delete ctx;
  }, static_cast<void *>(ctx), id.getNumber());
  return Value::undefined();
}


void bindToBlob(std::unique_ptr<JSContext> &context) {
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_to_blob__", 0, toBlob);
}


}
}
