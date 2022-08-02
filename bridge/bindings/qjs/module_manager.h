/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_MODULE_MANAGER_H
#define BRIDGE_MODULE_MANAGER_H

#include "executing_context.h"

namespace webf::binding::qjs {

struct ModuleContext {
  JSValue callback;
  ExecutionContext* context;
  list_head link;
};

void bindModuleManager(ExecutionContext* context);
void handleInvokeModuleUnexpectedCallback(void* callbackContext, int32_t contextId, NativeString* errmsg, NativeString* json);
}  // namespace webf::binding::qjs

#endif  // BRIDGE_MODULE_MANAGER_H
