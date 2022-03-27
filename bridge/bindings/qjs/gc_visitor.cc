/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gc_visitor.h"
#include "garbage_collected.h"

namespace kraken {

void GCVisitor::Trace(ScriptWrappable* target) {
  if (target != nullptr) {
    JS_MarkValue(runtime_, target->ToQuickJS(), markFunc_);
  }
}

}  // namespace kraken
