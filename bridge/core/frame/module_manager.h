/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MODULE_MANAGER_H
#define KRAKENBRIDGE_MODULE_MANAGER_H

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/qjs_function.h"
#include "module_callback.h"

namespace kraken {

class ModuleManager {
 public:
  static ScriptValue invokeModule(ExecutionContext* context, ScriptValue& moduleName, ScriptValue& method, ScriptValue& params, QJSFunction* callback, ExceptionState* exception);
  static void addModuleListener(ExecutionContext* context, QJSFunction* handler, ExceptionState* exception);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_MANAGER_H
