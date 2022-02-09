/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKE_CONSOLE_H
#define KRAKE_CONSOLE_H

#include "bindings/qjs/script_value.h"
#include "core/executing_context.h"

namespace kraken {

class Console final {
 public:
  static void __kraken_print__(ExecutionContext* context, ScriptValue& log, ScriptValue& level, ExceptionState* exception);
};

}

#endif  // KRAKE_CONSOLE_H
