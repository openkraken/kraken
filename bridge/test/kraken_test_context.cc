/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_test_context.h"
#include "testframework.h"

namespace kraken {

KrakenTestContext::KrakenTestContext(ExecutingContext* context) : m_context(context) {
  //  bridge->owner = this;
  //  bridge->disposeCallback = [](KrakenPage* bridge) { delete static_cast<KrakenPageTest*>(bridge->owner); };
  //  QJS_GLOBAL_BINDING_FUNCTION(m_page_context, executeTest, "__kraken_execute_test__", 1);
  //  QJS_GLOBAL_BINDING_FUNCTION(m_page_context, matchImageSnapshot, "__kraken_match_image_snapshot__", 3);
  //  QJS_GLOBAL_BINDING_FUNCTION(m_page_context, environment, "__kraken_environment__", 0);
  //  QJS_GLOBAL_BINDING_FUNCTION(m_page_context, simulatePointer, "__kraken_simulate_pointer__", 1);
  //  QJS_GLOBAL_BINDING_FUNCTION(m_page_context, simulateInputText, "__kraken_simulate_inputtext__", 1);
  //  QJS_GLOBAL_BINDING_FUNCTION(m_page_context, triggerGlobalError, "__kraken_trigger_global_error__", 0);
  //  QJS_GLOBAL_BINDING_FUNCTION(m_page_context, parseHTML, "__kraken_parse_html__", 1);

  //  initKrakenTestFramework(bridge);
  //  init_list_head(&image_link);
}

bool KrakenTestContext::evaluateTestScripts(const uint16_t* code,
                                            size_t codeLength,
                                            const char* sourceURL,
                                            int startLine) {
  if (!m_context->IsValid())
    return false;
  return m_context->EvaluateJavaScript(code, codeLength, sourceURL, startLine);
}

bool KrakenTestContext::parseTestHTML(const uint16_t* code, size_t codeLength) {
  //  if (!m_page_context->isValid())
  //    return false;
  //  std::string utf8Code = toUTF8(std::u16string(reinterpret_cast<const char16_t*>(code), codeLength));
  //  return m_page->parseHTML(utf8Code.c_str(), utf8Code.length());
}

static JSValue executeTest(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  //  JSValue& callback = argv[0];
  //  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  //  if (!JS_IsObject(callback)) {
  //    return JS_ThrowTypeError(ctx, "Failed to execute 'executeTest': parameter 1 (callback) is not an function.");
  //  }
  //
  //  if (!JS_IsFunction(ctx, callback)) {
  //    return JS_ThrowTypeError(ctx, "Failed to execute 'executeTest': parameter 1 (callback) is not an function.");
  //  }
  //  auto bridge = static_cast<KrakenPage*>(context->getOwner());
  //  auto bridgeTest = static_cast<KrakenTestContext*>(bridge->owner);
  //  bridgeTest->m_executeTestCallback = ScriptValue(ctx, callback);
  //  return JS_NULL;
}

static JSValue matchImageSnapshot(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  //  JSValue& blobValue = argv[0];
  //  JSValue& screenShotValue = argv[1];
  //  JSValue& callbackValue = argv[2];
  //  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  //
  //  if (!JS_IsObject(blobValue)) {
  //    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_match_image_snapshot__': parameter 1 (blob) must be
  //    an Blob object.");
  //  }
  //  auto blob = static_cast<kraken::BlobInstance*>(JS_GetOpaque(blobValue, kraken::Blob::kBlobClassID));
  //
  //  if (blob == nullptr) {
  //    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_match_image_snapshot__': parameter 1 (blob) must be
  //    an Blob object.");
  //  }
  //
  //  if (!JS_IsString(screenShotValue)) {
  //    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_match_image_snapshot__': parameter 2 (match) must be
  //    an string.");
  //  }
  //
  //  if (!JS_IsObject(callbackValue)) {
  //    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_match_image_snapshot__': parameter 3 (callback) is
  //    not an function.");
  //  }
  //
  //  if (!JS_IsFunction(ctx, callbackValue)) {
  //    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_match_image_snapshot__': parameter 3 (callback) is
  //    not an function.");
  //  }
  //
  //  if (getDartMethod()->matchImageSnapshot == nullptr) {
  //    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_match_image_snapshot__': dart method
  //    (matchImageSnapshot) is not registered.");
  //  }
  //
  //  std::unique_ptr<NativeString> screenShotNativeString = kraken::jsValueToNativeString(ctx, screenShotValue);
  //  auto bridge = static_cast<KrakenPageTest*>(static_cast<KrakenPage*>(context->getOwner())->owner);
  //  auto* callbackContext = new ImageSnapShotContext{JS_DupValue(ctx, callbackValue), context};
  //  list_add_tail(&callbackContext->link, &bridge->image_link);
  //
  //  auto fn = [](void* ptr, int32_t contextId, int8_t result, const char* errmsg) {
  //    auto* callbackContext = static_cast<ImageSnapShotContext*>(ptr);
  //    JSContext* ctx = callbackContext->context->ctx();
  //
  //    if (errmsg == nullptr) {
  //      JSValue arguments[] = {JS_NewBool(ctx, result != 0), JS_NULL};
  //      JSValue returnValue = JS_Call(ctx, callbackContext->callback, callbackContext->context->global(), 1,
  //      arguments); callbackContext->context->handleException(&returnValue);
  //    } else {
  //      JSValue errmsgValue = JS_NewString(ctx, errmsg);
  //      JSValue arguments[] = {JS_NewBool(ctx, false), errmsgValue};
  //      JSValue returnValue = JS_Call(ctx, callbackContext->callback, callbackContext->context->global(), 2,
  //      arguments); callbackContext->context->handleException(&returnValue); JS_FreeValue(ctx, errmsgValue);
  //    }
  //
  //    callbackContext->context->drainPendingPromiseJobs();
  //    JS_FreeValue(callbackContext->context->ctx(), callbackContext->callback);
  //    list_del(&callbackContext->link);
  //  };
  //
  //  getDartMethod()->matchImageSnapshot(callbackContext, context->getContextId(), blob->bytes(), blob->size(),
  //  screenShotNativeString.get(), fn);
  return JS_NULL;
}

static JSValue environment(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* context = ExecutingContext::From(ctx);
#if FLUTTER_BACKEND
  if (context->dartMethodPtr()->environment == nullptr) {
    return JS_ThrowTypeError(
        ctx, "Failed to execute '__kraken_environment__': dart method (environment) is not registered.");
  }
  const char* env = context->dartMethodPtr()->environment();
  return JS_ParseJSON(ctx, env, strlen(env), "");
#else
  return JS_NewObject(ctx);
#endif
}

static JSValue simulatePointer(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
  if (context->dartMethodPtr()->simulatePointer == nullptr) {
    return JS_ThrowTypeError(
        ctx, "Failed to execute '__kraken_simulate_pointer__': dart method(simulatePointer) is not registered.");
  }

  JSValue inputArrayValue = argv[0];
  if (!JS_IsObject(inputArrayValue)) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute '__kraken_simulate_pointer__': first arguments should be an array.");
  }

