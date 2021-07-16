/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "polyfill.h"

#include "dart_methods.h"
#include <atomic>
#include <cstdlib>
#include <memory>
#include "bridge_qjs.h"

#include "bindings/qjs/bom/console.h"
#include "bindings/qjs/bom/timer.h"
#include "bindings/qjs/bom/blob.h"
#include "bindings/qjs/bom/window.h"
#include "bindings/qjs/kraken.h"
#include "bindings/qjs/module_manager.h"
#include "bindings/qjs/dom/event_target.h"
#include "bindings/qjs/dom/event.h"
#include "bindings/qjs/dom/element.h"
#include "bindings/qjs/dom/document.h"
#include "bindings/qjs/dom/style_declaration.h"


namespace kraken {

using namespace binding::qjs;

std::unordered_map<std::string, NativeString> JSBridge::pluginSourceCode {};
ConsoleMessageHandler JSBridge::consoleMessageHandler {nullptr};

/**
 * JSRuntime
 */
JSBridge::JSBridge(int32_t contextId, const JSExceptionHandler &handler) : contextId(contextId) {
  auto errorHandler = [handler, this](int32_t contextId, const char *errmsg) {
    handler(contextId, errmsg);
    // trigger window.onerror handler.
    // TODO: trigger onerror event.
  };

#if ENABLE_PROFILE
  double jsContextStartTime =
    std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
#endif
  bridgeCallback = new foundation::BridgeCallback();

  m_context = binding::qjs::createJSContext(contextId, errorHandler, this);

//#if ENABLE_PROFILE
//  auto nativePerformance = binding::jsc::NativePerformance::instance(m_context->uniqueId);
//  nativePerformance->mark(PERF_JS_CONTEXT_INIT_START, jsContextStartTime);
//  nativePerformance->mark(PERF_JS_CONTEXT_INIT_END);
//  nativePerformance->mark(PERF_JS_NATIVE_METHOD_INIT_START);
//#endif

  bindConsole(m_context);
  bindTimer(m_context);
  bindKraken(m_context);
  bindModuleManager(m_context);
  bindEventTarget(m_context);
  bindBlob(m_context);
  bindWindow(m_context);
  bindEvent(m_context);
//  bindMouseEvent(m_context);
//  bindCustomEvent(m_context);
//  bindCloseEvent(m_context);
//  bindGestureEvent(m_context);
//  bindMediaErrorEvent(m_context);
//  bindTouchEvent(m_context);
//  bindInputEvent(m_context);
//  bindIntersectionChangeEvent(m_context);
//  bindMessageEvent(m_context);
//  bindEventTarget(m_context);
  bindDocument(m_context);
//  bindNode(m_context);
//  bindTextNode(m_context);
//  bindCommentNode(m_context);
  bindElement(m_context);
//  bindImageElement(m_context);
//  bindInputElement(m_context);
//  bindSVGElement(m_context);
//  bindWindow(m_context);
//  bindPerformance(m_context);
  bindCSSStyleDeclaration(m_context);
//  bindScreen(m_context);
//  bindBlob(m_context);

//#if ENABLE_PROFILE
//  nativePerformance->mark(PERF_JS_NATIVE_METHOD_INIT_END);
//  nativePerformance->mark(PERF_JS_POLYFILL_INIT_START);
//#endif

  initKrakenPolyFill(this);

  for (auto p : pluginSourceCode) {
    evaluateScript(&p.second, p.first.c_str(), 0);
  }

//#if ENABLE_PROFILE
//  nativePerformance->mark(PERF_JS_POLYFILL_INIT_END);
//#endif
}

void JSBridge::invokeModuleEvent(NativeString *moduleName, const char* eventType, void *event, NativeString *extra) {
//  if (!m_context->isValid()) return;
//
//  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
//    KRAKEN_LOG(VERBOSE) << "[invokeModuleEvent VERBOSE]: moduleName " << moduleName << " event: " << event;
//  }
//
//  JSValueRef exception = nullptr;
//  JSObjectRef eventObjectRef = nullptr;
//  if (event != nullptr) {
//    std::string type = std::string(eventType);
//    EventInstance *eventInstance = JSEvent::buildEventInstance(type, m_context.get(), event, false);
//    eventObjectRef = eventInstance->object;
//  }
//
//  for (const auto &callback : krakenModuleListenerList) {
//    if (exception != nullptr) {
//      m_context->handleException(exception);
//      return;
//    }
//
//    JSStringRef moduleNameStringRef = JSStringCreateWithCharacters(moduleName->string, moduleName->length);
//    JSStringRef moduleExtraDataRef = JSStringCreateWithCharacters(extra->string, extra->length);
//    const JSValueRef args[] = {
//      JSValueMakeString(m_context->context(), moduleNameStringRef),
//      eventObjectRef == nullptr ? JSValueMakeNull(m_context->context()) : eventObjectRef,
//      JSValueMakeFromJSONString(m_context->context(), moduleExtraDataRef)
//    };
//    JSObjectCallAsFunction(m_context->context(), callback, m_context->global(), 3, args, &exception);
//  }
//
//  m_context->handleException(exception);
}

void JSBridge::evaluateScript(const NativeString *script, const char *url, int startLine) {
  if (!m_context->isValid()) return;
//  binding::qjs::updateLocation(url);

//#if ENABLE_PROFILE
//  auto nativePerformance = binding::jsc::NativePerformance::instance(m_context->uniqueId);
//  nativePerformance->mark(PERF_JS_PARSE_TIME_START);
//  std::u16string patchedCode = std::u16string(u"performance.mark('js_parse_time_end');") + std::u16string(reinterpret_cast<const char16_t *>(script->string));
//  m_context->evaluateJavaScript(patchedCode.c_str(), patchedCode.size(), url, startLine);
//#else
  m_context->evaluateJavaScript(script->string, script->length, url, startLine);
//#endif
}

void JSBridge::evaluateScript(const uint16_t *script, size_t length, const char *url, int startLine) {
  if (!m_context->isValid()) return;
//  binding::qjs::updateLocation(url);
  m_context->evaluateJavaScript(script, length, url, startLine);
}

void JSBridge::evaluateScript(const char *script, size_t length, const char *url, int startLine) {
  if (!m_context->isValid()) return;
  //  binding::qjs::updateLocation(url);
  m_context->evaluateJavaScript(script, length, url, startLine);
}

JSBridge::~JSBridge() {
  if (!m_context->isValid()) return;

  for (auto &callback : krakenModuleListenerList) {
    JS_FreeValue(m_context->ctx(), callback);
  }

  krakenModuleListenerList.clear();

  delete bridgeCallback;

  if (m_disposeCallback != nullptr) {
    this->m_disposeCallback(m_disposePrivateData);
  }

//  binding::qjs::NativePerformance::disposeInstance(m_context->uniqueId);
}

void JSBridge::reportError(const char *errmsg) {
  m_handler(m_context->getContextId(), errmsg);
}

void JSBridge::setDisposeCallback(Task task, void *data) {
  m_disposeCallback = task;
  m_disposePrivateData = data;
}

} // namespace kraken
