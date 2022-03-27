/*
 * Copyright (C) 2022 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dictionary_base.h"

namespace kraken {

JSValue DictionaryBase::toQuickJS(JSContext* ctx) const {
  JSValue object = JS_NewObject(ctx);
  if (!FillQJSObjectWithMembers(ctx, object)) {
    return JS_NULL;
  }
  return object;
}

}  // namespace kraken
