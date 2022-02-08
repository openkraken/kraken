/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_GC_VISITOR_H
#define KRAKENBRIDGE_GC_VISITOR_H

#include <quickjs/quickjs.h>

namespace kraken {

// Use GCVisitor to keep track gc managed members in C++ class.
class GCVisitor final {
 public:
  explicit GCVisitor(JSRuntime* rt, JS_MarkFunc* markFunc): m_runtime(rt), m_markFunc(markFunc) {};

  void trace(JSValue value);

 private:
  JSRuntime* m_runtime{nullptr};
  JS_MarkFunc* m_markFunc{nullptr};
};

}

#endif  // KRAKENBRIDGE_GC_VISITOR_H
