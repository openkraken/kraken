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

namespace kraken {
/**
 * JSRuntime
 */
JSBridge::JSBridge(int32_t contextId, const JSExceptionHandler &handler) : contextId(contextId) {
  auto errorHandler = [handler, this](int32_t contextId, const char *errmsg) {
    handler(contextId, errmsg);
    // trigger window.onerror handler.
    JSStringRef errmsgStringRef = JSStringCreateWithUTF8CString(errmsg);
    const JSValueRef errorArguments[] = {JSValueMakeString(context->context(), errmsgStringRef)};
    JSValueRef exception = nullptr;
    JSObjectRef errorObject = JSObjectMakeError(context->context(), 1, errorArguments, &exception);

    JSStringRef errorHandlerKeyRef = JSStringCreateWithUTF8CString("__global_onerror_handler__");
    JSValueRef errorHandlerValueRef =
      JSObjectGetProperty(context->context(), context->global(), errorHandlerKeyRef, &exception);

    if (!JSValueIsObject(context->context(), errorHandlerValueRef)) {
      context->reportError("Failed to trigger global onerror: __global_onerror_handler__ is not registered.");
      return;
    }

    JSObjectRef errorHandlerFunction = JSValueToObject(context->context(), errorHandlerValueRef, &exception);
    const JSValueRef errorHandlerArguments[] = {errorObject};
    JSObjectCallAsFunction(context->context(), errorHandlerFunction, context->global(), 1, errorHandlerArguments,
                           &exception);

    context->handleException(exception);
  };

  bridgeCallback = new foundation::BridgeCallback();

  context = binding::jsc::createJSContext(contextId, errorHandler, this);

  kraken::binding::jsc::bindKraken(context);
  kraken::binding::jsc::bindUIManager(context);
  kraken::binding::jsc::bindConsole(context);
  kraken::binding::jsc::bindDocument(context);
  kraken::binding::jsc::bindWindow(context);
  kraken::binding::jsc::bindScreen(context);
  kraken::binding::jsc::bindTimer(context);
  kraken::binding::jsc::bindToBlob(context);
  kraken::binding::jsc::bindBlob(context);

  initKrakenPolyFill(this);
#ifdef KRAKEN_ENABLE_JSA
  Object promiseHandler = context->global().getPropertyAsObject(*context, "__global_unhandled_promise_handler__");
  context->setUnhandledPromiseRejectionHandler(promiseHandler);
#endif
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

void JSBridge::handleUIListener(const NativeString *args, JSValueRef *exception) {
  for (const auto &callback : krakenUIListenerList) {
    JSStringRef argsRef = JSStringCreateWithCharacters(args->string, args->length);
    const JSValueRef arguments[] = {JSValueMakeString(context->context(), argsRef)};
    JSObjectCallAsFunction(context->context(), callback, context->global(), 1, arguments, exception);
  }
}

void JSBridge::handleModuleListener(const NativeString *args, JSValueRef *exception) {
  for (const auto &callback : krakenModuleListenerList) {
    JSStringRef argsRef = JSStringCreateWithCharacters(args->string, args->length);
    const JSValueRef arguments[] = {JSValueMakeString(context->context(), argsRef)};
    JSObjectCallAsFunction(context->context(), callback, context->global(), 1, arguments, exception);
  }
}

const int UI_EVENT = 0;
const int MODULE_EVENT = 1;

void JSBridge::invokeEventListener(int32_t type, const NativeString *args) {
  if (!context->isValid()) return;

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[invokeEventListener VERBOSE]: message " << args;
  }

  JSValueRef exception = nullptr;
  if (UI_EVENT == type) {
    this->handleUIListener(args, &exception);
  } else if (MODULE_EVENT == type) {
    this->handleModuleListener(args, &exception);
  }
  context->handleException(exception);
}

void JSBridge::evaluateScript(const NativeString *script, const char *url, int startLine) {
  if (!context->isValid()) return;
  binding::jsc::updateLocation(url);
  context->evaluateJavaScript(script->string, script->length, url, startLine);
}

void JSBridge::evaluateScript(const char *script, const char *url, int startLine) {
  if (!context->isValid()) return;
  binding::jsc::updateLocation(url);
  context->evaluateJavaScript(script, url, startLine);
}

JSBridge::~JSBridge() {
  if (!context->isValid()) return;

  for (auto &callback : krakenUIListenerList) {
    JSValueUnprotect(context->context(), callback);
  }
  for (auto &callback : krakenModuleListenerList) {
    JSValueUnprotect(context->context(), callback);
  }

  krakenUIListenerList.clear();
  krakenModuleListenerList.clear();

  delete bridgeCallback;
}

void JSBridge::reportError(const char *errmsg) {
  handler_(context->getContextId(), errmsg);
}

} // namespace kraken
