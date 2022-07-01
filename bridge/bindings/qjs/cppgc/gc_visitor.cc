/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gc_visitor.h"
#include "bindings/qjs/script_wrappable.h"

namespace kraken {

void GCVisitor::Trace(JSValue value) {
  JS_MarkValue(runtime_, value, markFunc_);
}

}  // namespace kraken
