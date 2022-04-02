/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_FILEAPI_BLOB_PART_H_
#define KRAKENBRIDGE_CORE_FILEAPI_BLOB_PART_H_

#include <quickjs/quickjs.h>
#include <memory>
#include <string>
#include <utility>
#include "bindings/qjs/exception_state.h"

namespace kraken {

class Blob;

class BlobPart {
 public:
  using ImplType = std::shared_ptr<BlobPart>;

  enum class ContentType { kArrayBuffer, kArrayBufferView, kBlob, kString };

  static std::shared_ptr<BlobPart> Create(JSContext* ctx, JSValue value, ExceptionState& exception_state);

  JSValue ToQuickJS(JSContext* ctx) const;
  ContentType GetContentType() const;
  const std::string& GetString() const;
  uint8_t* GetBytes(uint32_t* length) const;
  Blob* GetBlob() const;

  explicit BlobPart(JSContext* ctx, uint8_t* arrayBuffer, uint32_t length)
      : content_type_(ContentType::kArrayBuffer), bytes_(arrayBuffer), byte_length_(length){};
  explicit BlobPart(JSContext* ctx,
                    uint8_t* buffer,
                    uint32_t length,
                    size_t byte_offset,
                    size_t byte_length,
                    size_t byte_per_element)
      : content_type_(ContentType::kArrayBufferView), bytes_(buffer), byte_length_(length){};
  explicit BlobPart(JSContext* ctx, std::string value)
      : content_type_(ContentType::kString), member_string_(std::move(value)){};
  explicit BlobPart(JSContext* ctx, Blob* blob) : content_type_(ContentType::kBlob), blob_(blob){};

 private:
  ContentType content_type_;
  std::string member_string_;
  Blob* blob_{nullptr};
  uint8_t* bytes_{nullptr};
  uint32_t byte_length_{0};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_FILEAPI_BLOB_PART_H_
