/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CALLBACK_CONTEXT_H
#define KRAKENBRIDGE_CALLBACK_CONTEXT_H

#include "jsa.h"

namespace kraken {
namespace foundation {

using namespace alibaba::jsa;

struct CallbackContext {
  CallbackContext(JSContext &context, std::shared_ptr<Value> callback)
    : _context(context), _callback(std::move(callback)){};

  JSContext &_context;
  std::shared_ptr<Value> _callback;
};

} // namespace foundation
} // namespace kraken

#endif // KRAKENBRIDGE_CALLBACK_CONTEXT_H
