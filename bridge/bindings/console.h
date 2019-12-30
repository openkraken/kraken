/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#ifndef KRAKEN_JS_BINDINGS_CONSOLE_H_
#define KRAKEN_JS_BINDINGS_CONSOLE_H_

#include "jsa.h"
#include "logging.h"

namespace kraken {
namespace binding {

void bindConsole(alibaba::jsa::JSContext *context);

} // namespace binding
} // namespace kraken

#endif // KRAKEN_JS_BINDINGS_CONSOLE_H_
