/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WRAPPER_TYPE_INFO_H
#define KRAKENBRIDGE_WRAPPER_TYPE_INFO_H

#include <assert.h>
#include <quickjs/quickjs.h>
#include "bindings/qjs/qjs_engine_patch.h"

namespace kraken {

enum { JS_CLASS_GC_TRACKER = JS_CLASS_INIT_COUNT + 1, JS_CLASS_BLOB };

// This struct provides a way to store a bunch of information that is helpful
// when creating quickjs objects. Each quickjs bindings class has exactly one static
// WrapperTypeInfo member, so comparing pointers is a safe way to determine if
// types match.
class WrapperTypeInfo final {
 public:
  bool equals(const WrapperTypeInfo* that) const { return this == that; }

  bool isSubclass(const WrapperTypeInfo* that) const {
    for (const WrapperTypeInfo* current = this; current; current = current->parent_class) {
      if (current == that)
        return true;
    }
    return false;
  }

  JSClassID classId{0};
  const char* className{nullptr};
  const WrapperTypeInfo* parent_class{nullptr};
  JSClassCall* callFunc{nullptr};
  JSClassExoticMethods* exoticMethods{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_WRAPPER_TYPE_INFO_H
