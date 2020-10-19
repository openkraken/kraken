/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JS_BINDINGS_CONSOLE_H_
#define KRAKEN_JS_BINDINGS_CONSOLE_H_

#include "jsa.h"
#include "logging.h"
#include <memory>

namespace kraken {
namespace binding {
namespace jsa {
using namespace alibaba::jsa;

void bindConsole(std::unique_ptr<JSContext> &context);

}
} // namespace binding
} // namespace kraken

#endif // KRAKEN_JS_BINDINGS_CONSOLE_H_
