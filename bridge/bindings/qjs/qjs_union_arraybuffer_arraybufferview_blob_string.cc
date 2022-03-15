/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_union_arraybuffer_arraybufferview_blob_string.h"

namespace kraken {

std::shared_ptr<QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString> QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString::Create(JSContext* ctx, JSValue value, ExceptionState& exception_state) {
  if (JS_IsString(value)) {
    const char* buffer = JS_ToCString(ctx, value);
    auto result = std::make_shared<QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString>(ctx, buffer);
    JS_FreeCString(ctx, buffer);
    return result;
  }

  return nullptr;
}

JSValue QJSUnionArrayBufferOrArrayBufferViewOrBlobOrString::ToQuickJS(JSContext* ctx) const{
  switch(content_type_) {
    case ContentType::kString: {
      return JS_NewString(ctx, member_string_.c_str());
    }
    case ContentType::kBlob: {
    }
  }
}

}
