/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob.h"
#include "foundation/logging.h"

namespace kraken::binding::jsc {

void BlobBuilder::append(JSContext &context, JSStringRef text) {
  std::string &&str = JSStringToStdString(text);
  std::vector<uint8_t> strArr(str.begin(), str.end());
  _data.reserve(_data.size() + strArr.size());
  _data.insert(_data.end(), strArr.begin(), strArr.end());
}

void BlobBuilder::append(JSContext &context, JSBlob::BlobInstance *blob) {
  std::vector<uint8_t> blobData = blob->_data;
  _data.reserve(_data.size() + blobData.size());
  _data.insert(_data.end(), blobData.begin(), blobData.end());
}

void BlobBuilder::append(JSContext &context, const JSValueRef value, JSValueRef *exception) {
  if (JSValueIsString(context.context(), value)) {
    append(context, JSValueToStringCopy(context.context(), value, exception));
  } else if (JSValueIsArray(context.context(), value)) {
    JSObjectRef array = JSValueToObject(context.context(), value, exception);
    JSValueRef lengthValue =
      JSObjectGetProperty(context.context(), array, JSStringCreateWithUTF8CString("length"), exception);
    size_t length = JSValueToNumber(context.context(), lengthValue, exception);

    for (size_t i = 0; i < length; i++) {
      JSValueRef v = JSObjectGetPropertyAtIndex(context.context(), array, i, exception);
      append(context, v, exception);
    }

  } else if (JSValueIsObject(context.context(), value)) {
    JSTypedArrayType typedArrayType = JSValueGetTypedArrayType(context.context(), value, exception);
    if (typedArrayType == JSTypedArrayType::kJSTypedArrayTypeInt8Array ||
        typedArrayType == JSTypedArrayType::kJSTypedArrayTypeInt16Array ||
        typedArrayType == JSTypedArrayType::kJSTypedArrayTypeInt32Array ||
        typedArrayType == JSTypedArrayType::kJSTypedArrayTypeUint8Array ||
        typedArrayType == JSTypedArrayType::kJSTypedArrayTypeUint8ClampedArray ||
        typedArrayType == JSTypedArrayType::kJSTypedArrayTypeUint16Array ||
        typedArrayType == JSTypedArrayType::kJSTypedArrayTypeUint32Array ||
        typedArrayType == JSTypedArrayType::kJSTypedArrayTypeFloat32Array ||
        typedArrayType == JSTypedArrayType::kJSTypedArrayTypeFloat64Array) {
      JSObjectRef typedArray = JSValueToObject(context.context(), value, exception);
      size_t length = JSObjectGetTypedArrayByteLength(context.context(), typedArray, exception);
      auto ptr = static_cast<uint8_t *>(JSObjectGetTypedArrayBytesPtr(context.context(), typedArray, exception));
      for (size_t i = 0; i < length; i++) {
        _data.emplace_back(ptr[i]);
      }
    } else if (typedArrayType == JSTypedArrayType::kJSTypedArrayTypeArrayBuffer) {
      JSObjectRef arrayBuffer = JSValueToObject(context.context(), value, exception);
      size_t length = JSObjectGetArrayBufferByteLength(context.context(), arrayBuffer, exception);
      auto ptr = static_cast<uint8_t *>(JSObjectGetArrayBufferBytesPtr(context.context(), arrayBuffer, exception));
      for (size_t i = 0; i < length; i++) {
        _data.emplace_back(ptr[i]);
      }
    } else {
      auto blob =
        static_cast<JSBlob::BlobInstance *>(JSObjectGetPrivate(JSValueToObject(context.context(), value, exception)));
      if (blob == nullptr) {
        return;
      }

      if (std::string(blob->_hostClass->_name) == JSBlobName) {
        std::vector<uint8_t> blobData = blob->_data;
        _data.reserve(_data.size() + blobData.size());
        _data.insert(_data.end(), blobData.begin(), blobData.end());
      }
    }
  }
}

std::vector<uint8_t> BlobBuilder::finalize() {
  return std::move(_data);
}

std::unordered_map<JSContext *, JSBlob *> JSBlob::instanceMap{};

JSBlob *JSBlob::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSBlob(context);
  }
  return instanceMap[context];
}

JSBlob::~JSBlob() {
  instanceMap.erase(context);
}

JSObjectRef JSBlob::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                        const JSValueRef *arguments, JSValueRef *exception) {
  BlobBuilder builder;
  auto Blob = static_cast<JSBlob *>(JSObjectGetPrivate(constructor));
  if (argumentCount == 0) {
    auto blob = new JSBlob::BlobInstance(Blob);
    return blob->object;
  }

  const JSValueRef &arrayValue = arguments[0];
  const JSValueRef &optionValue = arguments[1];

  if (!JSValueIsArray(ctx, arrayValue)) {
    throwJSError(ctx, "Failed to construct 'Blob': The provided value cannot be converted to a sequence", exception);
    return nullptr;
  }

  if (argumentCount == 1 || JSValueIsUndefined(ctx, optionValue)) {
    builder.append(*context, arrayValue, exception);
    auto blob = new JSBlob::BlobInstance(Blob, builder.finalize());
    return blob->object;
  }

  if (!JSValueIsObject(ctx, optionValue)) {
    throwJSError(ctx,
                    "Failed to construct 'Blob': parameter 2 ('options') "
                    "is not an object",
                    exception);
    return nullptr;
  }

  JSObjectRef optionObject = JSValueToObject(ctx, optionValue, exception);
  JSValueRef mimeTypeValueRef =
    JSObjectGetProperty(ctx, optionObject, JSStringCreateWithUTF8CString("type"), exception);
  JSStringRef mineTypeStringRef = JSValueToStringCopy(ctx, mimeTypeValueRef, exception);
  builder.append(*context, arrayValue, exception);
  std::string mimeType = JSStringToStdString(mineTypeStringRef);
  auto blob = new JSBlob::BlobInstance(Blob, builder.finalize(), mimeType);
  return blob->object;
}

