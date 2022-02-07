/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <atomic>
#include <unordered_map>

#include <core/dart_methods.h>
#include "bindings/qjs/binding_initializer.h"
#include "foundation/logging.h"
#include "page.h"
#include "polyfill.h"

namespace kraken {

std::unordered_map<std::string, NativeByteCode> KrakenPage::pluginByteCode{};
ConsoleMessageHandler KrakenPage::consoleMessageHandler{nullptr};

kraken::KrakenPage** KrakenPage::pageContextPool{nullptr};

KrakenPage::KrakenPage(int32_t contextId, const JSExceptionHandler& handler) : contextId(contextId), ownerThreadId(std::this_thread::get_id()) {
#if ENABLE_PROFILE
  auto jsContextStartTime = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
#endif
  m_context = new ExecutionContext(
      contextId,
      [this](int32_t contextId, const char* message) {
        if (m_context->dartMethodPtr()->onJsError != nullptr) {
          m_context->dartMethodPtr()->onJsError(contextId, message);
        }
        KRAKEN_LOG(ERROR) << message << std::endl;
      },
      this);

#if ENABLE_PROFILE
  auto nativePerformance = Performance::instance(m_context)->m_nativePerformance;
  nativePerformance.mark(PERF_JS_CONTEXT_INIT_START, jsContextStartTime);
  nativePerformance.mark(PERF_JS_CONTEXT_INIT_END);
  nativePerformance.mark(PERF_JS_NATIVE_METHOD_INIT_START);
#endif

  initBinding();

#if ENABLE_PROFILE
  nativePerformance.mark(PERF_JS_NATIVE_METHOD_INIT_END);
  nativePerformance.mark(PERF_JS_POLYFILL_INIT_START);
#endif

  initKrakenPolyFill(this);

  for (auto& p : pluginByteCode) {
    evaluateByteCode(p.second.bytes, p.second.length);
  }

#if ENABLE_PROFILE
  nativePerformance.mark(PERF_JS_POLYFILL_INIT_END);
#endif
}

bool KrakenPage::parseHTML(const char* code, size_t length) {
  //  if (!m_context->isValid())
  //    return false;
  //  JSValue bodyValue = JS_GetPropertyStr(m_context->ctx(), m_context->document()->jsObject, "body");
  //  auto* body = static_cast<Element*>(JS_GetOpaque(bodyValue, Element::classId));
  //  HTMLParser::parseHTML(code, length, body);
  //  JS_FreeValue(m_context->ctx(), bodyValue);
  //  return true;
}

void KrakenPage::invokeModuleEvent(const NativeString* moduleName, const char* eventType, void* ptr, NativeString* extra) {
  //  if (!m_context->isValid())
  //    return;
  //
  //  JSValue eventObject = JS_NULL;
  //  if (ptr != nullptr) {
  //    std::string type = std::string(eventType);
  //    auto* rawEvent = static_cast<RawEvent*>(ptr)->bytes;
  //    Event* event = Event::create(m_context->ctx(), reinterpret_cast<NativeEvent*>(rawEvent));
  //    eventObject = event->toQuickJS();
  //  }
  //
  //  JSValue moduleNameValue = JS_NewUnicodeString(m_context->runtime(), m_context->ctx(), moduleName->string, moduleName->length);
  //  JSValue extraObject = JS_NULL;
  //  if (extra != nullptr) {
  //    std::u16string u16Extra = std::u16string(reinterpret_cast<const char16_t*>(extra->string), extra->length);
  //    std::string extraString = toUTF8(u16Extra);
  //    extraObject = JS_ParseJSON(m_context->ctx(), extraString.c_str(), extraString.size(), "");
  //  }
  //
  //  {
  //    struct list_head *el, *el1;
  //    list_for_each_safe(el, el1, &m_context->module_job_list) {
  //      auto* module = list_entry(el, ModuleContext, link);
  //      JSValue callback = module->callback;
  //
  //      JSValue arguments[] = {moduleNameValue, eventObject, extraObject};
  //      JSValue returnValue = JS_Call(m_context->ctx(), callback, m_context->global(), 3, arguments);
  //      m_context->handleException(&returnValue);
  //      JS_FreeValue(m_context->ctx(), returnValue);
  //    }
  //  }
  //
  //  JS_FreeValue(m_context->ctx(), moduleNameValue);
  //
  //  if (rawEvent != nullptr) {
  //    JS_FreeValue(m_context->ctx(), eventObject);
  //  }
  //  if (extra != nullptr) {
  //    JS_FreeValue(m_context->ctx(), extraObject);
  //  }
}

void KrakenPage::evaluateScript(const NativeString* script, const char* url, int startLine) {
  if (!m_context->isValid())
    return;

#if ENABLE_PROFILE
  auto nativePerformance = Performance::instance(m_context)->m_nativePerformance;
  nativePerformance.mark(PERF_JS_PARSE_TIME_START);
  std::u16string patchedCode = std::u16string(u"performance.mark('js_parse_time_end');") + std::u16string(reinterpret_cast<const char16_t*>(script->string), script->length);
  m_context->evaluateJavaScript(patchedCode.c_str(), patchedCode.size(), url, startLine);
#else
  m_context->evaluateJavaScript(script->string, script->length, url, startLine);
#endif
}

void KrakenPage::evaluateScript(const uint16_t* script, size_t length, const char* url, int startLine) {
  if (!m_context->isValid())
    return;
  m_context->evaluateJavaScript(script, length, url, startLine);
}

void KrakenPage::evaluateScript(const char* script, size_t length, const char* url, int startLine) {
  if (!m_context->isValid())
    return;
  m_context->evaluateJavaScript(script, length, url, startLine);
}

uint8_t* KrakenPage::dumpByteCode(const char* script, size_t length, const char* url, size_t* byteLength) {
  if (!m_context->isValid())
    return nullptr;
  return m_context->dumpByteCode(script, length, url, byteLength);
}

void KrakenPage::evaluateByteCode(uint8_t* bytes, size_t byteLength) {
  if (!m_context->isValid())
    return;
  m_context->evaluateByteCode(bytes, byteLength);
}

void KrakenPage::registerDartMethods(uint64_t* methodBytes, int32_t length) {
  size_t i = 0;

  auto& dartMethodPointer = m_context->dartMethodPtr();

  dartMethodPointer->invokeModule = reinterpret_cast<InvokeModule>(methodBytes[i++]);
  dartMethodPointer->requestBatchUpdate = reinterpret_cast<RequestBatchUpdate>(methodBytes[i++]);
  dartMethodPointer->reloadApp = reinterpret_cast<ReloadApp>(methodBytes[i++]);
  dartMethodPointer->setTimeout = reinterpret_cast<SetTimeout>(methodBytes[i++]);
  dartMethodPointer->setInterval = reinterpret_cast<SetInterval>(methodBytes[i++]);
  dartMethodPointer->clearTimeout = reinterpret_cast<ClearTimeout>(methodBytes[i++]);
  dartMethodPointer->requestAnimationFrame = reinterpret_cast<RequestAnimationFrame>(methodBytes[i++]);
  dartMethodPointer->cancelAnimationFrame = reinterpret_cast<CancelAnimationFrame>(methodBytes[i++]);
  dartMethodPointer->getScreen = reinterpret_cast<GetScreen>(methodBytes[i++]);
  dartMethodPointer->devicePixelRatio = reinterpret_cast<DevicePixelRatio>(methodBytes[i++]);
  dartMethodPointer->platformBrightness = reinterpret_cast<PlatformBrightness>(methodBytes[i++]);
  dartMethodPointer->toBlob = reinterpret_cast<ToBlob>(methodBytes[i++]);
  dartMethodPointer->flushUICommand = reinterpret_cast<FlushUICommand>(methodBytes[i++]);
  dartMethodPointer->initWindow = reinterpret_cast<InitWindow>(methodBytes[i++]);
  dartMethodPointer->initDocument = reinterpret_cast<InitDocument>(methodBytes[i++]);

#if ENABLE_PROFILE
  methodPointer->getPerformanceEntries = reinterpret_cast<GetPerformanceEntries>(methodBytes[i++]);
#else
  i++;
#endif

  dartMethodPointer->onJsError = reinterpret_cast<OnJSError>(methodBytes[i++]);

  assert_m(i == length, "Dart native methods count is not equal with C++ side method registrations.");
}

std::thread::id KrakenPage::currentThread() const {
  return ownerThreadId;
}

KrakenPage::~KrakenPage() {
#if IS_TEST
  if (disposeCallback != nullptr) {
    disposeCallback(this);
  }
#endif
  delete m_context;
  KrakenPage::pageContextPool[contextId] = nullptr;
}

void KrakenPage::reportError(const char* errmsg) {
  m_handler(m_context->getContextId(), errmsg);
}

}  // namespace kraken
