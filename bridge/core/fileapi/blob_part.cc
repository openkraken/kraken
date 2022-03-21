/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob_part.h"
#include "qjs_blob.h"

namespace kraken {

std::shared_ptr<BlobPart> BlobPart::Create(JSContext* ctx, JSValue value, ExceptionState& exception_state) {
  auto* context = ExecutingContext::From(ctx);
  // Create from string.
  if (JS_IsString(value)) {
    const char* buffer = JS_ToCString(ctx, value);
    auto result = std::make_shared<BlobPart>(ctx, buffer);
    JS_FreeCString(ctx, buffer);
    return result;
  }

  // Create from another blob
  if (QJSBlob::HasInstance(context, value)) {
    Blob* qjs_value = toScriptWrappable<Blob>(value);
    return std::make_shared<BlobPart>(ctx, qjs_value);
  }

  if (JS_IsArrayBuffer(value)) {
    size_t length;
    uint8_t* buffer = JS_GetArrayBuffer(ctx, &length, value);
    return std::make_shared<BlobPart>(ctx, buffer, length);
  }

  if (JS_IsArrayBufferView(value)) {
    size_t byte_offset;
    size_t byte_length;
    size_t byte_per_element;
    size_t length;
    uint8_t* buffer;
    JSValue arrayBufferObject = JS_GetTypedArrayBuffer(ctx, value, &byte_offset, &byte_length, &byte_per_element);
    if (JS_IsException(arrayBufferObject)) {
      exception_state.ThrowException(ctx, arrayBufferObject);
      return nullptr;
    }
    buffer = JS_GetArrayBuffer(ctx, &length, arrayBufferObject);
    return std::make_shared<BlobPart>(ctx, buffer, length, byte_offset, byte_length, byte_per_element);
  }

  return nullptr;
}

JSValue BlobPart::ToQuickJS(JSContext* ctx) const {
  switch(content_type_) {
    case ContentType::kString: {
      return JS_NewString(ctx, member_string_.c_str());
    }
    case ContentType::kBlob: {
      return blob_->ToQuickJS();
    }
    case ContentType::kArrayBuffer: {
      return JS_NewArrayBufferCopy(ctx, bytes_, byte_length_);
    }
    case ContentType::kArrayBufferView: {
      // TODO: Create ArrayBufferView from QuickJS API is not support now.
      return JS_NULL;
    }
  }
}

BlobPart::ContentType BlobPart::GetContentType() const {
  return content_type_;
}

const std::string& BlobPart::GetString() const {
  return member_string_;
}

uint8_t* BlobPart::GetBytes(uint32_t* length) const {
  *length = byte_length_;
  return bytes_;
}

Blob* BlobPart::GetBlob() const {
  return blob_;
}

}
