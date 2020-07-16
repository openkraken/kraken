/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge.h"
#include "bindings/KOM/blob.h"
#include "bindings/KOM/console.h"
#include "bindings/KOM/location.h"
#include "bindings/KOM/screen.h"
#include "bindings/KOM/timer.h"
#include "bindings/KOM/toBlob.h"
#include "bindings/KOM/window.h"
#include "foundation/bridge_callback.h"
#include "polyfill.h"

#include "dart_methods.h"
#include "jsa.h"
#include "thread_safe_array.h"
#include <atomic>
#include <cstdlib>
#include <memory>

namespace kraken {
namespace {

using namespace foundation;

/**
 * Message channel, send message from JS to Dart.
 * @param context
 * @param thisVal
 * @param args
 * @param count
 * @return JSValue
 */
Value krakenUIManager(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count < 1) {
    throw JSError(context, "Failed to execute '__kraken_ui_manager__': 1 argument required, but only 0 present.");
  }

  if (context.isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to execute '__kraken_ui_manager__': context is freeze" << std::endl;
    return Value::undefined();
  }

  auto &&message = args[0];
  const std::string messageStr = message.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[krakenUIManager]: " << messageStr << std::endl;
  }

  if (getDartMethod()->invokeUIManager == nullptr) {
    throw JSError(context,
                  "Failed to execute '__kraken_ui_manager__': dart method (invokeUIManager) is not registered.");
  }

  const char *result = getDartMethod()->invokeUIManager(&context, context.getContextIndex(), messageStr.c_str());
  std::string resultStr = std::string(result);

  if (resultStr.find("Error:", 0) != std::string::npos) {
    throw JSError(context, result);
  }

  if (resultStr.empty()) {
    return Value::null();
  }

  return Value(context, String::createFromUtf8(context, resultStr));
}

void handleInvokeModuleTransientCallback(void *callbackContext, void *context, int32_t contextIndex, char *json) {
  auto *obj = static_cast<BridgeCallback::Context *>(callbackContext);
  JSContext &_context = obj->_context;

  if (!BridgeCallback::checkContext(_context, contextIndex)) {
    return;
  }

  if (!_context.isValid()) return;

  if (_context.isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to execute '__kraken_invoke_module': context is freeze" << std::endl;
    return;
  }

  if (obj->_callback == nullptr) {
    JSError error(obj->_context, "Failed to execute '__kraken_invoke_module__': callback is null.");
    obj->_context.reportError(error);
    return;
  }

  Object callback = obj->_callback->getObject(_context);
  callback.asFunction(_context).call(_context, String::createFromUtf8(_context, std::string(json)));
}

Value invokeModule(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (context.isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to execute __kraken_invoke_module__: context is freeze" << std::endl;
    return Value::undefined();
  }

  const Value &message = args[0];
  const std::string messageStr = message.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr && strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[invokeModule]: " << messageStr << std::endl;
  }

  if (getDartMethod()->invokeModule == nullptr) {
    throw JSError(context,
                  "Failed to execute '__kraken_invoke_module__': dart method (invokeModule) is not registered.");
  }

  std::unique_ptr<BridgeCallback::Context> callbackContext = nullptr;

  if (count < 2) {
    HostFunctionType emptyCallback = [](JSContext &context, const Value &thisVal, const Value *args,
                                        size_t count) -> Value { return Value::undefined(); };

    std::shared_ptr<Value> callbackValue = std::make_shared<Value>(
      Function::createFromHostFunction(context, PropNameID::forAscii(context, "f"), 0, emptyCallback));
    Object &&callbackFunction = callbackValue->getObject(context);
    callbackContext = std::make_unique<BridgeCallback::Context>(context, callbackValue);
  } else if (count == 2) {
    std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, args[1].getObject(context)));
    Object &&callbackFunction = callbackValue->getObject(context);
    callbackContext = std::make_unique<BridgeCallback::Context>(context, callbackValue);
  }

  const char *result = BridgeCallback::instance()->registerCallback<const char *>(
    std::move(callbackContext),
    [&messageStr](BridgeCallback::Context *bridgeContext, JSBridge *bridge, int32_t contextIndex) {
      return getDartMethod()->invokeModule(bridgeContext, bridge, contextIndex, messageStr.c_str(),
                                           handleInvokeModuleTransientCallback);
    });

  if (result == nullptr) {
    return Value::null();
  }
  return Value(context, String::createFromUtf8(context, std::string(result)));
}