JSValueRef JSBlob::slice(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                       size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef startValueRef = arguments[0];
  const JSValueRef endValueRef = arguments[1];
  const JSValueRef contentTypeValueRef = arguments[2];

  auto blob = static_cast<JSBlob::BlobInstance *>(JSObjectGetPrivate(thisObject));
  size_t start = 0;
  size_t end = blob->_data.size();
  std::string mimeType = blob->mimeType;

  if (argumentCount > 0 && !JSValueIsUndefined(ctx, startValueRef)) {
    start = JSValueToNumber(ctx, startValueRef, exception);
  }

  if (argumentCount > 1 && !JSValueIsUndefined(ctx, endValueRef)) {
    end = JSValueToNumber(ctx, endValueRef, exception);
  }

  if (argumentCount > 2 && !JSValueIsUndefined(ctx, contentTypeValueRef)) {
    JSStringRef contentTypeStringRef = JSValueToStringCopy(ctx, contentTypeValueRef, exception);
    mimeType = std::move(JSStringToStdString(contentTypeStringRef));
    JSStringRelease(contentTypeStringRef);
  }

  if (start == 0 && end == blob->_data.size()) {
    auto newBlob =
      new JSBlob::BlobInstance(reinterpret_cast<JSBlob *>(blob->_hostClass), std::move(blob->_data), mimeType);
    return newBlob->object;
  }

  std::vector<uint8_t> newData;
  newData.reserve(blob->_data.size() - (end - start));
  newData.insert(newData.begin(), blob->_data.begin() + start, blob->_data.end() - (blob->_data.size() - end));

  auto newBlob = new JSBlob::BlobInstance(reinterpret_cast<JSBlob *>(blob->_hostClass), std::move(newData), mimeType);
  return newBlob->object;
}

JSValueRef JSBlob::text(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                      size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto blob = static_cast<JSBlob::BlobInstance *>(JSObjectGetPrivate(thisObject));
  auto context = new BlobPromiseContext();
  context->blobInstance = blob;
  JSObjectCallAsFunctionCallback callback = [](JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                               size_t argumentCount, const JSValueRef arguments[],
                                               JSValueRef *exception) -> JSValueRef {
    auto blobContext = reinterpret_cast<BlobPromiseContext *>(JSObjectGetPrivate(function));
    const JSValueRef resolveValueRef = arguments[0];

    JSObjectRef resolveObjectRef = JSValueToObject(ctx, resolveValueRef, exception);

    std::string newString(reinterpret_cast<const char *>(blobContext->blobInstance->_data.data()),
                          blobContext->blobInstance->_data.size());
    JSStringRef newStringRef = JSStringCreateWithUTF8CString(newString.c_str());

    const JSValueRef resolveArgs[] = {JSValueMakeString(ctx, newStringRef)};
    JSObjectCallAsFunction(ctx, resolveObjectRef, thisObject, 1, resolveArgs, exception);
    return nullptr;
  };

  return JSObjectMakePromise(blob->context, context, callback, exception);
}

JSValueRef JSBlob::arrayBuffer(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                             size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto blob = static_cast<JSBlob::BlobInstance *>(JSObjectGetPrivate(thisObject));
  auto context = new BlobPromiseContext();
  context->blobInstance = blob;
  JSObjectCallAsFunctionCallback callback = [](JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                               size_t argumentCount, const JSValueRef arguments[],
                                               JSValueRef *exception) -> JSValueRef {
    auto blobContext = reinterpret_cast<BlobPromiseContext *>(JSObjectGetPrivate(function));
    const JSValueRef resolveValueRef = arguments[0];

    JSObjectRef resolveObjectRef = JSValueToObject(ctx, resolveValueRef, exception);
    auto buffer = JSObjectMakeArrayBufferWithBytesNoCopy(
      ctx, blobContext->blobInstance->bytes(), blobContext->blobInstance->size(),
      [](void *bytes, void *deallocatorContext) {}, nullptr, exception);
    const JSValueRef resolveArgs[] = {buffer};
    JSObjectCallAsFunction(ctx, resolveObjectRef, thisObject, 1, resolveArgs, exception);
    return nullptr;
  };

  return JSObjectMakePromise(blob->context, context, callback, exception);
}

JSBlob::BlobInstance::~BlobInstance() {
}

uint8_t *JSBlob::BlobInstance::bytes() {
  return _data.data();
}

int32_t JSBlob::BlobInstance::size() {
  return _data.size();
}

JSValueRef JSBlob::BlobInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto &propertyMap = getBlobPropertyMap();
  auto &prototypePropertyMap = getBlobPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSBlob>()->prototypeObject, nameStringHolder.getString(), exception);
  };

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case BlobProperty::type: {
      JSStringRef typeStringRef = JSStringCreateWithUTF8CString(mimeType.empty() ? "" : mimeType.c_str());
      return JSValueMakeString(_hostClass->ctx, typeStringRef);
    }
    case BlobProperty::size:
      return JSValueMakeNumber(_hostClass->ctx, _size);
    }
  }

  return Instance::getProperty(name, exception);
}

void JSBlob::BlobInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getBlobPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : getBlobPrototypePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

void bindBlob(std::unique_ptr<JSContext> &context) {
  auto Blob = JSBlob::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Blob", Blob->classObject);
}

} // namespace kraken::binding::jsc
