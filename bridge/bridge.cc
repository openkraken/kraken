/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge.h"
#include "bindings/KOM/console.h"
#include "bindings/KOM/location.h"
#include "bindings/KOM/screen.h"
#include "bindings/KOM/timer.h"
#include "bindings/KOM/window.h"
#include "bindings/KOM/blob.h"
#include "bindings/KOM/toBlob.h"
#include "polyfill.h"

#include "dart_methods.h"
#include "foundation/flushUITask.h"
#include "jsa.h"
#include "thread_safe_array.h"
#include <atomic>
#include <cassert>
#include <cstdlib>
#include <iostream>
#include <memory>

namespace kraken {
namespace {

using namespace alibaba::jsa;

ThreadSafeArray<std::shared_ptr<Value>> krakenUIListenerList;
ThreadSafeArray<std::shared_ptr<Value>> krakenModuleListenerList;
/**
 * Message channel, send message from JS to Dart.
 * @param context
 * @param thisVal
 * @param args
 * @param count
 * @return JSValue
 */
Value krakenUIManager(JSContext &context, const Value &thisVal,
                     const Value *args, size_t count) {
  if (count < 1) {
    throw JSError(context, "[krakenUIManager ERROR]: function missing parameter");
  }

  auto &&message = args[0];
  const std::string messageStr = message.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[krakenUIManager]: " << messageStr << std::endl;
  }

  if (getDartMethod()->invokeUIManager == nullptr) {
    throw JSError(context, "[krakenUIManager ERROR]: dart callbacks not register");
  }

  const char *result = getDartMethod()->invokeUIManager(messageStr.c_str());
  if (result == nullptr) {
    return Value::null();
  }
  return String::createFromUtf8(context, std::string(result));
}

struct CallbackContext {
  CallbackContext(JSContext &context, std::shared_ptr<Value> callback)
      : _context(context), _callback(std::move(callback)){};

  JSContext &_context;
  std::shared_ptr<Value> _callback;
};




void handleInvokeModuleTransientCallback(char *json, void *data) {
  auto *obj = static_cast<CallbackContext *>(data);
  JSContext &_context = obj->_context;
  if (!_context.isValid())
    return;

  if (obj->_callback == nullptr) {
    JSError error(obj->_context, "Callback is null");
    obj->_context.reportError(error);
    return;
  }

  Object callback = obj->_callback->getObject(_context);
  callback.asFunction(_context).call(_context, String::createFromUtf8(_context, std::string(json)));

  delete obj;
}


Value invokeModule(JSContext &context, const Value &thisVal, const Value *args,
                 size_t count) {

  const Value &message = args[0];
  const std::string messageStr = message.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[invokeModule]: " << messageStr << std::endl;
  }

  if (getDartMethod()->invokeModule == nullptr) {
    throw JSError(context, "Dart method 'invokeModule' not registered.");
  }

  CallbackContext *callbackContext = nullptr;

  if (count == 2) {
    std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[1].getObject(context)));
    Object &&callbackFunction = callbackValue->getObject(context);
    callbackContext = new CallbackContext(context, callbackValue);
  }

  const char *result = getDartMethod()->invokeModule(messageStr.c_str(),
      handleInvokeModuleTransientCallback, static_cast<void *>(callbackContext));

  if (result == nullptr) {
    return Value::null();
  }
  return String::createFromUtf8(context, std::string(result));
}

/**
 * Message channel, send message from Dart to JS.
 * @param context
 * @param thisVal
 * @param args
 * @param count
 * @return
 */
Value krakenUIListener(JSContext &context, const Value &thisVal,
                 const Value *args, size_t count) {
  if (count < 1) {
    throw JSError(context, "[krakenUIListener ERROR]: function missing parameter");
  }

  if (!args[0].isObject() || !args[0].getObject(context).isFunction(context)) {
    throw JSError(context, "[krakenUIListener ERROR]: parameter should be a function");
  }

  std::shared_ptr<Value> val =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&func = val->getObject(context);

  krakenUIListenerList.push(val);

  return Value::undefined();
}

Value krakenModuleListener(JSContext &context, const Value &thisVal,
                     const Value *args, size_t count) {
  if (count < 1) {
    throw JSError(context, "[krakenModuleListener ERROR]: function missing parameter");
  }

  if (!args[0].isObject() || !args[0].getObject(context).isFunction(context)) {
    throw JSError(context, "[krakenModuleListener ERROR]: parameter should be a function");
  }

  std::shared_ptr<Value> val =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&func = val->getObject(context);

  krakenModuleListenerList.push(val);

  return Value::undefined();
}

void handleTransientCallback(void *data) {
  auto *obj = static_cast<CallbackContext *>(data);
  JSContext &_context = obj->_context;
  if (!_context.isValid())
    return;

  if (obj->_callback == nullptr) {
    JSError error(obj->_context, "Callback is null");
    obj->_context.reportError(error);
    return;
  }

  Object callback = obj->_callback->getObject(_context);
  callback.asFunction(_context).call(_context, Value::undefined(), 0);
  delete obj;
}

Value requestBatchUpdate(JSContext &context, const Value &thisVal,
                            const Value *args, size_t count) {
  if (count <= 0) {
    throw JSError(context, "[requestBatchUpdate] function missing parameters");
  }

  if (!args[0].isObject() || !args[0].getObject(context).isFunction(context)) {
    throw JSError(context, "[requestBatchUpdate] first param should be a function");
  }

  std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&callbackFunction = callbackValue->getObject(context);

  // the context pointer which will be pass by pointer address to dart code.
  auto *callbackContext = new CallbackContext(context, callbackValue);

  if (getDartMethod()->requestBatchUpdate == nullptr) {
    throw JSError(context, "[requestBatchUpdate] dart callback not register");
  }

  getDartMethod()->requestBatchUpdate(handleTransientCallback, static_cast<void *>(callbackContext));

  return Value::undefined();
}

