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

#include "bindings/jsc/KOM/timer.h"
#include "bindings/jsc/DOM/comment_node.h"
#include "bindings/jsc/DOM/custom_event.h"
#include "bindings/jsc/DOM/document.h"
#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/DOM/elements/image_element.h"
#include "bindings/jsc/DOM/elements/input_element.h"
#include "bindings/jsc/DOM/elements/svg_element.h"
#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/DOM/custom_event.h"
#include "bindings/jsc/DOM/events/gesture_event.h"
#include "bindings/jsc/DOM/events/mouse_event.h"
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
#include "bindings/jsc/html_parser.h"

namespace kraken {

using namespace binding::jsc;

std::unordered_map<std::string, NativeString> JSBridge::pluginSourceCode {};
ConsoleMessageHandler JSBridge::consoleMessageHandler {nullptr};

/**
 * JSRuntime
 */
JSBridge::JSBridge(int32_t contextId, const JSExceptionHandler &handler) : contextId(contextId) {
  auto errorHandler = [handler, this](int32_t contextId, const char *errmsg, JSObjectRef errorObject) {
    handler(contextId, errmsg, errorObject);

    // trigger error event.
    JSStringHolder windowKeyHolder = JSStringHolder(m_context.get(), "window");
    JSValueRef windowValue = JSObjectGetProperty(m_context->context(), m_context->global(), windowKeyHolder.getString(), nullptr);
    JSObjectRef windowObject = JSValueToObject(m_context->context(), windowValue, nullptr);
    JSStringHolder onerrorKeyHolder = JSStringHolder(m_context.get(), "__global_onerror_handler__");
    if (JSObjectHasProperty(m_context->context(), windowObject, onerrorKeyHolder.getString())) {
      JSValueRef onerrorFuncValue = JSObjectGetProperty(m_context->context(), windowObject, onerrorKeyHolder.getString(), nullptr);
      JSObjectRef onerrorFunc = JSValueToObject(m_context->context(), onerrorFuncValue, nullptr);
      JSValueRef arguments[] = {
        errorObject
      };

      JSObjectCallAsFunction(m_context->context(), onerrorFunc, m_context->global(), 1, arguments, nullptr);
    }
  };

#if ENABLE_PROFILE
  double jsContextStartTime =
    std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
#endif
  bridgeCallback = new foundation::BridgeCallback();

  m_context = binding::jsc::createJSContext(contextId, errorHandler, this);

  m_html_parser = binding::jsc::createHTMLParser(m_context, errorHandler, this);

#if ENABLE_PROFILE
  auto nativePerformance = binding::jsc::NativePerformance::instance(m_context->uniqueId);
  nativePerformance->mark(PERF_JS_CONTEXT_INIT_START, jsContextStartTime);
  nativePerformance->mark(PERF_JS_CONTEXT_INIT_END);
  nativePerformance->mark(PERF_JS_NATIVE_METHOD_INIT_START);
#endif

  bindTimer(m_context);
  bindKraken(m_context);
  bindUIManager(m_context);
  bindConsole(m_context);
  bindEvent(m_context);
  bindMouseEvent(m_context);
  bindCustomEvent(m_context);
  bindCloseEvent(m_context);
  bindGestureEvent(m_context);
  bindMediaErrorEvent(m_context);
  bindTouchEvent(m_context);
  bindInputEvent(m_context);
  bindIntersectionChangeEvent(m_context);
  bindMessageEvent(m_context);
  bindEventTarget(m_context);
  bindDocument(m_context);
  bindNode(m_context);
  bindTextNode(m_context);
  bindCommentNode(m_context);
  bindElement(m_context);
  bindImageElement(m_context);
  bindInputElement(m_context);
  bindSVGElement(m_context);
  bindWindow(m_context);
  bindPerformance(m_context);
  bindCSSStyleDeclaration(m_context);
  bindScreen(m_context);
  bindBlob(m_context);

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
  Object promiseHandler = m_context->global().getPropertyAsObject(*m_context, "__global_unhandled_promise_handler__");
  m_context->setUnhandledPromiseRejectionHandler(promiseHandler);
#endif
}

void JSBridge::invokeModuleEvent(NativeString *moduleName, const char* eventType, void *event, NativeString *extra) {
  if (!m_context->isValid()) return;

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[invokeModuleEvent VERBOSE]: moduleName " << moduleName << " event: " << event;
  }

