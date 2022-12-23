/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_MODULE_MANAGER_H
#define KRAKENBRIDGE_MODULE_MANAGER_H

#include "executing_context.h"

namespace kraken::binding::qjs {

struct ModuleContext {
  JSValue callback;
  ExecutionContext* context;
  list_head link;
};

void bindModuleManager(ExecutionContext* context);
void handleInvokeModuleUnexpectedCallback(void* callbackContext, int32_t contextId, NativeString* errmsg, NativeString* json);
}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_MODULE_MANAGER_H
