/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob.h"
#include "bindings/jsc/macros.h"
#include "foundation/logging.h"

namespace kraken::binding::jsc {

void BlobBuilder::append(JSContext &context, JSStringRef text) {
  size_t length = JSStringGetMaximumUTF8CStringSize(text);
  char buffer[length];
  JSStringGetUTF8CString(text, buffer, length);

  for (size_t i = 0; i < length; i++) {
    _data.emplace_back(buffer[i]);
  }
}

void BlobBuilder::append(JSContext &context, JSBlob *blob) {
  std::vector<uint8_t> blobData = blob->_data;
  _data.reserve(_data.size() + blobData.size());
  _data.insert(_data.end(), blobData.begin(), blobData.end());
}

void BlobBuilder::append(JSContext &context, const JSValueRef value, JSValueRef *exception) {
  if (JSValueIsString(context.context(), value)) {
    append(context, JSValueToStringCopy(context.context(), value, exception));
  } else if (JSValueIsArray(context.context(), value)) {
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
      JSObjectRef array = JSValueToObject(context.context(), value, exception);
      JSValueRef lengthValue =
        JSObjectGetProperty(context.context(), array, JSStringCreateWithUTF8CString("length"), exception);
      size_t length = JSValueToNumber(context.context(), lengthValue, exception);

      for (size_t i = 0; i < length; i++) {
        JSValueRef v = JSObjectGetPropertyAtIndex(context.context(), array, i, exception);
        append(context, v, exception);
      }
    }
  } else if (JSValueIsObject(context.context(), value)) {
    auto blob = static_cast<JSBlob *>(JSObjectGetPrivate(JSValueToObject(context.context(), value, exception)));
    if (blob == nullptr) {
      return;
    }

    if (std::string(blob->name) == JSBlobName) {
      std::vector<uint8_t> blobData = blob->_data;
      _data.reserve(_data.size() + blobData.size());
      _data.insert(_data.end(), blobData.begin(), blobData.end());
    }
  }
}

std::vector<uint8_t> BlobBuilder::finalize() {
  return std::move(_data);
}

uint8_t *JSBlob::bytes() {
  return _data.data();
}

int32_t JSBlob::size() {
  return _data.size();
}

JSValueRef JSBlob::constructor(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  BlobBuilder builder;
  auto context = static_cast<JSContext *>(JSObjectGetPrivate(function));
  if (argumentCount == 0) {
    auto blob = new JSBlob(context);
    return JSObjectMake(ctx, blob->object, blob);
  }

  const JSValueRef &arrayValue = arguments[0];
  const JSValueRef &optionValue = arguments[1];

  if (!JSValueIsArray(ctx, arrayValue)) {
    JSC_THROW_ERROR(ctx, "Failed to construct 'Blob': The provided value cannot be converted to a sequence", exception);
    return nullptr;
  }

  if (JSValueIsUndefined(ctx, optionValue)) {
    builder.append(*context, arrayValue, exception);
    auto blob = new JSBlob(context, builder.finalize());
    return JSObjectMake(ctx, blob->object, blob);
  }

  if (!JSValueIsObject(ctx, optionValue)) {
    JSC_THROW_ERROR(ctx,
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
  auto blob = new JSBlob(context, builder.finalize(), JSStringToStdString(mineTypeStringRef));
  return JSObjectMake(ctx, blob->object, blob);
}

JSValueRef JSBlob::slice(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef startValueRef = arguments[0];
  const JSValueRef endValueRef = arguments[1];
  const JSValueRef contentTypeValueRef = arguments[2];

  auto blob = static_cast<JSBlob *>(JSObjectGetPrivate(function));
  size_t start = 0;
  size_t end = blob->_data.size();
  std::string mimeType = blob->mimeType;

  if (!JSValueIsUndefined(ctx, startValueRef)) {
    start = JSValueToNumber(ctx, startValueRef, exception);
  }

  if (!JSValueIsUndefined(ctx, endValueRef)) {
    end = JSValueToNumber(ctx, endValueRef, exception);
  }

  if (!JSValueIsUndefined(ctx, contentTypeValueRef)) {
    JSStringRef contentTypeStringRef = JSValueToStringCopy(ctx, contentTypeValueRef, exception);
    mimeType = JSStringToStdString(contentTypeStringRef);
    JSStringRelease(contentTypeStringRef);
  }

  if (start == 0 && end == blob->_data.size()) {
    auto newBlob = new JSBlob(blob->context, std::move(blob->_data), mimeType);
    return JSObjectMake(ctx, newBlob->object, newBlob);
  }

  std::vector<uint8_t> newData;
  newData.reserve(blob->_data.size() - (end - start));
  newData.insert(newData.begin(), blob->_data.begin() + start, blob->_data.end() - (blob->_data.size() - end));

  auto newBlob = new JSBlob(blob->context, std::move(newData), mimeType);
  return JSObjectMake(ctx, newBlob->object, newBlob);
}

JSValueRef JSBlob::text(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                        const JSValueRef *arguments, JSValueRef *exception) {
  auto blob = static_cast<JSBlob *>(JSObjectGetPrivate(function));
  std::string newString(reinterpret_cast<const char *>(blob->_data.data()), blob->_data.size());
  JSStringRef newStringRef = JSStringCreateWithUTF8CString(newString.c_str());
  return JSValueMakeString(ctx, newStringRef);
}

JSValueRef JSBlob::arrayBuffer(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  auto blob = static_cast<JSBlob *>(JSObjectGetPrivate(function));
  auto buffer = JSObjectMakeArrayBufferWithBytesNoCopy(
    ctx, blob->bytes(), blob->size(), [](void *bytes, void *deallocatorContext) {}, nullptr, exception);
  return buffer;
}

JSValueRef JSBlob::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);

  if (name == "slice") {
    return JSBlob::propertyBindingFunction(context, this, "slice", slice);
  } else if (name == "text") {
    return JSBlob::propertyBindingFunction(context, this, "text", text);
  } else if (name == "arrayBuffer") {
    return JSBlob::propertyBindingFunction(context, this, "arrayBuffer", arrayBuffer);
  }

  return nullptr;
}

void JSBlob::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &propertyName : propertyNames) {
    JSPropertyNameAccumulatorAddName(accumulator, propertyName);
  }
}

JSBlob::~JSBlob() {
  for (auto &propertyName : propertyNames) {
    JSStringRelease(propertyName);
  }
}

void bindBlob(std::unique_ptr<JSContext> &context) {
  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_blob__", JSBlob::constructor);
}

} // namespace kraken::binding::jsc
