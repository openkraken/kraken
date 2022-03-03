/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_QJS_UNION_ARRAYBUFFER_ARRAYBUFFERVIEW_BLOB_STRING_H
#define KRAKENBRIDGE_QJS_UNION_ARRAYBUFFER_ARRAYBUFFERVIEW_BLOB_STRING_H

#include <quickjs/quickjs.h>

#include "core/fileapi/blob.h"
#include "exception_state.h"

namespace kraken {

class QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString {
 public:
  enum class ContentType {
    kArrayBuffer, kArrayBufferView, kBlob, kString
  };

  static QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString* Create(
    JSContext* ctx,
    JSValue value,
    ExceptionState& exception_state);

  explicit QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString(JSContext* ctx, uint8_t* arrayBuffer, uint32_t length): content_type_(ContentType::kArrayBuffer) {};
  explicit QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString(JSContext* ctx, const std::string& value): content_type_(ContentType::kString) {};
  explicit QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString(JSContext* ctx, Blob* blob): content_type_(ContentType::kBlob) {};

private:
  ContentType content_type_;
  std::string member_string_;
  uint32_t* bytes;
};

}

class qjs_union_arraybuffer_arraybufferview_blob_string {};

#endif  // KRAKENBRIDGE_QJS_UNION_ARRAYBUFFER_ARRAYBUFFERVIEW_BLOB_STRING_H
