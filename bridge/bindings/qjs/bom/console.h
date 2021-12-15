/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CONSOLE_H
#define KRAKENBRIDGE_CONSOLE_H

#include "bindings/qjs/executing_context.h"

namespace kraken::binding::qjs {

void bindConsole(std::unique_ptr<ExecutionContext>& context);

}

#endif  // KRAKENBRIDGE_CONSOLE_H