/**
 * Message channel, send message from Dart to JS.
 * @param context
 * @param thisVal
 * @param args
 * @param count
 * @return
 */
Value krakenUIListener(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count < 1) {
    throw JSError(context, "Failed to execute '__kraken_ui_listener__': 1 parameter required, but only 0 present.");
  }

  if (!args[0].isObject() || !args[0].getObject(context).isFunction(context)) {
    throw JSError(context, "Failed to execute '__kraken_ui_listener__': parameter 1 (callback) must be an function.");
  }

  if (context.isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to execute '__kraken_ui_listener__': context is freeze" << std::endl;
    return Value::undefined();
  }

  std::shared_ptr<Value> val = std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&func = val->getObject(context);

  auto bridge = static_cast<JSBridge *>(context.getOwner());
  bridge->krakenUIListenerList.emplace_back(val);

  return Value::undefined();
}

Value krakenModuleListener(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count < 1) {
    throw JSError(context, "Failed to execute '__kraken_module_listener__': 1 parameter required, but only 0 present.");
  }

  if (!args[0].isObject() || !args[0].getObject(context).isFunction(context)) {
    throw JSError(context,
                  "Failed to execute '__kraken_module_listener__': parameter 1 (callback) must be a function.");
  }

  if (context.isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to execute '_kraken_module_listener__': context is freeze" << std::endl;
    return Value::undefined();
  }

  std::shared_ptr<Value> val = std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&func = val->getObject(context);

  auto bridge = static_cast<JSBridge *>(context.getOwner());
  bridge->krakenModuleListenerList.emplace_back(val);

  return Value::undefined();
}

void handleTransientCallback(void *callbackContext, void *context, int32_t contextIndex, const char *errmsg) {
  auto *obj = static_cast<BridgeCallback::Context *>(callbackContext);
  JSContext &_context = obj->_context;

  if (!BridgeCallback::checkContext(_context, contextIndex)) {
    return;
  }

  if (!_context.isValid()) return;

  if (_context.isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to execute '__kraken_request_batch_update__': context is freeze" << std::endl;
    return;
  }

  if (obj->_callback == nullptr) {
    JSError error(obj->_context, "Failed to execute '__kraken_request_batch_update__': callback is null.");
    obj->_context.reportError(error);
    return;
  }

  if (errmsg != nullptr) {
    JSError error(obj->_context, errmsg);
    obj->_context.reportError(error);
    return;
  }

  Object callback = obj->_callback->getObject(_context);
  callback.asFunction(_context).call(_context, Value::undefined(), 0);
}

Value requestBatchUpdate(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  if (count <= 0) {
    throw JSError(context,
                  "Failed to execute '__kraken_request_batch_update__': 1 parameter required, but only 0 present.");
  }

  if (!args[0].isObject() || !args[0].getObject(context).isFunction(context)) {
    throw JSError(context,
                  "Failed to execute '__kraken_request_batch_update__': parameter 1 (callback) must be an function.");
  }

  if (context.isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to execute '__kraken_request_batch_update': context is freeze" << std::endl;
    return Value::undefined();
  }

  std::shared_ptr<Value> callbackValue = std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  // the context pointer which will be pass by pointer address to dart code.
  auto callbackContext = std::make_unique<BridgeCallback::Context>(context, callbackValue);

  if (getDartMethod()->requestBatchUpdate == nullptr) {
    throw JSError(
      context,
      "Failed to execute '__kraken_request_batch_update__': dart method (requestBatchUpdate) is not registered.");
  }

  BridgeCallback::instance()->registerCallback<void>(
    std::move(callbackContext), [](BridgeCallback::Context *callbackContext, JSBridge *bridge, int32_t contextIndex) {
      getDartMethod()->requestBatchUpdate(callbackContext, bridge, contextIndex, handleTransientCallback);
    });

  return Value::undefined();
}

} // namespace

