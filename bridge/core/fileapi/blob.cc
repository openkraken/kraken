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
//
//void BlobBuilder::append(ExecutingContext& context, Blob* blob) {
//  std::vector<uint8_t> blobData = blob->_data;
//  _data.reserve(_data.size() + blobData.size());
//  _data.insert(_data.end(), blobData.begin(), blobData.end());
//}
//
//void BlobBuilder::append(ExecutingContext& context, const std::string& value) {
//  std::vector<uint8_t> strArr(value.begin(), value.end());
//  _data.reserve(_data.size() + strArr.size());
//  _data.insert(_data.end(), strArr.begin(), strArr.end());
//}
//
//void BlobBuilder::append(ExecutingContext& context, ScriptValue value) {
//  if (value.isString()) {
//
//  } else if (value.isArray()) {
//    std::vector<ScriptValue> array = createArrayFromQuickJSArraySlow(&context, value);
//    for (auto &i : array) {
//      append(context, i);
//    }
//  } else if (value.isObject()) {
//    context.contextData()->constructorForType(Blob::getStaticWrapperTypeInfo());
//    if (value.isInstanceOf(Blob::getStaticWrapperTypeInfo())) {
//      auto blob = static_cast<Blob*>(toScriptWrappable(value.toQuickJS()));
//      if (blob == nullptr)
//        return;
//      if (std::string(blob->getHumanReadableName()) == "Blob") {
//        std::vector<uint8_t> blobData = blob->_data;
//        _data.reserve(_data.size() + blobData.size());
//        _data.insert(_data.end(), blobData.begin(), blobData.end());
//      }
//    } else {
//      size_t length;
//      uint8_t* buffer;
//      if (!value.isArrayBuffer(&buffer, &length)) {
//        size_t byte_offset;
//        size_t byte_length;
//        size_t byte_per_element;
//        ExceptionState exceptionState;
//        value.getTypedArrayBuffer(&buffer, &length, &byte_offset, &byte_length, &byte_per_element, &exceptionState);
//      }
//
//      for (size_t i = 0; i < length; i++) {
//        _data.emplace_back(buffer[i]);
//      }
//    }
//  }
//}
//
//std::vector<uint8_t> BlobBuilder::finalize() {
//  return std::move(_data);
//}

int32_t Blob::size() {
  return _data.size();
}

uint8_t* Blob::bytes() {
  return _data.data();
}

void Blob::Trace(GCVisitor* visitor) const {}
void Blob::Dispose() const {}

}  // namespace kraken
