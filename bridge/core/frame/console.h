/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKE_CONSOLE_H
#define KRAKE_CONSOLE_H

#include "bindings/qjs/script_value.h"
#include "bindings/qjs/atom_string.h"
#include "core/executing_context.h"

namespace kraken {

class Console final {
 public:
  static void __kraken_print__(ExecutingContext* context,
                               const AtomicString& log,
                               const AtomicString& level,
                               ExceptionState& exception);
  static void __kraken_print__(ExecutingContext* context,
                               const AtomicString& log,
                               ExceptionState& exception_state);
};

}  // namespace kraken

#endif  // KRAKE_CONSOLE_H
