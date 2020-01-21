/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "jsa.h"
#include "kraken_dart_export.h"
#include "logging.h"
#include <cstdlib>

const char *CREATE_ELEMENT_JS_API = "__kraken__createElement__";
const char *CREATE_TEXT_NODE_JS_API = "__kraken__createTextNode__";
const char *SET_STYLE_JS_API = "__kraken__setStyle__";
const char *REMOVE_NODE_JS_API = "__kraken__removeNode__";
const char *INSERT_ADJACENT_NODE_JS_API = "__kraken__insertAdjacentNode__";
const char *SET_PROPERTY_JS_API = "__kraken__setProperty__";
const char *REMOVE_PROPERTY_JS_API = "__kraken__removeProperty__";
const char *METHOD_JS_API = "__kraken__method__";

namespace kraken {
namespace binding {

Value createElement(JSContext &context, const Value &thisVal, const Value *args,
                    size_t count) {
  if (count != 4) {
    KRAKEN_LOG(WARN) << CREATE_ELEMENT_JS_API << " needs 4 params" << std::endl;
    return Value::undefined();
  }

  const Value &type = args[0];
  const Value &id = args[1];
  const Value &props = args[2];
  const Value &events = args[3];

  if (!type.isString()) {
    KRAKEN_LOG(WARN) << CREATE_ELEMENT_JS_API
                     << " first params's type should be string" << std::endl;
    return Value::undefined();
  }

  if (!id.isNumber()) {
    KRAKEN_LOG(WARN) << CREATE_ELEMENT_JS_API
                     << " second params's type should be number" << std::endl;
    return Value::undefined();
  }

  if (!props.isString()) {
    KRAKEN_LOG(WARN) << CREATE_ELEMENT_JS_API
                     << " third params's type should be string" << std::endl;
    return Value::undefined();
  }

  if (!props.isString()) {
    KRAKEN_LOG(WARN) << CREATE_ELEMENT_JS_API
                     << " forth params's type should be string" << std::endl;
    return Value::undefined();
  }

  std::string &&c_type = type.getString(context).utf8(context);
  std::string &&c_props = props.getString(context).utf8(context);
  std::string &&c_events = events.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[createElement]: "
                        << R"([{"type":")" << c_type
                        << R"(","id":)" << id.getNumber() << R"(,"props":)"
                        << c_props << R"(,"events":)" << c_events << "}]"
                        << std::endl;
  }

#ifdef IS_TEST
  // TODO unit tests
#else
  KrakenCreateElement(c_type.c_str(), (int)id.getNumber(), c_props.c_str(),
                      c_events.c_str());
#endif
  return Value::undefined();
}

Value createTextNode(JSContext &context, const Value &thisVal,
                     const Value *args, size_t count) {
  if (count != 4) {
    KRAKEN_LOG(WARN) << CREATE_TEXT_NODE_JS_API << " needs 4 params"
                     << std::endl;
    return Value::undefined();
  }

  const Value &type = args[0];
  const Value &id = args[1];
  const Value &props = args[2];
  const Value &events = args[3];

  if (!type.isString()) {
    KRAKEN_LOG(WARN) << CREATE_TEXT_NODE_JS_API
                     << " first params's type should be string" << std::endl;
    return Value::undefined();
  }

  if (!id.isNumber()) {
    KRAKEN_LOG(WARN) << CREATE_TEXT_NODE_JS_API
                     << " second params's type should be number" << std::endl;
    return Value::undefined();
  }

  if (!props.isString()) {
    KRAKEN_LOG(WARN) << CREATE_TEXT_NODE_JS_API
                     << " third params's type should be string" << std::endl;
    return Value::undefined();
  }

  if (!props.isString()) {
    KRAKEN_LOG(WARN) << CREATE_TEXT_NODE_JS_API
                     << " forth params's type should be string" << std::endl;
    return Value::undefined();
  }

  std::string &&c_type = type.getString(context).utf8(context);
  std::string &&c_props = props.getString(context).utf8(context);
  std::string &&c_events = events.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[createTextNode]: "
                        << R"([{"type":")" << c_type
                        << R"(","id":)" << id.getNumber() << R"(,"props":)"
                        << c_props << R"(,"events":)" << c_events << "}]"
                        << std::endl;
  }

#ifdef IS_TEST
#else
  KrakenCreateTextNode(c_type.c_str(), (int)id.getNumber(), c_props.c_str(),
                       c_events.c_str());
#endif

  return Value::undefined();
}

