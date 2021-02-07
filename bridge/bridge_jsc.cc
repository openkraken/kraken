/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_ENABLE_JSA

#include "bridge_jsc.h"
#include "foundation/logging.h"
#include "polyfill.h"

#include "dart_methods.h"
#include <atomic>
#include <cstdlib>
#include <memory>

namespace kraken {

using namespace binding::jsc;

/**
 * JSRuntime
 */
JSBridge::JSBridge(int32_t contextId, const JSExceptionHandler &handler) : contextId(contextId) {
  auto errorHandler = [handler, this](int32_t contextId, const char *errmsg) {
    handler(contextId, errmsg);
    // trigger window.onerror handler.
    // TODO: trigger oneror event.
  };

#if ENABLE_PROFILE
  double jsContextStartTime =
    std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
#endif
  bridgeCallback = new foundation::BridgeCallback();

  context = binding::jsc::createJSContext(contextId, errorHandler, this);

#if ENABLE_PROFILE
  auto nativePerformance = binding::jsc::NativePerformance::instance(context->uniqueId);
  nativePerformance->mark(PERF_JS_CONTEXT_INIT_START, jsContextStartTime);
  nativePerformance->mark(PERF_JS_CONTEXT_INIT_END);
  nativePerformance->mark(PERF_JS_NATIVE_METHOD_INIT_START);
#endif

  bindKraken(context);
  bindUIManager(context);
  bindConsole(context);
  bindEvent(context);
  bindCustomEvent(context);
  bindCloseEvent(context);
  bindMediaErrorEvent(context);
  bindTouchEvent(context);
  bindInputEvent(context);
  bindIntersectionChangeEvent(context);
  bindMessageEvent(context);
  bindEventTarget(context);
  bindDocument(context);
  bindNode(context);
  bindTextNode(context);
  bindCommentNode(context);
  bindElement(context);
  bindImageElement(context);
  bindInputElement(context);
  bindWindow(context);
  bindPerformance(context);
  bindCSSStyleDeclaration(context);
  bindScreen(context);
  bindBlob(context);

#if ENABLE_PROFILE
  nativePerformance->mark(PERF_JS_NATIVE_METHOD_INIT_END);
  nativePerformance->mark(PERF_JS_POLYFILL_INIT_START);
#endif

  initKrakenPolyFill(this);

#if ENABLE_PROFILE
  nativePerformance->mark(PERF_JS_POLYFILL_INIT_END);
#endif

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

void JSBridge::invokeModuleEvent(NativeString *moduleName, NativeEvent *event, NativeString *extra) {
  if (!context->isValid()) return;

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[invokeModuleEvent VERBOSE]: moduleName " << moduleName << " event: " << event;
  }

  JSValueRef exception = nullptr;

  for (const auto &callback : krakenModuleListenerList) {
    if (exception != nullptr) {
      context->handleException(exception);
      return;
    }

    JSObjectRef eventObjectRef = nullptr;
    if (event != nullptr) {
      auto eventInstance = new EventInstance(JSEvent::instance(context.get()), event);
      eventObjectRef = eventInstance->object;
    }

    JSStringRef moduleNameStringRef = JSStringCreateWithCharacters(moduleName->string, moduleName->length);
    JSStringRef moduleExtraDataRef = JSStringCreateWithCharacters(extra->string, extra->length);
    const JSValueRef args[] = {
      JSValueMakeString(context->context(), moduleNameStringRef),
      eventObjectRef == nullptr ? JSValueMakeNull(context->context()) : eventObjectRef,
      JSValueMakeFromJSONString(context->context(), moduleExtraDataRef)
    };
    JSObjectCallAsFunction(context->context(), callback, context->global(), 3, args, &exception);
  }

  context->handleException(exception);
}

void JSBridge::evaluateScript(const NativeString *script, const char *url, int startLine) {
  if (!context->isValid()) return;
  binding::jsc::updateLocation(url);
  context->evaluateJavaScript(script->string, script->length, url, startLine);
}

void JSBridge::evaluateScript(const std::u16string &script, const char *url, int startLine) {
  if (!context->isValid()) return;
  binding::jsc::updateLocation(url);
  context->evaluateJavaScript(script.c_str(), script.size(), url, startLine);
}

JSBridge::~JSBridge() {
  if (!context->isValid()) return;

  for (auto &callback : krakenModuleListenerList) {
    JSValueUnprotect(context->context(), callback);
  }

  krakenModuleListenerList.clear();

  delete bridgeCallback;

  binding::jsc::NativePerformance::disposeInstance(context->uniqueId);
}

void JSBridge::reportError(const char *errmsg) {
  handler_(context->getContextId(), errmsg);
}

} // namespace kraken

#endif
