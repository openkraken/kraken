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
  static std::unique_ptr<NativeString> __kraken_invoke_module__(ExecutingContext* context, std::unique_ptr<NativeString>& moduleName, std::unique_ptr<NativeString>& method, ExceptionState& exception);
  static std::unique_ptr<NativeString> __kraken_invoke_module__(ExecutingContext* context,
                                                                std::unique_ptr<NativeString>& moduleName,
                                                                std::unique_ptr<NativeString>& method,
                                                                ScriptValue& params,
                                                                ExceptionState& exception);
  static std::unique_ptr<NativeString> __kraken_invoke_module__(ExecutingContext* context,
                                                                std::unique_ptr<NativeString>& moduleName,
                                                                std::unique_ptr<NativeString>& method,
                                                                ScriptValue& params,
                                                                std::shared_ptr<QJSFunction> callback,
                                                                ExceptionState& exception);
  static void __kraken_add_module_listener__(ExecutingContext* context, const std::shared_ptr<QJSFunction>& handler, ExceptionState& exception);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MODULE_MANAGER_H
