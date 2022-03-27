/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_GC_VISITOR_H
#define KRAKENBRIDGE_GC_VISITOR_H

#include <quickjs/quickjs.h>
#include "script_wrappable.h"

namespace kraken {

class GarbageCollected;

// Use GCVisitor to keep track gc managed members in C++ class.
class GCVisitor final {
 public:
  explicit GCVisitor(JSRuntime* rt, JS_MarkFunc* markFunc) : runtime_(rt), markFunc_(markFunc){};

  void Trace(ScriptWrappable* target);

 private:
  JSRuntime* runtime_{nullptr};
  JS_MarkFunc* markFunc_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_GC_VISITOR_H
