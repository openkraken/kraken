/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob.h"
#include "dart_methods.h"

namespace kraken::binding::qjs {

std::once_flag kBlobInitOnceFlag;

void bindBlob(std::unique_ptr<JSContext>& context) {
  auto* constructor = Blob::instance(context.get());
  context->defineGlobalProperty("Blob", constructor->jsObject);
}

Blob::Blob(JSContext* context) : HostClass(context, "Blob") {
  std::call_once(kBlobInitOnceFlag, []() { JS_NewClassID(&kBlobClassID); });
}

JSClassID Blob::kBlobClassID{0};

JSValue Blob::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  BlobBuilder builder;
  auto constructor = static_cast<Blob*>(JS_GetOpaque(func_obj, JSContext::kHostClassClassId));
  if (argc == 0) {
    auto blob = new BlobInstance(constructor);
    return blob->jsObject;
  }

  JSValue arrayValue = argv[0];
  JSValue optionValue = JS_UNDEFINED;

  if (argc > 1) {
    optionValue = argv[1];
  }

  if (!JS_IsArray(ctx, arrayValue)) {
    return JS_ThrowTypeError(ctx, "Failed to construct 'Blob': The provided value cannot be converted to a sequence");
  }

  if (argc == 1 || JS_IsUndefined(optionValue)) {
    builder.append(*constructor->m_context, arrayValue);
    auto blob = new BlobInstance(constructor, builder.finalize());
    return blob->jsObject;
  }

  if (!JS_IsObject(optionValue)) {
    return JS_ThrowTypeError(ctx,
                             "Failed to construct 'Blob': parameter 2 ('options') "
                             "is not an object");
  }

  JSAtom mimeTypeKey = JS_NewAtom(ctx, "type");

  JSValue mimeTypeValue = JS_GetProperty(ctx, optionValue, mimeTypeKey);
  builder.append(*constructor->m_context, mimeTypeValue);
  const char* cMineType = JS_ToCString(ctx, mimeTypeValue);
  std::string mimeType = std::string(cMineType);

  auto* blob = new BlobInstance(constructor, builder.finalize(), mimeType);

  JS_FreeValue(ctx, mimeTypeValue);
  JS_FreeCString(ctx, mimeType.c_str());
  JS_FreeAtom(ctx, mimeTypeKey);

  return blob->jsObject;
}

IMPL_PROPERTY_GETTER(Blob, type)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* blobInstance = static_cast<BlobInstance*>(JS_GetOpaque(this_val, Blob::kBlobClassID));
  return JS_NewString(blobInstance->m_ctx, blobInstance->mimeType.empty() ? "" : blobInstance->mimeType.c_str());
}

IMPL_PROPERTY_GETTER(Blob, size)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* blobInstance = static_cast<BlobInstance*>(JS_GetOpaque(this_val, Blob::kBlobClassID));
  return JS_NewFloat64(blobInstance->m_ctx, blobInstance->_size);
}

JSValue Blob::arrayBuffer(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  JSValue resolving_funcs[2];
  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);

  auto blob = static_cast<BlobInstance*>(JS_GetOpaque(this_val, Blob::kBlobClassID));

  JS_DupValue(ctx, blob->jsObject);

  auto* promiseContext = new PromiseContext{blob, blob->m_context, resolving_funcs[0], resolving_funcs[1], promise};
  auto callback = [](void* callbackContext, int32_t contextId, const char* errmsg) {
    if (!isContextValid(contextId))
      return;
    auto* promiseContext = static_cast<PromiseContext*>(callbackContext);
    auto* blob = static_cast<BlobInstance*>(promiseContext->data);
    QjsContext* ctx = blob->m_ctx;

    JSValue arrayBuffer = JS_NewArrayBuffer(
        ctx, blob->bytes(), blob->size(), [](JSRuntime* rt, void* opaque, void* ptr) {}, nullptr, false);
    JSValue arguments[] = {arrayBuffer};
    JSValue returnValue = JS_Call(ctx, promiseContext->resolveFunc, blob->context()->global(), 1, arguments);
    JS_FreeValue(ctx, returnValue);

    blob->context()->drainPendingPromiseJobs();

    if (JS_IsException(returnValue)) {
      blob->context()->handleException(&returnValue);
      return;
    }

    JS_FreeValue(ctx, promiseContext->resolveFunc);
    JS_FreeValue(ctx, promiseContext->rejectFunc);
    JS_FreeValue(ctx, arrayBuffer);
    JS_FreeValue(ctx, blob->jsObject);
    list_del(&promiseContext->link);
    delete promiseContext;
  };
  list_add_tail(&promiseContext->link, &blob->m_context->promise_job_list);

  // TODO: remove setTimeout
  getDartMethod()->setTimeout(promiseContext, blob->context()->getContextId(), callback, 0);

  return promise;
}

JSValue Blob::slice(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  JSValue startValue = argv[0];
  JSValue endValue = argv[1];
  JSValue contentTypeValue = argv[2];

  auto* blob = static_cast<BlobInstance*>(JS_GetOpaque(this_val, Blob::kBlobClassID));
  int32_t start = 0;
  int32_t end = blob->_data.size();
  std::string mimeType = blob->mimeType;

  if (argc > 0 && !JS_IsUndefined(startValue)) {
    JS_ToInt32(ctx, &start, startValue);
  }

  if (argc > 1 && !JS_IsUndefined(endValue)) {
    JS_ToInt32(ctx, &end, endValue);
  }

  if (argc > 2 && !JS_IsUndefined(contentTypeValue)) {
    const char* cmimeType = JS_ToCString(ctx, contentTypeValue);
    mimeType = std::string(cmimeType);
    JS_FreeCString(ctx, mimeType.c_str());
  }

  if (start == 0 && end == blob->_data.size()) {
    auto newBlob = new BlobInstance(reinterpret_cast<Blob*>(blob->m_hostClass), std::move(blob->_data), mimeType);
    return newBlob->jsObject;
  }
  std::vector<uint8_t> newData;
  newData.reserve(blob->_data.size() - (end - start));
  newData.insert(newData.begin(), blob->_data.begin() + start, blob->_data.end() - (blob->_data.size() - end));

  auto newBlob = new BlobInstance(reinterpret_cast<Blob*>(blob->m_hostClass), std::move(newData), mimeType);
  return newBlob->jsObject;
}

