/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include "js_error.h"
#include "js_type.h"

namespace alibaba {
namespace jsa {

namespace {
#ifdef KRAKEN_JSC_ENGINE
std::string reformatStack(std::string const &&stack) {
  std::string formatted;
  formatted.reserve(stack.length());

  formatted += "    at ";
  bool hasName = false;
  for (size_t i = 0; i < stack.length(); i ++) {
    if (stack[i] == '@') {
      formatted += " (";
      hasName = true;
    } else if (stack[i] == '[') {
      size_t nextBracket = stack.find(']', i);
      i += nextBracket - i;
    } else if (stack[i] == '\n') {
      if (hasName) {
        formatted += ')';
      }
      hasName = false;
      formatted += "\n    at ";
    } else {
      formatted += stack[i];
    }
  }
  return formatted;
}

#elif KRAKEN_V8_ENGINE
std::string reformatStack(std::string const &&stack) {
  return stack;
}
#endif
}

JSError::JSError(JSContext &context, Value &&value) { setValue(context, std::move(value)); }

JSError::JSError(JSContext &context, std::string msg) : message_(std::move(msg)) {
  try {
    setValue(context,
             context.global().getPropertyAsFunction(context, "Error").call(context, message_));
  } catch (...) {
    setValue(context, Value());
  }
}

JSError::JSError(JSContext &context, std::string msg, std::string stack)
    : message_(std::move(msg)), stack_(std::move(stack)) {
  try {
    Object e(context);
    e.setProperty(context, "message", String::createFromUtf8(context, message_));
    e.setProperty(context, "stack", String::createFromUtf8(context, stack_));
    e.setProperty(context, "name", String::createFromAscii(context, "NativeBridgeError"));
    setValue(context, std::move(e));
  } catch (...) {
    setValue(context, Value());
  }
}

JSError::JSError(std::string what, JSContext &context, Value &&value)
    : JSAException(std::move(what)) {
  setValue(context, std::move(value));
}

void JSError::setValue(JSContext &context, Value &&value) {
  value_ = std::make_shared<jsa::Value>(std::move(value));

  try {
    if ((message_.empty() || stack_.empty()) && value_->isObject()) {
      auto obj = value_->getObject(context);

      if (kind_.empty()) {
        jsa::Value kind = obj.getProperty(context, "name");
        if (!kind.isUndefined()) {
          kind_ = kind.toString(context).utf8(context);
        }
      }

      if (message_.empty()) {
        jsa::Value message = obj.getProperty(context, "message");
        if (!message.isUndefined()) {
          message_ = message.toString(context).utf8(context);
        }
      }

      if (stack_.empty()) {
        jsa::Value stack = obj.getProperty(context, "stack");
        if (!stack.isUndefined()) {
#ifdef KRAKEN_JSC_ENGINE
          stack_ = reformatStack(stack.toString(context).utf8(context));
#elif KRAKEN_V8_ENGINE
          stack_ = reformatStack(stack.toString(context).utf8(context));
#endif
        }
      }
    }

    if (message_.empty()) {
      message_ = value_->toString(context).utf8(context);
    }

    if (stack_.empty()) {
      stack_ = "no stack";
    }

    if (what_.empty()) {
      what_ = "\n" + kind_ + ": " + message_ + "\n" + stack_;
    }
  } catch (...) {
    message_ = "[Exception caught creating message string]";
    stack_ = "[Exception caught creating stack string]";
    what_ = "[Exception caught getting value fields]";
  }
}
} // namespace jsa
} // namespace alibaba
