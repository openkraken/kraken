/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge.h"
#include "bindings/KOM/console.h"
#include "bindings/KOM/fetch.h"
#include "bindings/KOM/location.h"
#include "bindings/KOM/screen.h"
#include "bindings/KOM/timer.h"
#include "bindings/KOM/window.h"

#include "dart_methods.h"
#include "foundation/flushUITask.h"
#include "jsa.h"
#include "logging.h"
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
    KRAKEN_LOG(WARN) << "[krakenUIManager ERROR]: function missing parameter";
    return Value::undefined();
  }

  auto &&message = args[0];
  const std::string messageStr = message.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[krakenUIManager]: " << messageStr << std::endl;
  }

  if (getDartMethod()->invokeUIManager == nullptr) {
    KRAKEN_LOG(ERROR) << "[krakenUIManager ERROR]: dart callbacks not register";
    return Value::undefined();
  }

  const char *result = getDartMethod()->invokeUIManager(messageStr.c_str());
  if (result == nullptr) {
    return Value::null();
  }
  return String::createFromUtf8(context, std::string(result));
}

std::atomic<int> methodCallbackId = {1};
ThreadSafeMap<int, std::shared_ptr<Value>> methodCallbackMap;

Value krakenModuleManager(JSContext &context, const Value &thisVal,
                     const Value *args, size_t count) {
  if (count < 1) {
    KRAKEN_LOG(WARN) << "[krakenModuleManager ERROR]: function missing parameter";
    return Value::undefined();
  }

  const Value &message = args[0];
  // Default 0 is not callback
  int callbackId = 0;
  if (count == 2) {
    const Value &func = args[1];
    if (func.getObject(context).isFunction(context)) {
      callbackId = methodCallbackId.load();
       std::shared_ptr<Value> funcValue = 
        std::make_shared<Value>(Value(func.getObject(context)));
      methodCallbackMap.set(callbackId, funcValue);
      methodCallbackId = callbackId + 1;
    }
  }

  const std::string messageStr = message.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[krakenModuleManager]: " << messageStr << std::endl;
  }

  if (getDartMethod()->invokeUIManager == nullptr) {
    KRAKEN_LOG(ERROR) << "[krakenModuleManager ERROR]: dart callbacks not register";
    return Value::undefined();
  }

  const char *result = getDartMethod()->invokeModuleManager(messageStr.c_str(), callbackId);
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
    KRAKEN_LOG(WARN) << "[krakenUIListener ERROR]: function missing parameter";
    return Value::undefined();
  }

  std::shared_ptr<Value> val =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&func = val->getObject(context);

  if (!func.isFunction(context)) {
    KRAKEN_LOG(WARN)
        << "[krakenUIListener ERROR]: parameter should be a function";
    return Value::undefined();
  }

  krakenUIListenerList.push(val);

  return Value::undefined();
}

Value krakenModuleListener(JSContext &context, const Value &thisVal,
                     const Value *args, size_t count) {
  if (count < 1) {
    KRAKEN_LOG(WARN) << "[krakenModuleListener ERROR]: function missing parameter";
    return Value::undefined();
  }

  std::shared_ptr<Value> val =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&func = val->getObject(context);

  if (!func.isFunction(context)) {
    KRAKEN_LOG(WARN)
        << "[krakenModuleListener ERROR]: parameter should be a function";
    return Value::undefined();
  }

  krakenModuleListenerList.push(val);

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
JSBridge::JSBridge() {
  context = alibaba::jsc::createJSContext();

  // Inject JSC global objects
  kraken::binding::bindKraken(context);
  kraken::binding::bindConsole(context);
  kraken::binding::bindTimer(context);
  kraken::binding::bindFetch(context);

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
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_module_manager__", 0,
                       krakenModuleManager);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_module_listener__", 0,
                       krakenModuleListener);
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
      KRAKEN_LOG(WARN) << "[krakenUIListener ERROR]: you should initialize UI listener";
      return;
    }

    if (!callback->getObject(*context).isFunction(*context)) {
      KRAKEN_LOG(WARN) << "[krakenUIListener ERROR]: callback is not a function";
      return;
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

    if (callback.get() == nullptr) {
      KRAKEN_LOG(WARN) << "[krakenModuleListener ERROR]: you should initialize Module listener";
      return;
    }

    if (!callback->getObject(*context).isFunction(*context)) {
      KRAKEN_LOG(WARN) << "[krakenModuleListener ERROR]: callback is not a function";
      return;
    }

    const String str = String::createFromAscii(*context, args);
    callback->getObject(*context).asFunction(*context).callWithThis(
        *context, context->global(), str, 1);
  }
}

const int UI_EVENT = 0;
const int MODULE_EVENT = 1;

void JSBridge::invokeEventListener(int32_t type, const char *args) {
  assert(context != nullptr);

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
    auto &&stack = error.getStack();
    auto &&message = error.getMessage();
    // TODO throw error in js context
    KRAKEN_LOG(ERROR) << message << "\n" << stack;
  }
}

void JSBridge::evaluateScript(const std::string &script, const std::string &url,
                              int startLine) {
  assert(context != nullptr);
  try {
    binding::updateLocation(url);
    context->evaluateJavaScript(script.c_str(), url.c_str(), startLine);
  } catch (JSError error) {
    auto &&stack = error.getStack();
    auto &&message = error.getMessage();

    // TODO throw error in js context
    KRAKEN_LOG(ERROR) << message << "\n" << stack;
  }

#ifdef ENABLE_DEBUGGER
  devtools_front_door_->notifyPageDiscovered(url, script);
#endif
}

JSBridge::~JSBridge() {
  window_->unbind(context);
  screen_->unbind(context);
  websocket_->unbind(context);
  binding::unbindTimer();
  binding::unbindFetch();
  krakenUIListenerList.clear();
  krakenModuleListenerList.clear();
}

Value JSBridge::getGlobalValue(std::string code) {
  return context->evaluateJavaScript(code.c_str(), "test://", 0);
}

void JSBridge::invokeSetTimeoutCallback(int32_t callbackId) {
  kraken::binding::invokeSetTimeoutCallback(context, callbackId);
}

void JSBridge::invokeSetIntervalCallback(int32_t callbackId) {
  kraken::binding::invokeSetIntervalCallback(context, callbackId);
}

void JSBridge::invokeRequestAnimationFrameCallback(int32_t callbackId) {
  kraken::binding::invokeRequestAnimationFrameCallback(context, callbackId);
}

void JSBridge::invokeFetchCallback(int32_t callbackId, const char *error,
                                   int32_t statusCode, const char *body) {
  kraken::binding::invokeFetchCallback(context, callbackId, std::string(error),
                                       statusCode, std::string(body));
}

void JSBridge::invokeModuleCallback(int32_t callbackId, const char *json) {
  std::shared_ptr<Value> funcValue;
  methodCallbackMap.get(callbackId, funcValue);

  if (funcValue.get() == nullptr) {
    KRAKEN_LOG(VERBOSE) << "Module method callback is null";
    return;
  }

  Object funcObj = funcValue->asObject(*context);
  funcObj.asFunction(*context).call(*context, String::createFromUtf8(*context, json));
}

void JSBridge::invokeOnloadCallback() {
  window_->invokeOnloadCallback(context);
}

void JSBridge::invokeOnPlatformBrightnessChangedCallback() {
  window_->invokeOnPlatformBrightnessChangedCallback(context);
}

void JSBridge::flushUITask() {
  kraken::foundation::flushUITask();
}

} // namespace kraken
