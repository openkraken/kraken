/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <atomic>
#include <unordered_map>

#include "bindings/qjs/binding_initializer.h"
#include "core/dart_methods.h"
#include "core/dom/document.h"
#include "core/frame/window.h"
#include "core/html/parser/html_parser.h"
#include "foundation/logging.h"
#include "page.h"
#include "polyfill.h"

namespace kraken {

ConsoleMessageHandler KrakenPage::consoleMessageHandler{nullptr};

kraken::KrakenPage** KrakenPage::pageContextPool{nullptr};

KrakenPage::KrakenPage(int32_t contextId, const JSExceptionHandler& handler)
    : contextId(contextId), ownerThreadId(std::this_thread::get_id()) {
  context_ = new ExecutingContext(
      contextId,
      [](ExecutingContext* context, const char* message) {
        if (context->dartMethodPtr()->onJsError != nullptr) {
          context->dartMethodPtr()->onJsError(context->contextId(), message);
        }
        KRAKEN_LOG(ERROR) << message << std::endl;
      },
      this);
}

bool KrakenPage::parseHTML(const char* code, size_t length) {
  if (!context_->IsValid())
    return false;

  // Remove all Nodes including body and head.
  context_->document()->documentElement()->RemoveChildren();

  HTMLParser::parseHTML(code, length, context_->document()->documentElement());

  return true;
}

void KrakenPage::invokeModuleEvent(const NativeString* moduleName,
                                   const char* eventType,
                                   void* ptr,
                                   NativeString* extra) {
  if (!context_->IsValid())
    return;

  JSContext* ctx = context_->ctx();
  Event* event = nullptr;
  if (ptr != nullptr) {
    std::string type = std::string(eventType);
    auto* rawEvent = static_cast<RawEvent*>(ptr)->bytes;
    event = Event::From(context_, reinterpret_cast<NativeEvent*>(rawEvent));
  }

  ScriptValue extraObject = ScriptValue::Empty(ctx);
  if (extra != nullptr) {
    std::u16string u16Extra = std::u16string(reinterpret_cast<const char16_t*>(extra->string()), extra->length());
    std::string extraString = toUTF8(u16Extra);
    extraObject = ScriptValue::CreateJsonObject(ctx, extraString.c_str(), extraString.length());
  }

  auto* listeners = context_->ModuleCallbacks()->listeners();
  for (auto& listener : *listeners) {
    ScriptValue arguments[] = {ScriptValue(ctx, moduleName),
                               event != nullptr ? event->ToValue() : ScriptValue::Empty(ctx), extraObject};
    ScriptValue result = listener->value()->Invoke(ctx, ScriptValue::Empty(ctx), 3, arguments);
    if (result.IsException()) {
      context_->HandleException(&result);
    }
  }
}

void KrakenPage::evaluateScript(const NativeString* script, const char* url, int startLine) {
  if (!context_->IsValid())
    return;

#if ENABLE_PROFILE
  auto nativePerformance = Performance::instance(context_)->m_nativePerformance;
  nativePerformance.mark(PERF_JS_PARSE_TIME_START);
  std::u16string patchedCode = std::u16string(u"performance.mark('js_parse_time_end');") +
                               std::u16string(reinterpret_cast<const char16_t*>(script->string), script->length);
  context_->evaluateJavaScript(patchedCode.c_str(), patchedCode.size(), url, startLine);
#else
  context_->EvaluateJavaScript(script->string(), script->length(), url, startLine);
#endif
}

void KrakenPage::evaluateScript(const uint16_t* script, size_t length, const char* url, int startLine) {
  if (!context_->IsValid())
    return;
  context_->EvaluateJavaScript(script, length, url, startLine);
}

void KrakenPage::evaluateScript(const char* script, size_t length, const char* url, int startLine) {
  if (!context_->IsValid())
    return;
  context_->EvaluateJavaScript(script, length, url, startLine);
}

uint8_t* KrakenPage::dumpByteCode(const char* script, size_t length, const char* url, size_t* byteLength) {
  if (!context_->IsValid())
    return nullptr;
  return context_->DumpByteCode(script, length, url, byteLength);
}

void KrakenPage::evaluateByteCode(uint8_t* bytes, size_t byteLength) {
  if (!context_->IsValid())
    return;
  context_->EvaluateByteCode(bytes, byteLength);
}

void KrakenPage::registerDartMethods(uint64_t* methodBytes, int32_t length) {
  size_t i = 0;

  auto& dartMethodPointer = context_->dartMethodPtr();

  dartMethodPointer->invokeModule = reinterpret_cast<InvokeModule>(methodBytes[i++]);
  dartMethodPointer->requestBatchUpdate = reinterpret_cast<RequestBatchUpdate>(methodBytes[i++]);
  dartMethodPointer->reloadApp = reinterpret_cast<ReloadApp>(methodBytes[i++]);
  dartMethodPointer->setTimeout = reinterpret_cast<SetTimeout>(methodBytes[i++]);
  dartMethodPointer->setInterval = reinterpret_cast<SetInterval>(methodBytes[i++]);
  dartMethodPointer->clearTimeout = reinterpret_cast<ClearTimeout>(methodBytes[i++]);
  dartMethodPointer->requestAnimationFrame = reinterpret_cast<RequestAnimationFrame>(methodBytes[i++]);
  dartMethodPointer->cancelAnimationFrame = reinterpret_cast<CancelAnimationFrame>(methodBytes[i++]);
  dartMethodPointer->getScreen = reinterpret_cast<GetScreen>(methodBytes[i++]);
  dartMethodPointer->toBlob = reinterpret_cast<ToBlob>(methodBytes[i++]);
  dartMethodPointer->flushUICommand = reinterpret_cast<FlushUICommand>(methodBytes[i++]);

#if ENABLE_PROFILE
  methodPointer->getPerformanceEntries = reinterpret_cast<GetPerformanceEntries>(methodBytes[i++]);
#else
  i++;
#endif

  dartMethodPointer->onJsError = reinterpret_cast<OnJSError>(methodBytes[i++]);
  dartMethodPointer->onJsLog = reinterpret_cast<OnJSLog>(methodBytes[i++]);

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
  delete context_;
  KrakenPage::pageContextPool[contextId] = nullptr;
}

void KrakenPage::reportError(const char* errmsg) {
  handler_(context_, errmsg);
}

}  // namespace kraken
