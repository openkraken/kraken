/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_jsc.h"
#include "foundation/logging.h"
#include "polyfill.h"

#include "dart_methods.h"
#include <atomic>
#include <cstdlib>
#include <memory>

#include "bindings/jsa/ui_manager.h"
#include "bindings/jsa/DOM/document.h"
#include "bindings/jsa/DOM/element.h"
#include "bindings/jsa/DOM/eventTarget.h"
#include "bindings/jsa/KOM/blob.h"
#include "bindings/jsa/KOM/console.h"
#include "bindings/jsa/KOM/location.h"
#include "bindings/jsa/KOM/screen.h"
#include "bindings/jsa/KOM/timer.h"
#include "bindings/jsa/KOM/toBlob.h"
#include "bindings/jsa/KOM/window.h"
#include "bindings/jsa/kraken.h"

namespace kraken {
/**
 * JSRuntime
 */
JSBridge::JSBridge(int32_t contextId, const JSExceptionHandler &handler) : contextId(contextId) {
  auto errorHandler = [handler, this](int32_t contextId, const char *errmsg) {
    handler(contextId, errmsg);
    // trigger window.onerror handler.
    const JSError &error = JSError(*context, errmsg);
    context->global()
        .getPropertyAsObject(*context, "__global_onerror_handler__")
        .getFunction(*context)
        .call(*context, Value(*context, error.value()));
  };

  context = KRAKEN_CREATE_JS_ENGINE(contextId, errorHandler, this);

    // Inject JSC global objects
  kraken::binding::jsa::bindUIManager(*context);
  kraken::binding::jsa::bindKraken(context);
  kraken::binding::jsa::bindConsole(context);
  kraken::binding::jsa::bindTimer(context);
  kraken::binding::jsa::bindBlob(context);
  kraken::binding::jsa::bindToBlob(context);
  kraken::binding::jsa::bindDocument(context);
  window_ = std::make_shared<kraken::binding::jsa::JSWindow>();
  window_->bind(context);
  screen_ = std::make_shared<kraken::binding::jsa::JSScreen>();
  screen_->bind(context);

  initKrakenPolyFill(this);
  Object promiseHandler = context->global().getPropertyAsObject(*context, "__global_unhandled_promise_handler__");
  context->setUnhandledPromiseRejectionHandler(promiseHandler);
}

#ifdef ENABLE_DEBUGGER
void JSBridge::attachDevtools() {
  assert(context_ != nullptr);
  KRAKEN_LOG(VERBOSE) << "Kraken will attach devtools ...";
  void *globalImpl = getRuntime()->globalImpl();
#ifdef IS_APPLE
  JSGlobalContextRef context = reinterpret_cast<JSGlobalContextRef>(globalImpl);
  JSC::ExecState *exec = toJS(context);
  JSC::JSLockHolder locker(exec);
  globalImpl = exec->lexicalGlobalObject();
#endif
  devtools_front_door_ =
    kraken::Debugger::FrontDoor::newInstance(reinterpret_cast<JSC::JSGlobalObject *>(globalImpl), nullptr, "127.0.0.1");
  devtools_front_door_->setup();
}

void JSBridge::detachDevtools() {
  assert(devtools_front_door_ != nullptr);
  KRAKEN_LOG(VERBOSE) << "Kraken will detach devtools ...";
  devtools_front_door_->terminate();
}
#endif // ENABLE_DEBUGGER

void JSBridge::handleUIListener(const NativeString *args) {
  for (const auto &callback : krakenUIListenerList) {
    if (callback == nullptr) {
      throw JSError(*context, "Failed to execute '__kraken_ui_listener__': can not get listener callback.");
    }

    if (!callback->getObject(*context).isFunction(*context)) {
      throw JSError(*context, "Failed to execute '__kraken_ui_listener__': callback is not a function.");
    }

    const String str = String::createFromUInt16(*context, args->string, args->length);
    callback->getObject(*context).asFunction(*context).callWithThis(*context, context->global(), str, 1);
  }
}

void JSBridge::handleModuleListener(const NativeString *args) {
  for (const auto &callback : krakenModuleListenerList) {
    if (callback == nullptr) {
      throw JSError(*context, "Failed to execute '__kraken_module_listener__': can not get callback.");
    }

    if (!callback->getObject(*context).isFunction(*context)) {
      throw JSError(*context, "Failed to execute '__kraken_module_listener__': callback is not a function.");
    }

    const String str = String::createFromUInt16(*context, args->string, args->length);
    callback->getObject(*context).asFunction(*context).callWithThis(*context, context->global(), str, 1);
  }
}

const int UI_EVENT = 0;
const int MODULE_EVENT = 1;

void JSBridge::invokeEventListener(int32_t type, const NativeString *args) {
  if (!context->isValid()) return;

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[invokeEventListener VERBOSE]: message " << args;
  }
  try {
    if (UI_EVENT == type) {
      this->handleUIListener(args);
    } else if (MODULE_EVENT == type) {
      this->handleModuleListener(args);
    }
  } catch (JSError &error) {
    handler_(*context, error);
  }
}

void JSBridge::evaluateScript(const NativeString *script, const char *url, int startLine) {
  if (!context->isValid()) return;
  binding::jsa::updateLocation(url);
  context->evaluateJavaScript(script->string, script->length, url, startLine);
}

void JSBridge::evaluateScript(const char *script, const char *url, int startLine) {
  if (!context->isValid()) return;
  binding::jsa::updateLocation(url);
  context->evaluateJavaScript(script, url, startLine);
}

JSBridge::~JSBridge() {
  if (!context->isValid()) return;
  krakenUIListenerList.clear();
  krakenModuleListenerList.clear();
}

void JSBridge::reportError(const char *errmsg) {
  handler_(context->getContextId(), errmsg);
}

} // namespace kraken
