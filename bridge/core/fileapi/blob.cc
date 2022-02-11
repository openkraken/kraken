/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bindings/qjs/qjs_blob.h"
#include "blob.h"

namespace kraken {

Blob* Blob::create(JSContext* ctx) {
  return makeGarbageCollected<Blob>(ctx);
}
Blob* Blob::create(JSContext* ctx, std::vector<uint8_t>&& data) {
  return makeGarbageCollected<Blob>(ctx, std::forward<std::vector<uint8_t>>(data));
}
Blob* Blob::create(JSContext* ctx, std::vector<uint8_t>&& data, std::string& mime) {
  return makeGarbageCollected<Blob>(ctx, std::forward<std::vector<uint8_t>>(data), mime);
}

void BlobBuilder::append(ExecutingContext& context, Blob* blob) {
  std::vector<uint8_t> blobData = blob->_data;
  _data.reserve(_data.size() + blobData.size());
  _data.insert(_data.end(), blobData.begin(), blobData.end());
}

void BlobBuilder::append(ExecutingContext& context, ScriptValue& value) {
  if (value.isString()) {
    std::string str = value.toCString();
    std::vector<uint8_t> strArr(str.begin(), str.end());
    _data.reserve(_data.size() + strArr.size());
    _data.insert(_data.end(), strArr.begin(), strArr.end());
  } else if (value.isArray()) {
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

Blob::Blob(JSContext* ctx): ScriptWrappable(ctx) {}
Blob::Blob(JSContext* pContext, std::vector<uint8_t> vector) {}

}  // namespace kraken
