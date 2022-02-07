/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SCRIPT_VALUE_H
#define KRAKENBRIDGE_SCRIPT_VALUE_H

#include <quickjs/quickjs.h>
#include "foundation/macros.h"

namespace kraken {

// ScriptValue is a QuickJS JSValue wrapper which hold all information to hide out QuickJS running details.
class ScriptValue final {
  KRAKEN_DISALLOW_NEW();

 public:
  explicit ScriptValue(JSContext* ctx, JSValue value) : m_ctx(ctx), m_value(value){};

 private:
  JSContext* m_ctx{nullptr};
  JSValue m_value{JS_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_SCRIPT_VALUE_H
