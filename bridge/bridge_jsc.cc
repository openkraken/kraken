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

#include "bindings/jsc/DOM/comment_node.h"
#include "bindings/jsc/DOM/custom_event.h"
#include "bindings/jsc/DOM/document.h"
#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/DOM/elements/image_element.h"
#include "bindings/jsc/DOM/elements/input_element.h"
#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/DOM/custom_event.h"
#include "bindings/jsc/DOM/gesture_event.h"
#include "bindings/jsc/DOM/events/input_event.h"
#include "bindings/jsc/DOM/event_target.h"
#include "bindings/jsc/DOM/events/close_event.h"
#include "bindings/jsc/DOM/events/input_event.h"
#include "bindings/jsc/DOM/events/intersection_change_event.h"
#include "bindings/jsc/DOM/events/media_error_event.h"
#include "bindings/jsc/DOM/events/message_event.h"
#include "bindings/jsc/DOM/events/touch_event.h"
#include "bindings/jsc/DOM/node.h"
#include "bindings/jsc/DOM/style_declaration.h"
#include "bindings/jsc/DOM/text_node.h"
#include "bindings/jsc/KOM/blob.h"
#include "bindings/jsc/KOM/console.h"
#include "bindings/jsc/KOM/location.h"
#include "bindings/jsc/KOM/performance.h"
#include "bindings/jsc/KOM/screen.h"
#include "bindings/jsc/KOM/window.h"
#include "bindings/jsc/js_context_internal.h"
#include "bindings/jsc/kraken.h"
#include "bindings/jsc/ui_manager.h"

namespace kraken {

using namespace binding::jsc;

std::unordered_map<std::string, NativeString> JSBridge::pluginSourceCode {};

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
  bindGestureEvent(context);
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

  for (auto p : pluginSourceCode) {
    evaluateScript(&p.second, p.first.c_str(), 0);
  }

#if ENABLE_PROFILE
  nativePerformance->mark(PERF_JS_POLYFILL_INIT_END);
#endif

#ifdef KRAKEN_ENABLE_JSA
  Object promiseHandler = context->global().getPropertyAsObject(*context, "__global_unhandled_promise_handler__");
  context->setUnhandledPromiseRejectionHandler(promiseHandler);
#endif

#if ENABLE_DEBUGGER
  attachInspector();
#endif
}

#ifdef ENABLE_DEBUGGER
void JSBridge::attachInspector() {
  std::shared_ptr<BridgeProtocolHandler> handler = std::make_shared<BridgeProtocolHandler>(this);
  m_inspector = std::make_shared<debugger::FrontDoor>(reinterpret_cast<JSC::JSGlobalObject *>(context->global()), handler);
}
#endif // ENABLE_DEBUGGER

void JSBridge::invokeModuleEvent(NativeString *moduleName, const char* eventType, void *event, NativeString *extra) {
  if (!context->isValid()) return;

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[invokeModuleEvent VERBOSE]: moduleName " << moduleName << " event: " << event;
  }

  JSValueRef exception = nullptr;
  JSObjectRef eventObjectRef = nullptr;
  if (event != nullptr) {
    std::string type = std::string(eventType);
    EventInstance *eventInstance = JSEvent::buildEventInstance(type, context.get(), event, false);
    eventObjectRef = eventInstance->object;
  }

  for (const auto &callback : krakenModuleListenerList) {
    if (exception != nullptr) {
      context->handleException(exception);
      return;
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

#if ENABLE_DEBUGGER
void BridgeProtocolHandler::handlePageReload() {}
#endif

} // namespace kraken

#endif