  JSValue pointerValue = argv[1];
  if (!JS_IsNumber(pointerValue)) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute '__kraken_simulate_pointer__': second arguments should be an number.");
  }

  uint32_t length;
  JSValue lengthValue = JS_GetPropertyStr(ctx, inputArrayValue, "length");
  JS_ToUint32(ctx, &length, lengthValue);
  JS_FreeValue(ctx, lengthValue);

  auto** mousePointerList = new MousePointer*[length];

  for (int i = 0; i < length; i++) {
    auto mouse = new MousePointer();
    JSValue params = JS_GetPropertyUint32(ctx, inputArrayValue, i);
    mouse->contextId = context->contextId();
    JSValue xValue = JS_GetPropertyUint32(ctx, params, 0);
    JSValue yValue = JS_GetPropertyUint32(ctx, params, 1);
    JSValue changeValue = JS_GetPropertyUint32(ctx, params, 2);

    double x;
    double y;
    double change;

    JS_ToFloat64(ctx, &x, xValue);
    JS_ToFloat64(ctx, &y, yValue);
    JS_ToFloat64(ctx, &change, changeValue);

    mouse->x = x;
    mouse->y = y;
    mouse->change = change;
    mousePointerList[i] = mouse;

    JS_FreeValue(ctx, params);
    JS_FreeValue(ctx, xValue);
    JS_FreeValue(ctx, yValue);
    JS_FreeValue(ctx, changeValue);
  }

  uint32_t pointer;
  JS_ToUint32(ctx, &pointer, pointerValue);

  context->dartMethodPtr()->simulatePointer(mousePointerList, length, pointer);

  delete[] mousePointerList;

  return JS_NULL;
}

static JSValue simulateInputText(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
  if (context->dartMethodPtr()->simulateInputText == nullptr) {
    return JS_ThrowTypeError(
        ctx, "Failed to execute '__kraken_simulate_keypress__': dart method(simulateInputText) is not registered.");
  }

  JSValue& charStringValue = argv[0];

  if (!JS_IsString(charStringValue)) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute '__kraken_simulate_keypress__': first arguments should be a string");
  }

  std::unique_ptr<NativeString> nativeString = kraken::jsValueToNativeString(ctx, charStringValue);
  void* p = static_cast<void*>(nativeString.get());
  context->dartMethodPtr()->simulateInputText(static_cast<NativeString*>(p));
  return JS_NULL;
};