JSValue Blob::text(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  JSValue resolving_funcs[2];
  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);

  auto blob = static_cast<BlobInstance*>(JS_GetOpaque(this_val, Blob::kBlobClassID));
  JS_DupValue(ctx, blob->jsObject);

  auto* promiseContext = new PromiseContext{blob, blob->m_context, resolving_funcs[0], resolving_funcs[1], promise};
  auto callback = [](void* callbackContext, int32_t contextId, const char* errmsg) {
    if (!isContextValid(contextId))
      return;

    auto* promiseContext = static_cast<PromiseContext*>(callbackContext);
    auto* blob = static_cast<BlobInstance*>(promiseContext->data);
    QjsContext* ctx = blob->m_ctx;

    JSValue text = JS_NewStringLen(ctx, reinterpret_cast<const char*>(blob->bytes()), blob->size());
    JSValue arguments[] = {text};
    JSValue returnValue = JS_Call(ctx, promiseContext->resolveFunc, blob->context()->global(), 1, arguments);
    JS_FreeValue(ctx, returnValue);

    blob->context()->drainPendingPromiseJobs();

    if (JS_IsException(returnValue)) {
      blob->context()->handleException(&returnValue);
      return;
    }

    JS_FreeValue(ctx, promiseContext->resolveFunc);
    JS_FreeValue(ctx, promiseContext->rejectFunc);
    JS_FreeValue(ctx, text);
    JS_FreeValue(ctx, blob->jsObject);
    list_del(&promiseContext->link);
    delete promiseContext;
  };
  list_add_tail(&promiseContext->link, &blob->m_context->promise_job_list);

  getDartMethod()->setTimeout(promiseContext, blob->context()->getContextId(), callback, 0);

  return promise;
}

void BlobInstance::finalize(JSRuntime* rt, JSValue val) {
  auto* eventTarget = static_cast<BlobInstance*>(JS_GetOpaque(val, Blob::kBlobClassID));
  delete eventTarget;
}

void BlobBuilder::append(JSContext& context, BlobInstance* blob) {
  std::vector<uint8_t> blobData = blob->_data;
  _data.reserve(_data.size() + blobData.size());
  _data.insert(_data.end(), blobData.begin(), blobData.end());
}

void BlobBuilder::append(JSContext& context, JSValue& value) {
  if (JS_IsString(value)) {
    const char* buffer = JS_ToCString(context.ctx(), value);
    std::string str = std::string(buffer);
    std::vector<uint8_t> strArr(str.begin(), str.end());
    _data.reserve(_data.size() + strArr.size());
    _data.insert(_data.end(), strArr.begin(), strArr.end());
    JS_FreeCString(context.ctx(), buffer);
  } else if (JS_IsArray(context.ctx(), value)) {
    JSAtom lengthKey = JS_NewAtom(context.ctx(), "length");
    JSValue lengthValue = JS_GetProperty(context.ctx(), value, lengthKey);
    uint32_t length;
    JS_ToUint32(context.ctx(), &length, lengthValue);

    JS_FreeValue(context.ctx(), lengthValue);
    JS_FreeAtom(context.ctx(), lengthKey);

    for (size_t i = 0; i < length; i++) {
      JSValue v = JS_GetPropertyUint32(context.ctx(), value, i);
      append(context, v);
      JS_FreeValue(context.ctx(), v);
    }
  } else if (JS_IsObject(value)) {
    if (JS_IsInstanceOf(context.ctx(), value, Blob::instance(&context)->jsObject)) {
      auto blob = static_cast<BlobInstance*>(JS_GetOpaque(value, Blob::kBlobClassID));
      if (blob == nullptr)
        return;
      if (std::string(blob->m_name) == "Blob") {
        std::vector<uint8_t> blobData = blob->_data;
        _data.reserve(_data.size() + blobData.size());
        _data.insert(_data.end(), blobData.begin(), blobData.end());
      }
    } else {
      size_t length;
      uint8_t* buffer = JS_GetArrayBuffer(context.ctx(), &length, value);

      if (buffer == nullptr) {
        size_t byte_offset;
        size_t byte_length;
        size_t byte_per_element;
        JSValue arrayBufferObject = JS_GetTypedArrayBuffer(context.ctx(), value, &byte_offset, &byte_length, &byte_per_element);
        if (JS_IsException(arrayBufferObject)) {
          context.handleException(&arrayBufferObject);
          return;
        }
        buffer = JS_GetArrayBuffer(context.ctx(), &length, arrayBufferObject);
        JS_FreeValue(context.ctx(), arrayBufferObject);
      }

      for (size_t i = 0; i < length; i++) {
        _data.emplace_back(buffer[i]);
      }
    }
  }
}

std::vector<uint8_t> BlobBuilder::finalize() {
  return std::move(_data);
}

int32_t BlobInstance::size() {
  return _data.size();
}

uint8_t* BlobInstance::bytes() {
  return _data.data();
}
}  // namespace kraken::binding::qjs
