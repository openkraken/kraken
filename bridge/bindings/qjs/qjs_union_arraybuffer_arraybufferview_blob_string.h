/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_QJS_UNION_ARRAYBUFFER_ARRAYBUFFERVIEW_BLOB_STRING_H
#define KRAKENBRIDGE_QJS_UNION_ARRAYBUFFER_ARRAYBUFFERVIEW_BLOB_STRING_H

#include <quickjs/quickjs.h>
#include <memory>

#include "core/fileapi/blob.h"
#include "exception_state.h"
#include "ts_type.h"
#include "converter_impl.h"

namespace kraken {

class QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString {
 public:
  enum class ContentType {
    kArrayBuffer, kArrayBufferView, kBlob, kString
  };

  static std::shared_ptr<QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString> Create(
    JSContext* ctx,
    JSValue value,
    ExceptionState& exception_state);

  JSValue ToQuickJS(JSContext* ctx) const;

  explicit QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString(JSContext* ctx, uint8_t* arrayBuffer, uint32_t length): content_type_(ContentType::kArrayBuffer) {};
  explicit QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString(JSContext* ctx, uint8_t* buffer, size_t byte_offset, size_t byte_length, size_t byte_per_element, uint32_t length): content_type_(ContentType::kArrayBufferView) {};
  explicit QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString(JSContext* ctx, const std::string& value): content_type_(ContentType::kString), member_string_(value) {};
  explicit QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString(JSContext* ctx, Blob* blob): content_type_(ContentType::kBlob) {};

private:
  ContentType content_type_;
  std::string member_string_;
  uint32_t* bytes{nullptr};
};

// Special types
struct TSUnionArrayBufferOrArrayBufferViewOrBlobOrString : public TSTypeBaseHelper<std::shared_ptr<QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString>> {
  using ImplType = typename std::shared_ptr<QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString>;
};

template <>
struct Converter<TSUnionArrayBufferOrArrayBufferViewOrBlobOrString> : public ConverterBase<TSUnionArrayBufferOrArrayBufferViewOrBlobOrString> {
  using ImplType = TSUnionArrayBufferOrArrayBufferViewOrBlobOrString::ImplType;
  static ImplType FromValue(JSContext* ctx, JSValue value, ExceptionState& exception_state) {
    assert(!JS_IsException(value));
    return QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString::Create(ctx, value, exception_state);
  }

  static JSValue ToValue(JSContext* ctx, QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString* data) { return data->ToQuickJS(ctx); }
};

}

class qjs_union_arraybuffer_arraybufferview_blob_string {};

#endif  // KRAKENBRIDGE_QJS_UNION_ARRAYBUFFER_ARRAYBUFFERVIEW_BLOB_STRING_H
