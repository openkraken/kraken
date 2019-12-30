/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "fetch.h"
#include "jsa.h"
#include "kraken_dart_export.h"
#include "logging.h"
#include "thread_safe_data.h"
#include "thread_safe_map.h"
#include <map>

namespace kraken {
namespace binding {

using namespace alibaba::jsa;

ThreadSafeMap<int, Value *> fetchMap;
ThreadSafeData<int> fetchId(0);

Value fetch(JSContext &context, const Value &thisVal, const Value *args,
            size_t count) {
  if (count != 3) {
    KRAKEN_LOG(WARN) << "__kraken_fetch__ should only have one parameter";
    return Value::undefined();
  }

  const Value &url = args[0];
  const Value &data = args[1];
  const Value &func = args[2];
  if (!func.getObject(context).isFunction(context)) {
    KRAKEN_LOG(WARN)
        << "__kraken_fetch__: first parameter should be an function";
    return Value::undefined();
  }

  if (!url.isString()) {
    KRAKEN_LOG(WARN) << "__kraken_fetch__: second parameter should be a string";
    return Value::undefined();
  }

  if (!data.isString()) {
    KRAKEN_LOG(WARN) << "__kraken_fetch__: third parameter  should be a string";
    return Value::undefined();
  }

  Value *funcValue = new Value(func.getObject(context));
  int id;
  fetchId.get(id);

  // store callback function
  fetchMap.set(id, funcValue);

  // call request
  KrakenInvokeFetch(id, url.getString(context).utf8(context).c_str(),
                    data.getString(context).utf8(context).c_str());

  fetchMap.set(id, funcValue);
  fetchId.set(id + 1);

  return Value::undefined();
}

void invokeFetchCallback(alibaba::jsa::JSContext *context, int callbackId,
                         const std::string &error, int statusCode,
                         const std::string &body) {
  Value *funcValue;
  fetchMap.get(callbackId, funcValue);

  if (funcValue == nullptr) {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
    return;
  }

  alibaba::jsa::Object funcObj = funcValue->asObject(*context);

  if (funcObj.isFunction(*context)) {
    Value jsError;
    if (!error.empty()) {
      jsError = alibaba::jsa::String::createFromUtf8(*context, error);
    } else {
      jsError = Value::undefined();
    }

    alibaba::jsa::Object &&response = alibaba::jsa::Object(*context);
    response.setProperty(*context, "statusCode", Value(statusCode));

    funcObj.asFunction(*context).call(
        *context, jsError, response,
        alibaba::jsa::String::createFromUtf8(*context, body));
  } else {
    KRAKEN_LOG(VERBOSE) << "callback is not a function";
  }
}

void bindFetch(alibaba::jsa::JSContext *context) {
  JSA_BINDING_FUNCTION(*context, context->global(), "__kraken__fetch__", 0,
                       fetch);
}

} // namespace binding
} // namespace kraken