static JSValue parseHTML(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  //  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  //
  //  if (argc == 1) {
  //    JSValue& html = argv[0];
  //
  //    std::string strHTML = jsValueToStdString(ctx, html);
  //
  //    JSValue bodyValue = JS_GetPropertyStr(context->ctx(), context->document()->jsObject, "body");
  //    auto* body = static_cast<ElementInstance*>(JS_GetOpaque(bodyValue, Element::classId()));
  //    HTMLParser::parseHTML(strHTML, body);
  //
  //    JS_FreeValue(ctx, bodyValue);
  //  }
  //
  //  return JS_NULL;
}

static JSValue triggerGlobalError(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));

  JSValue globalErrorFunc = JS_GetPropertyStr(ctx, context->Global(), "triggerGlobalError");

  if (JS_IsFunction(ctx, globalErrorFunc)) {
    JSValue exception = JS_Call(ctx, globalErrorFunc, context->Global(), 0, nullptr);
    context->HandleException(&exception);
    JS_FreeValue(ctx, globalErrorFunc);
  }

  return JS_NULL;
}

struct ExecuteCallbackContext {
  ExecuteCallbackContext() = delete;

  explicit ExecuteCallbackContext(ExecutingContext* context, ExecuteCallback executeCallback)
      : executeCallback(executeCallback), context(context){};
  ExecuteCallback executeCallback;
  ExecutingContext* context;
};

void KrakenTestContext::invokeExecuteTest(ExecuteCallback executeCallback) {
  //  if (JS_IsNull(executeTestCallback)) {
  //    return;
  //  }
  //  if (!JS_IsFunction(m_page_context->ctx(), executeTestCallback)) {
  //    return;
  //  }
  //
  //  auto done = [](JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic, JSValue* func_data)
  //  -> JSValue {
  //    JSValue& statusValue = argv[0];
  //    JSValue proxyObject = func_data[0];
  //    auto* callbackContext = static_cast<ExecuteCallbackContext*>(JS_GetOpaque(proxyObject, 1));
  //
  //    if (!JS_IsString(statusValue)) {
  //      return JS_ThrowTypeError(ctx, "failed to execute 'done': parameter 1 (status) is not a string");
  //    }
  //
  //    std::unique_ptr<NativeString> status = kraken::jsValueToNativeString(ctx, statusValue);
  //    callbackContext->executeCallback(callbackContext->context->getContextId(), status.get());
  //    return JS_NULL;
  //  };
  //  auto* callbackContext = new ExecuteCallbackContext(m_page_context, executeCallback);
  //  executeTestProxyObject = JS_NewObject(m_page_context->ctx());
  //  JS_SetOpaque(executeTestProxyObject, callbackContext);
  //  JSValue callbackData[]{executeTestProxyObject};
  //  JSValue callback = JS_NewCFunctionData(m_page_context->ctx(), done, 0, 0, 1, callbackData);
  //
  //  JSValue arguments[] = {callback};
  //  JSValue result = JS_Call(m_page_context->ctx(), executeTestCallback, executeTestCallback, 1, arguments);
  //  m_page_context->handleException(&result);
  //  m_page_context->drainPendingPromiseJobs();
  //  JS_FreeValue(m_page_context->ctx(), executeTestCallback);
  //  JS_FreeValue(m_page_context->ctx(), callback);
  //  executeTestCallback = JS_NULL;
}

void KrakenTestContext::registerTestEnvDartMethods(uint64_t* methodBytes, int32_t length) {
  size_t i = 0;

  auto& dartMethodPtr = m_context->dartMethodPtr();

  dartMethodPtr->onJsError = reinterpret_cast<OnJSError>(methodBytes[i++]);
  dartMethodPtr->matchImageSnapshot = reinterpret_cast<MatchImageSnapshot>(methodBytes[i++]);
  dartMethodPtr->environment = reinterpret_cast<Environment>(methodBytes[i++]);
  dartMethodPtr->simulatePointer = reinterpret_cast<SimulatePointer>(methodBytes[i++]);
  dartMethodPtr->simulateInputText = reinterpret_cast<SimulateInputText>(methodBytes[i++]);

  assert_m(i == length, "Dart native methods count is not equal with C++ side method registrations.");
}

}  // namespace kraken
