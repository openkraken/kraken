/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_blob_property_bag.h"

namespace kraken {

BlobPropertyBag* BlobPropertyBag::create(ExecutingContext* context, JSValue value, ExceptionState* exceptionState) {
  BlobPropertyBag* dictionary = new BlobPropertyBag();

  if (JS_IsUndefined(value)) {

  }
  return nullptr;
}

void BlobPropertyBag::fillMemberFromQuickjsObject(ExecutingContext* context, JSValue value, ExceptionState* exceptionState) {

}

}
