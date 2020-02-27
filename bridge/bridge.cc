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
#include "polyfill.h"

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

struct CallbackContext {
  CallbackContext(JSContext &context, std::shared_ptr<Value> callback)
      : _context(context), _callback(std::move(callback)){};

  JSContext &_context;
  std::shared_ptr<Value> _callback;
};

void handleTransientCallback(char *json, void *data) {
  auto *obj = static_cast<CallbackContext *>(data);
  JSContext &_context = obj->_context;
  std::shared_ptr<Value> _callback = obj->_callback;

  if (!_context.isValid())
    return;

  if (_callback == nullptr) {
    KRAKEN_LOG(VERBOSE) << "Callback is null";
    return;
  }

  Object callback = _callback->getObject(_context);
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
    KRAKEN_LOG(ERROR) << "Dart method 'invokeModule' not registered.";
    return Value::undefined();
  }

  CallbackContext *callbackContext = nullptr;

  if (count == 2) {
    std::shared_ptr<Value> callbackValue =
      std::make_shared<Value>(Value(context, args[1].getObject(context)));
    Object &&callbackFunction = callbackValue->getObject(context);
    callbackContext = new CallbackContext(context, callbackValue);
  }

  const char *result = getDartMethod()->invokeModule(messageStr.c_str(),
      handleTransientCallback, static_cast<void *>(callbackContext));

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
#ifdef KRAKEN_JSC_ENGINE
  context = alibaba::jsc::createJSContext();
#elif KRAKEN_V8_ENGINE
  alibaba::jsa_v8::initV8Engine("");
  context = alibaba::jsa_v8::createJSContext();
#endif

  // Inject JSC global objects
  kraken::binding::bindKraken(context);
  kraken::binding::bindConsole(context);
  kraken::binding::bindTimer(context);
  kraken::binding::bindBlob(context);

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
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_invoke_module__", 0,
                       invokeModule);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_module_listener__", 0,
                       krakenModuleListener);

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
    auto &&stack = error.getStack();
    auto &&message = error.getMessage();
    // TODO throw error in js context
    KRAKEN_LOG(ERROR) << message << "\n" << stack;
  }
}

alibaba::jsa::Value JSBridge::evaluateScript(const std::string &script, const std::string &url,
                              int startLine) {
  if (!context->isValid()) return Value::undefined();
  try {
    binding::updateLocation(url);
    return context->evaluateJavaScript(script.c_str(), url.c_str(), startLine);
  } catch (JSError error) {
    auto &&stack = error.getStack();
    auto &&message = error.getMessage();

    // TODO throw error in js context
    KRAKEN_LOG(ERROR) << message << "\n" << stack;
  }

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
  window_->invokeOnloadCallback(context);
}

void JSBridge::invokeOnPlatformBrightnessChangedCallback() {
  if (!context->isValid()) return;
  window_->invokeOnPlatformBrightnessChangedCallback(context);
}

void JSBridge::flushUITask() {
  if (!context->isValid()) return;
  kraken::foundation::flushUITask();
}

} // namespace kraken