Value setStyle(JSContext &context, const Value &thisVal, const Value *args,
               size_t count) {
  if (count != 3) {
    KRAKEN_LOG(WARN) << SET_STYLE_JS_API << " needs 3 params" << std::endl;
    return Value::undefined();
  }

  const Value &targetId = args[0];
  const Value &key = args[1];
  const Value &value = args[2];

  if (!targetId.isNumber()) {
    KRAKEN_LOG(WARN) << SET_STYLE_JS_API
                     << " first params's type should be number" << std::endl;
    return Value::undefined();
  }

  if (!key.isString()) {
    KRAKEN_LOG(WARN) << SET_STYLE_JS_API
                     << " second params's type should be string" << std::endl;
    return Value::undefined();
  }

  if (!value.isString()) {
    KRAKEN_LOG(WARN) << SET_STYLE_JS_API
                     << " third params's type should be string" << std::endl;
    return Value::undefined();
  }

  std::string &&c_key = key.getString(context).utf8(context);
  std::string &&c_value = value.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[setStyle]: "
                        << "[" << (int)targetId.getNumber()
                        << "," << "\"" << c_key << "\",\"" << c_value
                        << "\"]" << std::endl;
  }

#ifdef IS_TEST
#else
  KrakenSetStyle((int)targetId.getNumber(),
                 key.getString(context).utf8(context).c_str(),
                 value.getString(context).utf8(context).c_str());
#endif

  return Value::undefined();
}

Value removeNode(JSContext &context, const Value &thisVal, const Value *args,
                 size_t count) {
  if (count != 1) {
    KRAKEN_LOG(WARN) << REMOVE_NODE_JS_API << " needs 1 params" << std::endl;
    return Value::undefined();
  }

  const Value &targetId = args[0];

  if (!targetId.isNumber()) {
    KRAKEN_LOG(WARN) << REMOVE_NODE_JS_API
                     << " first param's type should be number" << std::endl;
    return Value::undefined();
  }

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[removeNode]: "
                        << "[" << (int)targetId.getNumber()
                        << "]" << std::endl;
  }

#ifdef IS_TEST
#else
  KrakenRemoveNode((int)targetId.getNumber());
#endif
  return Value::undefined();
}

Value insertAdjacentNode(JSContext &context, const Value &thisVal,
                         const Value *args, size_t count) {
  if (count != 3) {
    KRAKEN_LOG(WARN) << INSERT_ADJACENT_NODE_JS_API << " needs 3 params"
                     << std::endl;
    return Value::undefined();
  }

  const Value &targetId = args[0];
  const Value &position = args[1];
  const Value &nodeId = args[2];

  if (!targetId.isNumber()) {
    KRAKEN_LOG(WARN) << INSERT_ADJACENT_NODE_JS_API
                     << " first params's type should be number" << std::endl;
    return Value::undefined();
  }

  if (!position.isString()) {
    KRAKEN_LOG(WARN) << INSERT_ADJACENT_NODE_JS_API
                     << " second param's type should be string" << std::endl;
    return Value::undefined();
  }

  if (!nodeId.isNumber()) {
    KRAKEN_LOG(WARN) << INSERT_ADJACENT_NODE_JS_API
                     << " third params's type should be number" << std::endl;
    return Value::undefined();
  }

  std::string &&c_position = position.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[insertAdjacentNode]: "
                        << "["
                        << (int)targetId.getNumber() << ",\"" << c_position
                        << "\"," << (int)nodeId.getNumber() << "]"
                        << std::endl;
  }

#ifdef IS_TEST
#else
  KrakenInsertAdjacentNode((int)targetId.getNumber(), c_position.c_str(),
                           (int)nodeId.getNumber());
#endif
  return Value::undefined();
}

Value setProperty(JSContext &context, const Value &thisVal, const Value *args,
                  size_t count) {
  if (count != 3) {
    KRAKEN_LOG(WARN) << SET_PROPERTY_JS_API << " needs 3 params" << std::endl;
    return Value::undefined();
  }

  const Value &targetId = args[0];
  const Value &key = args[1];
  const Value &value = args[2];

  if (!targetId.isNumber()) {
    KRAKEN_LOG(WARN) << SET_PROPERTY_JS_API
                     << " first params's type should be number" << std::endl;
    return Value::undefined();
  }

  if (!key.isString()) {
    KRAKEN_LOG(WARN) << SET_PROPERTY_JS_API
                     << " second param's type should be string" << std::endl;
    return Value::undefined();
  }

  if (!value.isString()) {
    KRAKEN_LOG(WARN) << SET_PROPERTY_JS_API
                     << " third params's type should be string" << std::endl;
    return Value::undefined();
  }

  std::string &&c_key = key.getString(context).utf8(context);
  std::string &&c_value = value.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[setProperty]: "
                        << "[" << (int)targetId.getNumber()
                        << ",\"" << c_key << "\",\"" << c_value << "\"]"
                        << std::endl;
  }