  JSValueRef exception = nullptr;
  JSObjectRef eventObjectRef = nullptr;
  if (event != nullptr) {
    std::string type = std::string(eventType);
    EventInstance *eventInstance = JSEvent::buildEventInstance(type, m_context.get(), event, false);
    eventObjectRef = eventInstance->object;
  }

  for (const auto &callback : krakenModuleListenerList) {
    // The last callback function may be a method such as reload, which releas JSContext. If JSContext has been released, it may access a null pointer and cause a crash.
    if (m_context == nullptr || !m_context->isValid()) break;

    JSStringRef moduleNameStringRef = JSStringCreateWithCharacters(moduleName->string, moduleName->length);
    JSStringRef moduleExtraDataRef = JSStringCreateWithCharacters(extra->string, extra->length);
    const JSValueRef args[] = {
      JSValueMakeString(m_context->context(), moduleNameStringRef),
      eventObjectRef == nullptr ? JSValueMakeNull(m_context->context()) : eventObjectRef,
      JSValueMakeFromJSONString(m_context->context(), moduleExtraDataRef)
    };
    JSObjectCallAsFunction(m_context->context(), callback, m_context->global(), 3, args, &exception);

    if (exception != nullptr) {
      m_context->handleException(exception);
      break;
    }
  }
}

// parse html.
void JSBridge::parseHTML(const NativeString *script, const char *url) {
  if (!m_context->isValid()) return;

  m_html_parser->parseHTML(script->string, script->length);
}

// eval javascript.
void JSBridge::evaluateScript(const NativeString *script, const char *url, int startLine) {
  if (!m_context->isValid()) return;

  #if ENABLE_PROFILE
    auto nativePerformance = binding::jsc::NativePerformance::instance(m_context->uniqueId);
    nativePerformance->mark(PERF_JS_PARSE_TIME_START);
    std::u16string patchedCode = std::u16string(u"performance.mark('js_parse_time_end');") + std::u16string(reinterpret_cast<const char16_t *>(script->string));
    m_context->evaluateJavaScript(patchedCode.c_str(), patchedCode.size(), url, startLine);
  #else
    m_context->evaluateJavaScript(script->string, script->length, url, startLine);
  #endif
}

void JSBridge::evaluateScript(const std::u16string &script, const char *url, int startLine) {
  if (!m_context->isValid()) return;
  m_context->evaluateJavaScript(script.c_str(), script.size(), url, startLine);
}

JSBridge::~JSBridge() {
  if (!m_context->isValid()) return;

  for (auto &callback : krakenModuleListenerList) {
    JSValueUnprotect(m_context->context(), callback);
  }

  krakenModuleListenerList.clear();

  delete bridgeCallback;

  if (m_disposeCallback != nullptr) {
    this->m_disposeCallback(m_disposePrivateData);
  }

  binding::jsc::NativePerformance::disposeInstance(m_context->uniqueId);
}

void JSBridge::reportError(const char *errmsg) {
  m_context->reportError(errmsg);
}

void JSBridge::setDisposeCallback(Task task, void *data) {
  m_disposeCallback = task;
  m_disposePrivateData = data;
}

} // namespace kraken

JSGlobalContextRef getGlobalContextRef(int32_t contextId) {
  assert(checkContext(contextId));
  auto bridge = static_cast<kraken::JSBridge *>(getJSContext(contextId));
  return bridge->getContext()->context();
};

#endif
