/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_GC_VISITOR_H
#define KRAKENBRIDGE_GC_VISITOR_H

#include <quickjs/quickjs.h>
#include "foundation/macros.h"

namespace kraken {

class ScriptWrappable;

// Use GCVisitor to keep track gc managed members in C++ class.
class GCVisitor final {
  KRAKEN_DISALLOW_NEW();
  KRAKEN_DISALLOW_IMPLICIT_CONSTRUCTORS(GCVisitor);

 public:
  explicit GCVisitor(JSRuntime* rt, JS_MarkFunc* markFunc) : runtime_(rt), markFunc_(markFunc){};

  void Trace(ScriptWrappable* target);
  void Trace(JSValue value);

 private:
  JSRuntime* runtime_{nullptr};
  JS_MarkFunc* markFunc_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_GC_VISITOR_H
