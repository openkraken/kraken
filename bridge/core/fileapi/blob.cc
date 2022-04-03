/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob.h"
#include <string>
#include "bindings/qjs/script_promise_resolver.h"
#include "core/executing_context.h"
#include "built_in_string.h"

namespace kraken {

class BlobReaderClient {
 public:
  enum ReadType { kReadAsText, kReadAsArrayBuffer };

  BlobReaderClient(ExecutingContext* context, Blob* blob, ScriptPromiseResolver* resolver, ReadType read_type)
      : context_(context), blob_(blob), resolver_(resolver), read_type_(read_type) {
    Start();
  };

  void Start();
  void DidFinishLoading();

 private:
  ExecutingContext* context_;
  Blob* blob_;
  ScriptPromiseResolver* resolver_;
  ReadType read_type_;
};

void BlobReaderClient::Start() {
  // Use setTimeout to simulate async data loading.
  // TODO: Blob are part of File API in W3C standard, but not supported by Kraken from now on.
  // Needs to remove this after File API had landed.
  auto callback = [](void* ptr, int32_t contextId, const char* errmsg) -> void {
    auto* client = static_cast<BlobReaderClient*>(ptr);
    client->DidFinishLoading();
  };
  context_->dartMethodPtr()->setTimeout(this, context_->contextId(), callback, 0);
}

void BlobReaderClient::DidFinishLoading() {
  if (read_type_ == ReadType::kReadAsText) {
    resolver_->Resolve<std::string>(blob_->StringResult());
  } else if (read_type_ == ReadType::kReadAsArrayBuffer) {
    resolver_->Resolve<ArrayBufferData>(blob_->ArrayBufferResult());
  }
  delete this;
}

Blob* Blob::Create(ExecutingContext* context) {
  return makeGarbageCollected<Blob>(context->ctx());
}

Blob* Blob::Create(ExecutingContext* context,
                   std::vector<std::shared_ptr<BlobPart>>& data,
                   ExceptionState& exception_state) {
  return makeGarbageCollected<Blob>(context->ctx(), data);
}

Blob* Blob::Create(ExecutingContext* context,
                   std::vector<std::shared_ptr<BlobPart>>& data,
                   std::shared_ptr<BlobPropertyBag> property,
                   ExceptionState& exception_state) {
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
  return slice(start, end, AtomicString::Empty(ctx()), exception_state);
}
Blob* Blob::slice(int64_t start,
                  int64_t end,
                  const AtomicString& content_type,
                  ExceptionState& exception_state) {
  auto* newBlob = makeGarbageCollected<Blob>(ctx());
  std::vector<uint8_t> newData;
  newData.reserve(_data.size() - (end - start));
  newData.insert(newData.begin(), _data.begin() + start, _data.end() - (_data.size() - end));
  newBlob->_data = newData;
  newBlob->mime_type_ = content_type != built_in_string::kempty_string ? content_type.ToStdString() : mime_type_;
  return newBlob;
}

std::string Blob::StringResult() {
  return std::string(bytes(), bytes() + size());
}

ArrayBufferData Blob::ArrayBufferResult() {
  return ArrayBufferData{bytes(), size()};
}

std::string Blob::type() {
  return mime_type_;
}

ScriptPromise Blob::arrayBuffer(ExceptionState& exception_state) {
  auto* resolver = ScriptPromiseResolver::Create(GetExecutingContext());
  new BlobReaderClient(GetExecutingContext(), this, resolver, BlobReaderClient::ReadType::kReadAsArrayBuffer);
  return resolver->Promise();
}

ScriptPromise Blob::text(ExceptionState& exception_state) {
  auto* resolver = ScriptPromiseResolver::Create(GetExecutingContext());
  new BlobReaderClient(GetExecutingContext(), this, resolver, BlobReaderClient::ReadType::kReadAsText);
  return resolver->Promise();
}

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
