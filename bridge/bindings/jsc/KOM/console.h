/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BINDINGS_CONSOLE_H_
#define KRAKEN_JS_BINDINGS_CONSOLE_H_

#include "bindings/jsc/js_context_internal.h"
#include "foundation/logging.h"
#include <memory>

namespace kraken::binding::jsc {

void bindConsole(std::unique_ptr<JSContext> &context);

} // namespace kraken

#endif // KRAKEN_JS_BINDINGS_CONSOLE_H_