/**
 * JSRuntime
 */
JSBridge::JSBridge(int32_t contextIndex, const alibaba::jsa::JSExceptionHandler &handler) : contextIndex(contextIndex) {
  auto errorHandler = [handler](alibaba::jsa::JSContext &context, const alibaba::jsa::JSError &error) {
    handler(context, error);
    // trigger window.onerror handler.
    const alibaba::jsa::Value &errorObject = error.value();
    context.global()
      .getPropertyAsObject(context, "__global_onerror_handler__")
      .getFunction(context)
      .call(context, Value(context, errorObject));
  };
#ifdef KRAKEN_JSC_ENGINE
  context = alibaba::jsc::createJSContext(contextIndex, errorHandler, this);
#elif KRAKEN_V8_ENGINE
  alibaba::jsa_v8::initV8Engine("");
  context = alibaba::jsa_v8::createJSContext(errorHandler);
#endif

  // Inject JSC global objects
  kraken::binding::bindKraken(context);
  kraken::binding::bindConsole(context);
  kraken::binding::bindTimer(context);
  kraken::binding::bindBlob(context);
  kraken::binding::bindToBlob(context);

  window_ = std::make_shared<kraken::binding::JSWindow>();
  window_->bind(context);
  screen_ = std::make_shared<kraken::binding::JSScreen>();
  screen_->bind(context);

  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_ui_manager__", 0, krakenUIManager);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_ui_listener__", 0, krakenUIListener);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_module_listener__", 0, krakenModuleListener);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_invoke_module__", 0, invokeModule);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_request_batch_update__", 0, requestBatchUpdate);

  initKrakenPolyFill(context.get());

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

void JSBridge::handleUIListener(const char *args) {
  if (context->isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to execute '__kraken_ui_listener__: context is freeze'" << std::endl;
    return;
  }

  for (const auto &callback : krakenUIListenerList) {
    if (callback == nullptr) {
      throw JSError(*context, "Failed to execute '__kraken_ui_listener__': can not get listener callback.");
    }

    if (!callback->getObject(*context).isFunction(*context)) {
      throw JSError(*context, "Failed to execute '__kraken_ui_listener__': callback is not a function.");
    }

    const String str = String::createFromAscii(*context, args);
    callback->getObject(*context).asFunction(*context).callWithThis(*context, context->global(), str, 1);
  }
}

void JSBridge::handleModuleListener(const char *args) {
  if (context->isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to execute '__kraken_module_listener__': context is freeze" << std::endl;
    return;
  }

  for (const auto &callback : krakenModuleListenerList) {
    if (callback == nullptr) {
      throw JSError(*context, "Failed to execute '__kraken_module_listener__': can not get callback.");
    }

    if (!callback->getObject(*context).isFunction(*context)) {
      throw JSError(*context, "Failed to execute '__kraken_module_listener__': callback is not a function.");
    }

    if (std::string(args).substr(0, 5) == "Error") {
      throw JSError(*context, args);
    }

    const String str = String::createFromAscii(*context, args);
    callback->getObject(*context).asFunction(*context).callWithThis(*context, context->global(), str, 1);
  }
}

const int UI_EVENT = 0;
const int MODULE_EVENT = 1;

void JSBridge::invokeEventListener(int32_t type, const char *args) {
  if (!context->isValid()) return;

  if (context->isFreeze()) {
    KRAKEN_LOG(ERROR) << "Failed to invokeEventListener: context is freeze" << std::endl;
    return;
  }

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

alibaba::jsa::Value JSBridge::evaluateScript(const std::string &script, const std::string &url, int startLine) {
  if (!context->isValid()) return Value::undefined();
  binding::updateLocation(url);
  return context->evaluateJavaScript(script.c_str(), url.c_str(), startLine);

#ifdef ENABLE_DEBUGGER
  devtools_front_door_->notifyPageDiscovered(url, script);
#endif
}

JSBridge::~JSBridge() {
  if (!context->isValid()) return;
  window_->unbind(context);
  screen_->unbind(context);
  krakenUIListenerList.clear();
  krakenModuleListenerList.clear();
  BridgeCallback::instance()->disposeAllCallbacks();
}

} // namespace kraken