#ifdef IS_TEST
Value getValue(JSContext &context, const Value &thisVal, const Value *args,
               size_t count) {
  if (count != 1) {
    KRAKEN_LOG(VERBOSE) << "[TEST] getValue() accept 1 params";
    return Value::undefined();
  }

  const Value &name = args[0];
  return JSA_GLOBAL_GET_PROPERTY(context, name.getString(context).utf8(context).c_str());
}
#endif

} // namespace

/**
 * JSRuntime
 */
JSBridge::JSBridge(alibaba::jsa::JSExceptionHandler handler) {
#ifdef KRAKEN_JSC_ENGINE
  context = alibaba::jsc::createJSContext(handler);
#elif KRAKEN_V8_ENGINE
  alibaba::jsa_v8::initV8Engine("");
  context = alibaba::jsa_v8::createJSContext();
#endif

  // Inject JSC global objects
  kraken::binding::bindKraken(context);
  kraken::binding::bindConsole(context);
  kraken::binding::bindTimer(context);
  kraken::binding::bindBlob(context);
  kraken::binding::bindToBlob(context);

  websocket_ = std::make_shared<kraken::binding::JSWebSocket>();
  websocket_->bind(context);
  window_ = std::make_shared<kraken::binding::JSWindow>();
  window_->bind(context);
  screen_ = std::make_shared<kraken::binding::JSScreen>();
  screen_->bind(context);

  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_ui_manager__", 0,
                       krakenUIManager);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_ui_listener__", 0,
                       krakenUIListener);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_module_listener__", 0,
                       krakenModuleListener);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_invoke_module__", 0,
                       invokeModule);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_request_batch_update__", 0,
                       requestBatchUpdate);

  initKrakenPolyFill(context.get());
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
  devtools_front_door_ = kraken::Debugger::FrontDoor::newInstance(
      reinterpret_cast<JSC::JSGlobalObject *>(globalImpl), nullptr,
      "127.0.0.1");
  devtools_front_door_->setup();
}

void JSBridge::detachDevtools() {
  assert(devtools_front_door_ != nullptr);
  KRAKEN_LOG(VERBOSE) << "Kraken will detach devtools ...";
  devtools_front_door_->terminate();
}
#endif // ENABLE_DEBUGGER

void JSBridge::handleUIListener(const char *args) {

  int length = krakenUIListenerList.length();

  for (int i = 0; i < length; i++) {
    std::shared_ptr<Value> callback;
    krakenUIListenerList.get(i, callback);

    if (callback.get() == nullptr) {
      throw JSError(*context, "[krakenUIListener ERROR]: you should initialize UI listener");
    }

    if (!callback->getObject(*context).isFunction(*context)) {
      throw JSError(*context, "[krakenUIListener ERROR]: callback is not a function");
    }

    const String str = String::createFromAscii(*context, args);
    callback->getObject(*context).asFunction(*context).callWithThis(
        *context, context->global(), str, 1);
  }
}

void JSBridge::handleModuleListener(const char *args) {

  int length = krakenModuleListenerList.length();

  for (int i = 0; i < length; i++) {
    std::shared_ptr<Value> callback;
    krakenModuleListenerList.get(i, callback);

    if (callback == nullptr) {
      throw JSError(*context, "[krakenModuleListener ERROR]: you should initialize Module listener");
    }

    if (!callback->getObject(*context).isFunction(*context)) {
      throw JSError(*context, "[krakenModuleListener ERROR]: callback is not a function");
    }

    const String str = String::createFromAscii(*context, args);
    callback->getObject(*context).asFunction(*context).callWithThis(
        *context, context->global(), str, 1);
  }
}

const int UI_EVENT = 0;
const int MODULE_EVENT = 1;

void JSBridge::invokeEventListener(int32_t type, const char *args) {
  if (!context->isValid()) return;

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[invokeEventListener VERBOSE]: message " << args;
  }
  try {
    if (UI_EVENT == type) {
      this->handleUIListener(args);
    } else if (MODULE_EVENT == type) {
      this->handleModuleListener(args);
    }
  } catch (JSError &error) {
    handler_(error);
  }
}

alibaba::jsa::Value JSBridge::evaluateScript(const std::string &script, const std::string &url,
                              int startLine) {
  if (!context->isValid()) return Value::undefined();
  binding::updateLocation(url);
  return context->evaluateJavaScript(script.c_str(), url.c_str(), startLine);

#ifdef ENABLE_DEBUGGER
  devtools_front_door_->notifyPageDiscovered(url, script);
#endif

  return Value::undefined();
}

JSBridge::~JSBridge() {
  if (!context->isValid()) return;
  window_->unbind(context);
  screen_->unbind(context);
  websocket_->unbind(context);
  krakenUIListenerList.clear();
  krakenModuleListenerList.clear();
}

Value JSBridge::getGlobalValue(std::string code) {
  return context->evaluateJavaScript(code.c_str(), "test://", 0);
}

void JSBridge::invokeOnloadCallback() {
  if (!context->isValid()) return;
  try {
    window_->invokeOnloadCallback(context);
  } catch (JSError &error) {
    handler_(error);
  }
}

void JSBridge::invokeOnPlatformBrightnessChangedCallback() {
  if (!context->isValid()) return;
  try {
    window_->invokeOnPlatformBrightnessChangedCallback(context);
  } catch (JSError &error) {
    handler_(error);
  }
}

void JSBridge::flushUITask() {
  if (!context->isValid()) return;
  try {
    kraken::foundation::flushUITask();
  } catch (JSError &error) {
    handler_(error);
  }
}

} // namespace kraken
