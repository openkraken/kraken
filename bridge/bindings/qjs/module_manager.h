/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MODULE_MANAGER_H
#define KRAKENBRIDGE_MODULE_MANAGER_H

#include "js_context.h"

namespace kraken::binding::qjs {

struct ModuleContext {
  JSValue callback;
  PageJSContext* context;
  list_head link;
};

void bindModuleManager(std::unique_ptr<PageJSContext>& context);
void handleInvokeModuleUnexpectedCallback(void* callbackContext, int32_t contextId, NativeString* errmsg, NativeString* json);
}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_MODULE_MANAGER_H