#ifdef IS_TEST
#else
  KrakenSetProperty((int)targetId.asNumber(), c_key.c_str(), c_value.c_str());
#endif

  return Value::undefined();
}

Value removeProperty(JSContext &context, const Value &thisVal,
                     const Value *args, size_t count) {
  if (count != 2) {
    KRAKEN_LOG(WARN) << REMOVE_PROPERTY_JS_API << " needs 2 params"
                     << std::endl;
    return Value::undefined();
  }

  const Value &targetId = args[0];
  const Value &key = args[1];

  if (!targetId.isNumber()) {
    KRAKEN_LOG(WARN) << REMOVE_PROPERTY_JS_API
                     << " first params's type should be number" << std::endl;
    return Value::undefined();
  }

  if (!key.isString()) {
    KRAKEN_LOG(WARN) << REMOVE_PROPERTY_JS_API
                     << " second param's type should be string" << std::endl;
    return Value::undefined();
  }

  std::string &&c_key = key.getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[removeProperty]: "
                        << "[" << (int)targetId.getNumber()
                        << ",\"" << c_key << "\"]" << std::endl;
  }
#ifdef IS_TEST
#else
  KrakenRemoveProperty((int)targetId.getNumber(), c_key.c_str());
#endif

  return Value::undefined();
}

Value method(JSContext &context, const Value &thisVal, const Value *args,
             size_t count) {
  if (count != 2) {
    KRAKEN_LOG(WARN) << METHOD_JS_API << " needs 3 params" << std::endl;
    return Value::undefined();
  }

  const Value &targetId = args[0];
  const Value &method = args[1];
  const Value &jsArgs = args[2];

  if (!targetId.isNumber()) {
    KRAKEN_LOG(WARN) << METHOD_JS_API << " first params's type should be number"
                     << std::endl;
    return Value::undefined();
  }

  if (!method.isString()) {
    KRAKEN_LOG(WARN) << METHOD_JS_API << " second param's type should be string"
                     << std::endl;
    return Value::undefined();
  }

  if (!jsArgs.isString()) {
    KRAKEN_LOG(WARN) << METHOD_JS_API << " third param's type should be string"
                     << std::endl;
    return Value::undefined();
  }

  std::string &&c_method = method.getString(context).utf8(context);
  std::string &&c_args = args->getString(context).utf8(context);

  if (std::getenv("ENABLE_KRAKEN_JS_LOG") != nullptr &&
      strcmp(std::getenv("ENABLE_KRAKEN_JS_LOG"), "true") == 0) {
    KRAKEN_LOG(VERBOSE) << "[method]: "
                        << "[" << (int)targetId.getNumber()
                        << ",\"" << c_method << "\"," << c_args << "]"
                        << std::endl;
  }

#ifdef IS_TEST
#else
  KrakenMethod((int)targetId.getNumber(),
               c_method.c_str(),
               c_args.c_str());
#endif
  return Value::undefined();
}

void bindElement(alibaba::jsa::JSContext *context) {
  JSA_BINDING_FUNCTION(*context, context->global(), CREATE_ELEMENT_JS_API, 4,
                       createElement);
  JSA_BINDING_FUNCTION(*context, context->global(), CREATE_TEXT_NODE_JS_API, 4,
                       createTextNode);
  JSA_BINDING_FUNCTION(*context, context->global(), SET_STYLE_JS_API, 3,
                       setStyle);
  JSA_BINDING_FUNCTION(*context, context->global(), REMOVE_NODE_JS_API, 1,
                       removeNode);
  JSA_BINDING_FUNCTION(*context, context->global(), INSERT_ADJACENT_NODE_JS_API,
                       3, insertAdjacentNode);
  JSA_BINDING_FUNCTION(*context, context->global(), SET_PROPERTY_JS_API, 3,
                       setProperty);
  JSA_BINDING_FUNCTION(*context, context->global(), REMOVE_PROPERTY_JS_API, 2,
                       removeProperty);
  JSA_BINDING_FUNCTION(*context, context->global(), METHOD_JS_API, 3, method);
}

} // namespace binding
} // namespace kraken
