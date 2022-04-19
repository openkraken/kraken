/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gc_visitor.h"
#include "script_wrappable.h"

namespace kraken {

void GCVisitor::Trace(ScriptWrappable* target) {
  if (target != nullptr) {
    JS_MarkValue(runtime_, target->jsObject_, markFunc_);
  }
}

void GCVisitor::Trace(JSValue value) {
  JS_MarkValue(runtime_, value, markFunc_);
}

}  // namespace kraken
