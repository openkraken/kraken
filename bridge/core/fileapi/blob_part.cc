/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob_part.h"

namespace kraken {

std::shared_ptr<BlobPart> BlobPart::Create(JSContext* ctx, JSValue value, ExceptionState& exception_state) {
  if (JS_IsString(value)) {
    const char* buffer = JS_ToCString(ctx, value);
    auto result = std::make_shared<BlobPart>(ctx, buffer);
    JS_FreeCString(ctx, buffer);
    return result;
  }

  return nullptr;
}

JSValue BlobPart::ToQuickJS(JSContext* ctx) const{
//  switch(content_type_) {
//    case ContentType::kString: {
//      return JS_NewString(ctx, member_string_.c_str());
//    }
//    case ContentType::kBlob: {
//    }
//  }
}

}
