/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob.h"
#include "bindings/qjs/script_promise_resolver.h"

namespace kraken {

Blob* Blob::Create(ExecutingContext* context) {
  return makeGarbageCollected<Blob>(context->ctx());
}

Blob* Blob::Create(ExecutingContext* context, std::vector<std::shared_ptr<BlobPart>>& data, ExceptionState& exception_state) {
  return makeGarbageCollected<Blob>(context->ctx(), data);
}

Blob* Blob::Create(ExecutingContext* context, std::vector<std::shared_ptr<BlobPart>>& data, std::shared_ptr<BlobPropertyBag> property, ExceptionState& exception_state) {
  return makeGarbageCollected<Blob>(context->ctx(), data, property);
}

int32_t Blob::size() {
  return _data.size();
}

uint8_t* Blob::bytes() {
  return _data.data();
}

const char* Blob::GetHumanReadableName() const {
  return "Blob";
}
void Blob::Trace(GCVisitor* visitor) const {}
void Blob::Dispose() const {}

Blob* Blob::slice(ExceptionState& exception_state) {
  return slice(0, _data.size(), exception_state);
}
Blob* Blob::slice(int64_t start, ExceptionState& exception_state) {
  return slice(start, _data.size(), exception_state);
}
Blob* Blob::slice(int64_t start, int64_t end, ExceptionState& exception_state) {
  std::unique_ptr<NativeString> contentType = nullptr;
  return slice(start, end, contentType, exception_state);
}
Blob* Blob::slice(int64_t start, int64_t end, std::unique_ptr<NativeString>& content_type, ExceptionState& exception_state) {
  auto* newBlob = makeGarbageCollected<Blob>(ctx());
  std::vector<uint8_t> newData;
  newData.reserve(_data.size() - (end - start));
  newData.insert(newData.begin(), _data.begin() + start, _data.end() - (_data.size() - end));
  newBlob->_data = newData;
  newBlob->mime_type_ = content_type != nullptr ? nativeStringToStdString(content_type.get()) : mime_type_;
  return newBlob;
}

std::string Blob::type() {
  return mime_type_;
}

ScriptPromise Blob::arrayBuffer() {
}

ScriptPromise Blob::text() {}

void Blob::PopulateBlobData(std::vector<std::shared_ptr<BlobPart>>& data) {
  for (auto& item : data) {
    switch (item->GetContentType()) {
      case BlobPart::ContentType::kString: {
        AppendText(item->GetString());
        break;
      }
      case BlobPart::ContentType::kArrayBuffer:
      case BlobPart::ContentType::kArrayBufferView: {
        uint32_t length;
        uint8_t* buffer = item->GetBytes(&length);
        AppendBytes(buffer, length);
        break;
      }
      case BlobPart::ContentType::kBlob: {
        AppendBytes(item->GetBlob()->bytes(), item->GetBlob()->size());
        break;
      }
    }
  }
}

void Blob::AppendText(const std::string& string) {
  std::vector<uint8_t> strArr(string.begin(), string.end());
  _data.reserve(_data.size() + strArr.size());
  _data.insert(_data.end(), strArr.begin(), strArr.end());
}

void Blob::AppendBytes(uint8_t* buffer, uint32_t length) {
  _data.reserve(_data.size() + length);
  for (size_t i = 0; i < length; i++) {
    _data.emplace_back(buffer[i]);
  }
}

}  // namespace kraken
