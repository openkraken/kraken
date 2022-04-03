/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MODULE_MANAGER_H
#define KRAKENBRIDGE_MODULE_MANAGER_H

#include "bindings/qjs/atom_string.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/qjs_function.h"
#include "module_callback.h"

namespace kraken {

class ModuleManager {
 public:
  static AtomicString __kraken_invoke_module__(ExecutingContext* context,
                                               const AtomicString& moduleName,
                                               const AtomicString& method,
                                               ExceptionState& exception);
  static AtomicString __kraken_invoke_module__(ExecutingContext* context,
                                               const AtomicString& moduleName,
                                               const AtomicString& method,
                                               ScriptValue& params,
                                               ExceptionState& exception);
  static AtomicString __kraken_invoke_module__(ExecutingContext* context,
                                               const AtomicString& moduleName,
                                               const AtomicString& method,
                                               ScriptValue& params,
                                               std::shared_ptr<QJSFunction> callback,
                                               ExceptionState& exception);
  static void __kraken_add_module_listener__(ExecutingContext* context,
                                             const std::shared_ptr<QJSFunction>& handler,
                                             ExceptionState& exception);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_MANAGER_H
