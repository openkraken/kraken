/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob_property_bag.h"

namespace kraken {

std::shared_ptr<BlobPropertyBag> BlobPropertyBag::Create(JSContext* ctx, JSValue value, ExceptionState& exceptionState) {
  auto bag = std::make_shared<BlobPropertyBag>();
  bag->FillMemberFromQuickjsObject(ctx, value, exceptionState);
  return nullptr;
}

void BlobPropertyBag::FillMemberFromQuickjsObject(JSContext* ctx, JSValue value, ExceptionState& exceptionState) {
  if (!JS_IsObject(value)) {
    return;
  }

  JSValue typeValue = JS_GetPropertyStr(ctx, value, "type");
  const char* ctype = JS_ToCString(ctx, typeValue);
  m_type = std::string(ctype);

  JS_FreeCString(ctx, ctype);
  JS_FreeValue(ctx, typeValue);
}

}  // namespace kraken
