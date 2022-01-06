/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WRAPPER_TYPE_INFO_H
#define KRAKENBRIDGE_WRAPPER_TYPE_INFO_H

#include <quickjs/quickjs.h>
#include <assert.h>
#include "bindings/qjs/qjs_patch.h"
#include "include/kraken_foundation.h"

namespace kraken::binding::qjs {

// This struct provides a way to store a bunch of information that is helpful
// when creating quickjs objects. Each quickjs bindings class has exactly one static
// WrapperTypeInfo member, so comparing pointers is a safe way to determine if
// types match.
class WrapperTypeInfo final {
 public:
  bool equals(const WrapperTypeInfo* that) const { return this == that; }

  bool isSubclass(const WrapperTypeInfo* that) const {
    for (const WrapperTypeInfo* current = this; current;
         current = current->parent_class) {
      if (current == that)
        return true;
    }
    return false;
  }

  const char* className;
  const WrapperTypeInfo* parent_class;
  JSClassCall* callFunc;

  JSClassID classId{0};
};

}

#endif  // KRAKENBRIDGE_WRAPPER_TYPE_INFO_H
