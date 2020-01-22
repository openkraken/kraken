/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bridge.h"
#include "jsa.h"
#include "kraken_dart_export.h"

#include "bindings/KOM/console.h"
#include "bindings/KOM/fetch.h"
#include "bindings/KOM/screen.h"
#include "bindings/KOM/timer.h"
#include "bindings/KOM/window.h"
#include "bindings/KOM/location.h"
#include "bindings/DOM/element.h"
#include "logging.h"
#include "message.h"
#include "thread_safe_array.h"
#include <atomic>
#include <cassert>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>

namespace kraken {
namespace {

using namespace alibaba::jsa;

const char CPP = 'C';
const char JS = 'J';
const char DART = 'D';

const char FRAME_BEGIN = '$';
const char FETCH_MESSAGE = 's';
const char TIMEOUT_MESSAGE = 't';
const char INTERVAL_MESSAGE = 'i';
const char ANIMATION_FRAME_MESSAGE = 'a';
const char SCREEN_METRICS = 'm';
const char WINDOW_LOAD = 'l';
const char WINDOW_INIT_DEVICE_PIXEL_RATIO = 'r';

ThreadSafeArray<std::shared_ptr<Value>> dartJsCallbackList;

/**
 * Message channel, send message from JS to Dart.
 * @param context
 * @param thisVal
 * @param args
 * @param count
 * @return JSValue
 */
Value krakenJsToDart(JSContext &context,
                                   const Value &thisVal,
                                   const Value *args,
                                   size_t count) {
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

  const char *result =
      KrakenInvokeDartFromCpp("krakenJsToDart", messageStr.c_str());

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
Value krakenDartToJs(JSContext &context,
                                   const Value &thisVal,
                                   const Value *args,
                                   size_t count) {
  if (count < 1) {
    KRAKEN_LOG(WARN) << "[KrakenDartToJS ERROR]: function missing parameter";
    return Value::undefined();
  }

  std::shared_ptr<Value> val = std::make_shared<Value>(Value(context, args[0].getObject(context)));
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
Value getValue(JSContext &context,
                             const Value &thisVal,
                             const Value *args,
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
  context_ = alibaba::jsc::createJSContext();
  contextInvalid = false;

  // Inject JSC global objects
  kraken::binding::bindKraken(context_.get());
  kraken::binding::bindConsole(context_.get());
  kraken::binding::bindTimer(context_.get());
  kraken::binding::bindFetch(context_.get());
  kraken::binding::bindScreen(context_.get());
  kraken::binding::bindElement(context_.get());

  websocket_ = std::make_shared<kraken::binding::JSWebSocket>();
  websocket_->bind(context_.get());
  window_ = std::make_shared<kraken::binding::JSWindow>();
  window_->bind(context_.get());

  JSA_BINDING_FUNCTION(*context_, context_->global(), "__kraken_js_to_dart__",
                       0, krakenJsToDart);
  JSA_BINDING_FUNCTION(*context_, context_->global(), "__kraken_dart_to_js__",
                       0, krakenDartToJs);
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

void JSBridge::detatchDevtools() {
  assert(devtools_front_door_ != nullptr);
  KRAKEN_LOG(VERBOSE) << "kraken will detatch Devtools...";
  devtools_front_door_->terminate();
}
#endif // ENABLE_DEBUGGER

void JSBridge::invokeKrakenCallback(const char *args) {
  assert(context_ != nullptr);

  int length = dartJsCallbackList.length();

  for (int i = 0; i < length; i++) {
    std::shared_ptr<Value> callback;
    dartJsCallbackList.get(i, callback);

    if (callback == nullptr) {
      KRAKEN_LOG(WARN) << "[KrakenDartToJS ERROR]: you should initialize with "
                          "__kraken_dart_to_js__ function";
      return;
    }

    if (!callback->getObject(*context_).isFunction(*context_)) {
      KRAKEN_LOG(WARN) << "[KrakenDartToJS ERROR]: callback is not a function";
      return;
    }

    const String str =
        String::createFromAscii(*context_, args);
    callback->getObject(*context_).asFunction(*context_).callWithThis(
        *context_, context_->global(), str, 1);
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
    if (
      kind != FRAME_BEGIN &&
      std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0
    ) {
      KRAKEN_LOG(VERBOSE) << "[KrakenDartToJS] called, message: " << args;
    }
    // do not handle message which did'n response to cpp layer
    if (to == JS) {
      this->invokeKrakenCallback(args);
      return;
    }

    switch (kind) {
    case TIMEOUT_MESSAGE:
      kraken::binding::invokeSetTimeoutCallback(context_.get(),
                                                std::stoi(str.substr(3)));
      break;
    case INTERVAL_MESSAGE:
      kraken::binding::invokeSetIntervalCallback(context_.get(),
                                                 std::stoi(str.substr(3)));
      break;
    case ANIMATION_FRAME_MESSAGE:
      kraken::binding::invokeRequestAnimationFrameCallback(
          context_.get(), std::stoi(str.substr(3)));
      break;
    case FETCH_MESSAGE: {
      // extract id from DCf[id][message]
      // D == Dart
      // C == Cpp
      // F == FetchMessage
      std::string callbackId;
      size_t lastStart = message::Message::getBracketsValue(str, callbackId);
      kraken::message::Message message;
      message.parseMessageBody(str.substr(lastStart + 1));

      std::string error;
      std::string statusCode;
      std::string body;

      message.readMessage("error", error);
      message.readMessage("statusCode", statusCode);
      message.readMessage("body", body);

      kraken::binding::invokeFetchCallback(context_.get(),
                                           std::stoi(callbackId), error,
                                           std::stoi(statusCode), body);
      break;
    }
    case SCREEN_METRICS: {
      kraken::message::Message message;
      message.parseMessageBody(str.substr(3));

      std::string width;
      std::string height;
      std::string availWidth;
      std::string availHeight;

      message.readMessage("width", width);
      message.readMessage("height", height);
      message.readMessage("availWidth", availWidth);
      message.readMessage("availHeight", availHeight);

      kraken::binding::invokeUpdateScreen(
          context_.get(), std::stoi(width), std::stoi(height),
          std::stoi(availWidth), std::stoi(availHeight));
      break;
    }
    case WINDOW_LOAD:
      window_->invokeOnloadCallback(context_.get());
      break;
    case WINDOW_INIT_DEVICE_PIXEL_RATIO:
      window_->initDevicePixelRatio(context_.get(), std::stoi(str.substr(3)));
      break;
    default:
      break;
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
  assert(context_ != nullptr);
  try {
    binding::updateLocation(url);
    context_->evaluateJavaScript(script.c_str(), url.c_str(), startLine);
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
  window_->unbind(context_.get());
  binding::unbindTimer();
  binding::unbindFetch();
  contextInvalid = true;
  dartJsCallbackList.clear();
  context_.reset();
}

Value JSBridge::getGlobalValue(std::string code) {
  return context_->evaluateJavaScript(code.c_str(), "test://", 0);
}

} // namespace kraken
