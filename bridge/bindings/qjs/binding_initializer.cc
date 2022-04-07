/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "binding_initializer.h"
#include "core/executing_context.h"

#include "qjs_console.h"
#include "qjs_event.h"
#include "qjs_event_target.h"
#include "qjs_module_manager.h"
#include "qjs_window.h"

namespace kraken {

void InstallBindings(ExecutingContext* context) {
  QJSWindow::installGlobalFunctions(context);
  QJSModuleManager::Install(context);
  QJSConsole::Install(context);
  QJSEventTarget::Install(context);
  QJSEvent::Install(context);
}

}  // namespace kraken
