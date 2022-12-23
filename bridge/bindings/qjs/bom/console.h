/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CONSOLE_H
#define KRAKENBRIDGE_CONSOLE_H

#include "bindings/qjs/executing_context.h"

namespace kraken::binding::qjs {

void bindConsole(ExecutionContext* context);

}

#endif  // KRAKENBRIDGE_CONSOLE_H
