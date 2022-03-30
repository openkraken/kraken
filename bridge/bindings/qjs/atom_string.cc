/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "atom_string.h"

namespace kraken {

JSValue StaticAtomicString::ToQuickJS(JSContext* ctx) const {
  return JS_AtomToValue(ctx, atom_);
}


}  // namespace kraken
