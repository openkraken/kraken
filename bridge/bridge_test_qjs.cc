/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge_test_qjs.h"
//#include "bindings/jsc/KOM/blob.h"
//#include "bindings/jsc/KOM/location.h"
//#include "dart_methods.h"
//#include "foundation/bridge_callback.h"
//#include "testframework.h"

namespace kraken {

using namespace kraken::foundation;

//bool JSBridgeTest::evaluateTestScripts(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine) {
//  if (!context->isValid()) return false;
//  binding::jsc::updateLocation(sourceURL);
//  return context->evaluateJavaScript(code, codeLength, sourceURL, startLine);
//}
//
//JSValueRef executeTest(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                       const JSValueRef *arguments, JSValueRef *exception) {
//  const JSValueRef &callback = arguments[0];
//
//  auto context = static_cast<binding::jsc::JSContext *>(JSObjectGetPrivate(function));
//  if (!JSValueIsObject(ctx, callback)) {
//    binding::jsc::throwJSError(ctx, "Failed to execute 'executeTest': parameter 1 (callback) is not an function.", exception);
//    return nullptr;
//  }
//
//  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callback, exception);
//
//  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
//    binding::jsc::throwJSError(ctx, "Failed to execute 'executeTest': parameter 1 (callback) is not an function.", exception);
//    return nullptr;
//  }
//
//  auto bridge = static_cast<JSBridge *>(context->getOwner());
//  auto bridgeTest = static_cast<JSBridgeTest *>(bridge->owner);
//  JSValueProtect(ctx, callbackObjectRef);
//  bridgeTest->executeTestCallback = callbackObjectRef;
//  return nullptr;
//}
//
//JSValueRef matchImageSnapshot(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                              const JSValueRef *arguments, JSValueRef *exception) {
//  const JSValueRef blobValueRef = arguments[0];
//  const JSValueRef screenShotValueRef = arguments[1];
//  const JSValueRef callbackValueRef = arguments[2];
//
//  auto context = static_cast<binding::jsc::JSContext *>(JSObjectGetPrivate(function));
//  if (!JSValueIsObject(ctx, blobValueRef)) {
//    binding::jsc::throwJSError(ctx, "Failed to execute '__kraken_match_image_snapshot__': parameter 1 (blob) must be an Blob object.",
//                    exception);
//    return nullptr;
//  }
//
//  JSObjectRef blobObjectRef = JSValueToObject(ctx, blobValueRef, exception);
//  auto blob = static_cast<binding::jsc::JSBlob::BlobInstance *>(JSObjectGetPrivate(blobObjectRef));
//
//  if (blob == nullptr) {
//    binding::jsc::throwJSError(ctx, "Failed to execute '__kraken_match_image_snapshot__': parameter 1 (blob) must be an Blob object.",
//                    exception);
//    return nullptr;
//  }
//
//  if (!JSValueIsString(ctx, screenShotValueRef)) {
//    binding::jsc::throwJSError(ctx, "Failed to execute '__kraken_match_image_snapshot__': parameter 2 (match) must be an string.",
//                    exception);
//    return nullptr;
//  }
//
//  if (!JSValueIsObject(ctx, callbackValueRef)) {
//    binding::jsc::throwJSError(ctx,
//                    "Failed to execute '__kraken_match_image_snapshot__': parameter 3 (callback) is not an function.",
//                    exception);
//    return nullptr;
//  }
//
//  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackValueRef, exception);
//
//  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
//    binding::jsc::throwJSError(ctx,
//                    "Failed to execute '__kraken_match_image_snapshot__': parameter 3 (callback) is not an function.",
//                    exception);
//    return nullptr;
//  }
//
//  if (getDartMethod()->matchImageSnapshot == nullptr) {
//    binding::jsc::throwJSError(
//      ctx, "Failed to execute '__kraken_match_image_snapshot__': dart method (matchImageSnapshot) is not registered.",
//      exception);
//    return nullptr;
//  }
//
//  JSStringRef screenShotStringRef = JSValueToStringCopy(ctx, screenShotValueRef, exception);
//  const uint16_t *unicodePtr = JSStringGetCharactersPtr(screenShotStringRef);
//  size_t unicodeLength = JSStringGetLength(screenShotStringRef);
//
//  NativeString nativeString{};
//  nativeString.string = unicodePtr;
//  nativeString.length = unicodeLength;
//
//  auto callbackContext = std::make_unique<BridgeCallback::Context>(*context, callbackObjectRef, exception);
//
//  auto fn = [](void *ptr, int32_t contextId, int8_t result) {
//    JSValueRef exception = nullptr;
//    auto callbackContext = static_cast<BridgeCallback::Context *>(ptr);
//    binding::jsc::JSContext &_context = callbackContext->_context;
//    JSContextRef ctx = _context.context();
//    JSObjectRef callbackObjectRef = JSValueToObject(ctx, callbackContext->_callback, &exception);
//    const JSValueRef arguments[] = {JSValueMakeBoolean(ctx, result != 0)};
//    JSObjectCallAsFunction(ctx, callbackObjectRef, _context.global(), 1, arguments, &exception);
//    auto bridge = static_cast<JSBridge *>(callbackContext->_context.getOwner());
//    bridge->bridgeCallback->freeBridgeCallbackContext(callbackContext);
//    _context.handleException(exception);
//  };
//
//  auto bridge = static_cast<JSBridge *>(context->getOwner());
//  bridge->bridgeCallback->registerCallback<void>(
//    std::move(callbackContext),
//    [&blob, &nativeString, &fn](BridgeCallback::Context *callbackContext, int32_t contextId) {
//      getDartMethod()->matchImageSnapshot(callbackContext, contextId, blob->bytes(), blob->size(), &nativeString, fn);
//    });
//
//  return nullptr;
//}
//
//JSValueRef environment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                       const JSValueRef *arguments, JSValueRef *exception) {
//  if (getDartMethod()->environment == nullptr) {
//    binding::jsc::throwJSError(ctx, "Failed to execute '__kraken_environment__': dart method (environment) is not registered.",
//                    exception);
//    return nullptr;
//  }
//  const char *env = getDartMethod()->environment();
//  JSStringRef envStringRef = JSStringCreateWithUTF8CString(env);
//  return JSValueMakeFromJSONString(ctx, envStringRef);
//}
//
//JSValueRef simulatePointer(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                           const JSValueRef *arguments, JSValueRef *exception) {
//  if (getDartMethod()->simulatePointer == nullptr) {
//    binding::jsc::throwJSError(ctx,
//                    "Failed to execute '__kraken_simulate_pointer__': dart method(simulatePointer) is not registered.",
//                    exception);
//    return nullptr;
//  }
//
//  auto context = static_cast<binding::jsc::JSContext *>(JSObjectGetPrivate(function));
//
//  const JSValueRef &firstArgsValueRef = arguments[0];
//  if (!JSValueIsObject(ctx, firstArgsValueRef)) {
//    binding::jsc::throwJSError(ctx, "Failed to execute '__kraken_simulate_pointer__': first arguments should be an array.",
//                    exception);
//    return nullptr;
//  }
//
//  JSObjectRef inputArrayObjectRef = JSValueToObject(ctx, firstArgsValueRef, exception);
//  size_t length;
//
//  {
//    JSStringRef lengthRef = JSStringCreateWithUTF8CString("length");
//    JSValueRef lengthValue = JSObjectGetProperty(ctx, inputArrayObjectRef, lengthRef, exception);
//    length = JSValueToNumber(ctx, lengthValue, exception);
//    JSStringRelease(lengthRef);
//  }
//
//  auto **mousePointerList = new MousePointer *[length];
//
//  for (int i = 0; i < length; i++) {
//    auto mouse = new MousePointer();
//
//    JSValueRef params = JSObjectGetPropertyAtIndex(ctx, inputArrayObjectRef, i, exception);
//    JSObjectRef paramsObjectRef = JSValueToObject(ctx, params, exception);
//    mouse->contextId = context->getContextId();
//    mouse->x = JSValueToNumber(ctx, JSObjectGetPropertyAtIndex(ctx, paramsObjectRef, 0, exception), exception);
//    mouse->y = JSValueToNumber(ctx, JSObjectGetPropertyAtIndex(ctx, paramsObjectRef, 1, exception), exception);
//    mouse->change = JSValueToNumber(ctx, JSObjectGetPropertyAtIndex(ctx, paramsObjectRef, 2, exception), exception);
//    mousePointerList[i] = mouse;
//  }
//
//  getDartMethod()->simulatePointer(mousePointerList, length);
//
//  delete[] mousePointerList;
//
//  return nullptr;
//}
//
//JSValueRef simulateKeyPress(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                            const JSValueRef *arguments, JSValueRef *exception) {
//  if (getDartMethod()->simulateKeyPress == nullptr) {
//    binding::jsc::throwJSError(ctx,
//                    "Failed to execute '__kraken_simulate_keypress__': dart method(simulateKeyPress) is not registered.",
//                    exception);
//    return nullptr;
//  }
//
//  const JSValueRef &firstArgsValueRef = arguments[0];
//  if (!JSValueIsString(ctx, firstArgsValueRef)) {
//    binding::jsc::throwJSError(ctx, "Failed to execute '__kraken_simulate_keypress__': first arguments should be a string.",
//                    exception);
//    return nullptr;
//  }
//
//  JSStringRef charsStringRef = JSValueToStringCopy(ctx, firstArgsValueRef, exception);
//  NativeString nativeString{};
//  nativeString.length = JSStringGetLength(charsStringRef);
//  nativeString.string = JSStringGetCharactersPtr(charsStringRef);
//  getDartMethod()->simulateKeyPress(&nativeString);
//  JSStringRelease(charsStringRef);
//  return nullptr;
//}
//
JSBridgeTest::JSBridgeTest(JSBridge *bridge) : bridge_(bridge), context(bridge->getContext()) {
  bridge->owner = this;
//  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_execute_test__", executeTest);
//  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_match_image_snapshot__", matchImageSnapshot);
//  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_environment__", environment);
//  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_simulate_pointer__", simulatePointer);
//  JSC_GLOBAL_BINDING_FUNCTION(context, "__kraken_simulate_keypress__", simulateKeyPress);

//  initKrakenTestFramework(bridge);
}
//
//struct ExecuteCallbackContext {
//  ExecuteCallbackContext() = delete;
//  explicit ExecuteCallbackContext(binding::jsc::JSContext *context, ExecuteCallback executeCallback)
//    : executeCallback(executeCallback), context(context){};
//  ExecuteCallback executeCallback;
//  binding::jsc::JSContext *context;
//};
//
//void JSBridgeTest::invokeExecuteTest(ExecuteCallback executeCallback) {
//  if (executeTestCallback == nullptr) {
//    return;
//  }
//
//  auto *callbackContext = new ExecuteCallbackContext(context.get(), executeCallback);
//
//  auto done = [](JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
//                 const JSValueRef arguments[], JSValueRef *exception) -> JSValueRef {
//    const JSValueRef &statusValueRef = arguments[0];
//    auto callbackContext = static_cast<ExecuteCallbackContext *>(JSObjectGetPrivate(function));
//
//    if (!JSValueIsString(ctx, statusValueRef)) {
//      binding::jsc::throwJSError(ctx, "failed to execute 'done': parameter 1 (status) is not a string", exception);
//      return nullptr;
//    }
//    JSStringRef statusString = JSValueToStringCopy(ctx, statusValueRef, exception);
//    NativeString nativeString{};
//    nativeString.string = JSStringGetCharactersPtr(statusString);
//    nativeString.length = JSStringGetLength(statusString);
//    callbackContext->executeCallback(callbackContext->context->getContextId(), &nativeString);
//    return nullptr;
//  };
//
//  JSObjectRef executeTestCallbackObject = JSValueToObject(context->context(), executeTestCallback, nullptr);
//  JSObjectSetPrivate(executeTestCallbackObject, callbackContext);
//
//  JSObjectRef callback =
//    kraken::binding::jsc::makeObjectFunctionWithPrivateData(context.get(), callbackContext, "done", done);
//  const JSValueRef arguments[] = {callback};
//
//  JSObjectCallAsFunction(context->context(), executeTestCallbackObject, context->global(), 1, arguments, nullptr);
//  JSValueUnprotect(context->context(), executeTestCallback);
//  executeTestCallback = nullptr;
//}

} // namespace kraken
