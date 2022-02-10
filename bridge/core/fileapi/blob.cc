/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob.h"
//#include "dart_methods.h"

namespace kraken {

//void bindBlob(std::unique_ptr<ExecutionContext>& context) {
//  JSValue constructor = context->contextData()->constructorForType(&blobTypeInfo);
//  JSValue prototype = context->contextData()->prototypeForType(&blobTypeInfo);
//
//  // Install methods on prototype.
//  INSTALL_FUNCTION(Blob, prototype, arrayBuffer, 0);
//  INSTALL_FUNCTION(Blob, prototype, slice, 3);
//  INSTALL_FUNCTION(Blob, prototype, text, 0);
//
//  // Install readonly properties.
//  INSTALL_READONLY_PROPERTY(Blob, prototype, type);
//  INSTALL_READONLY_PROPERTY(Blob, prototype, size);
//
//  context->defineGlobalProperty("Blob", constructor);
//}

JSClassID Blob::classID{0};

Blob* Blob::create(JSContext* ctx) {
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
  auto* blob = makeGarbageCollected<Blob>()->initialize<Blob>(ctx, &classID);

  JSValue prototype = context->contextData()->prototypeForType(&blobTypeInfo);

  // Let eventTarget instance inherit EventTarget prototype methods.
  JS_SetPrototype(ctx, blob->toQuickJS(), prototype);
  return blob;
}
Blob* Blob::create(JSContext* ctx, std::vector<uint8_t>&& data) {
  return create(ctx);
}
Blob* Blob::create(JSContext* ctx, std::vector<uint8_t>&& data, std::string& mime) {
  return create(ctx);
}

JSValue Blob::constructor(ExecutingContext* context) {
  return context->contextData()->constructorForType(&blobTypeInfo);
}

JSValue Blob::prototype(ExecutingContext* context) {
  return context->contextData()->prototypeForType(&blobTypeInfo);
}

IMPL_PROPERTY_GETTER(Blob, type)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));
  return JS_NewString(blob->m_ctx, blob->mimeType.empty() ? "" : blob->mimeType.c_str());
}

IMPL_PROPERTY_GETTER(Blob, size)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));
  return JS_NewFloat64(blob->m_ctx, blob->_size);
}

IMPL_FUNCTION(Blob, arrayBuffer)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  JSValue resolving_funcs[2];
  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);

  auto blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));

  JS_DupValue(ctx, blob->jsObject);

  auto* promiseContext = new PromiseContext{blob, blob->context(), resolving_funcs[0], resolving_funcs[1], promise};
  auto callback = [](void* callbackContext, int32_t contextId, const char* errmsg) {
    if (!isContextValid(contextId))
      return;
    auto* promiseContext = static_cast<PromiseContext*>(callbackContext);
    auto* blob = static_cast<Blob*>(promiseContext->data);
    JSContext* ctx = blob->m_ctx;

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
  list_add_tail(&promiseContext->link, &blob->context()->promise_job_list);

  // TODO: remove setTimeout
  getDartMethod()->setTimeout(promiseContext, blob->context()->getContextId(), callback, 0);

  return promise;
}

IMPL_FUNCTION(Blob, slice)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  JSValue startValue = argv[0];
  JSValue endValue = argv[1];
  JSValue contentTypeValue = argv[2];

  auto* blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));
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
    auto* newBlob = Blob::create(ctx, std::move(blob->_data), mimeType);
    return newBlob->toQuickJS();
  }
  std::vector<uint8_t> newData;
  newData.reserve(blob->_data.size() - (end - start));
  newData.insert(newData.begin(), blob->_data.begin() + start, blob->_data.end() - (blob->_data.size() - end));

  auto* newBlob = Blob::create(ctx, std::move(newData), mimeType);
  return newBlob->toQuickJS();
}

IMPL_FUNCTION(Blob, text)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  JSValue resolving_funcs[2];
  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);

  auto blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));
  JS_DupValue(ctx, blob->jsObject);

  auto* promiseContext = new PromiseContext{blob, blob->context(), resolving_funcs[0], resolving_funcs[1], promise};
  auto callback = [](void* callbackContext, int32_t contextId, const char* errmsg) {
    if (!isContextValid(contextId))
      return;

    auto* promiseContext = static_cast<PromiseContext*>(callbackContext);
    auto* blob = static_cast<Blob*>(promiseContext->data);
    JSContext* ctx = blob->m_ctx;

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
  list_add_tail(&promiseContext->link, &blob->context()->promise_job_list);

  getDartMethod()->setTimeout(promiseContext, blob->context()->getContextId(), callback, 0);

  return promise;
}

void BlobBuilder::append(ExecutingContext& context, Blob* blob) {
  std::vector<uint8_t> blobData = blob->_data;
  _data.reserve(_data.size() + blobData.size());
  _data.insert(_data.end(), blobData.begin(), blobData.end());
}

void BlobBuilder::append(ExecutingContext& context, JSValue& value) {
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
    if (JS_IsInstanceOf(context.ctx(), value, Blob::constructor(&context))) {
      auto blob = static_cast<Blob*>(JS_GetOpaque(value, Blob::classID));
      if (blob == nullptr)
        return;
      if (std::string(blob->getHumanReadableName()) == "Blob") {
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

int32_t Blob::size() {
  return _data.size();
}

uint8_t* Blob::bytes() {
  return _data.data();
}

void Blob::trace(GCVisitor* visitor) const {}
void Blob::dispose() const {}

}  // namespace kraken
