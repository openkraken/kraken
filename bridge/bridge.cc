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
#include "foundation/flushUITask.h"
#include "dart_callbacks.h"
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

const char JS = 'J';
const char DART = 'D';

const char FRAME_BEGIN = '$';

ThreadSafeArray<std::shared_ptr<Value>> dartJsCallbackList;

/**
 * Message channel, send message from JS to Dart.
 * @param context
 * @param thisVal
 * @param args
 * @param count
 * @return JSValue
 */
Value krakenJsToDart(JSContext &context, const Value &thisVal,
                     const Value *args, size_t count) {
  if (count < 1) {
    KRAKEN_LOG(WARN) << "[KrakenJSToDart ERROR]: function missing parameter";
    return Value::undefined();
  }

  auto &&message = args[0];
  const std::string messageStr = message.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[KrakenJSToDart]: " << messageStr << std::endl;
  }

  if (getDartFunc()->invokeDartFromJS == nullptr) {
    KRAKEN_LOG(ERROR) << "[KrakenJSToDart ERROR]: dart callbacks not register";
    return Value::undefined();
  }

  const char *result = getDartFunc()->invokeDartFromJS(messageStr.c_str());
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
Value krakenDartToJs(JSContext &context, const Value &thisVal,
                     const Value *args, size_t count) {
  if (count < 1) {
    KRAKEN_LOG(WARN) << "[KrakenDartToJS ERROR]: function missing parameter";
    return Value::undefined();
  }

  std::shared_ptr<Value> val =
      std::make_shared<Value>(Value(context, args[0].getObject(context)));
  Object &&func = val->getObject(context);

  if (!func.isFunction(context)) {
    KRAKEN_LOG(WARN)
        << "[KrakenDartToJS ERROR]: parameter should be a function";
    return Value::undefined();
  }

  dartJsCallbackList.push(val);

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
  return JSA_GLOBAL_GET_PROPERTY(context,
                                 name.getString(context).utf8(context).c_str());
}
#endif

} // namespace

/**
 * JSRuntime
 */
JSBridge::JSBridge() {
  if (std::getenv("KRAKEN_JS_ENGINE") != nullptr &&
      strcmp(std::getenv("KRAKEN_JS_ENGINE"), "v8") == 0) {
    context = alibaba::jsa_v8::createJSContext();
  } else {
    context = alibaba::jsc::createJSContext();
  }

  contextInvalid = false;

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

  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_js_to_dart__", 0,
                       krakenJsToDart);
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken_dart_to_js__", 0,
                       krakenDartToJs);
}

#ifdef ENABLE_DEBUGGER
void JSBridge::attachDevtools() {
  assert(context_ != nullptr);
  KRAKEN_LOG(VERBOSE) << "kraken will attach Devtools...";
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
  KRAKEN_LOG(VERBOSE) << "kraken will detach Devtools...";
  devtools_front_door_->terminate();
}
#endif // ENABLE_DEBUGGER

void JSBridge::invokeKrakenCallback(const char *args) {
  assert(context != nullptr);

  int length = dartJsCallbackList.length();

  for (int i = 0; i < length; i++) {
    std::shared_ptr<Value> callback;
    dartJsCallbackList.get(i, callback);

    if (callback == nullptr) {
      KRAKEN_LOG(WARN) << "[KrakenDartToJS ERROR]: you should initialize with "
                          "__kraken_dart_to_js__ function";
      return;
    }

    if (!callback->getObject(*context).isFunction(*context)) {
      KRAKEN_LOG(WARN) << "[KrakenDartToJS ERROR]: callback is not a function";
      return;
    }

    const String str = String::createFromAscii(*context, args);
    callback->getObject(*context).asFunction(*context).callWithThis(
        *context, context->global(), str, 1);
  }
}

void JSBridge::handleFlutterCallback(const char *args) {
  if (contextInvalid) {
    return;
  }

  std::string &&str = static_cast<std::string>(args);
  char from = str[0];
  char to = str[1];

  // not from dart, who are you ??
  if (from != DART) {
    KRAKEN_LOG(WARN) << "unexpected recevied message: " << args;
    return;
  }

  try {
    char kind = str[2];
    if (kind != FRAME_BEGIN && std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
        strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
      KRAKEN_LOG(VERBOSE) << "[KrakenDartToJS] called, message: " << args;
    }
    // do not handle message which did'n response to cpp layer
    if (to == JS) {
      this->invokeKrakenCallback(args);
      return;
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
  contextInvalid = true;
  dartJsCallbackList.clear();
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
