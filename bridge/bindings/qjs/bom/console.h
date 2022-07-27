/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CONSOLE_H
#define BRIDGE_CONSOLE_H

#include "bindings/qjs/executing_context.h"

namespace webf::binding::qjs {

void bindConsole(ExecutionContext* context);

}

#endif  // BRIDGE_CONSOLE_H
