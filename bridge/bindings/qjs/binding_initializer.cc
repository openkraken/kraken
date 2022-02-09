/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "binding_initializer.h"

#include "qjs_console.h"
#include "qjs_module_manager.h"
#include "qjs_window.h"

namespace kraken {

void installBindings(JSContext* ctx) {
  QJSWindow::installGlobalFunctions(ctx);
  QJSModuleManager::installGlobalFunctions(ctx);
  QJSConsole::install(ctx);
}

}  // namespace kraken
