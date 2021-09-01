/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_UI_MANAGER_H
#define KRAKENBRIDGE_UI_MANAGER_H

#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {
void handleInvokeModuleUnexpectedCallback(void *callbackContext, int32_t contextId, NativeString *errmsg,
                                          NativeString *json);
void bindUIManager(std::unique_ptr<JSContext> &context);
}

#endif // KRAKENBRIDGE_UI_MANAGER_H
