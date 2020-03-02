/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include <js_error.h>

namespace alibaba {
namespace jsa {
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

      if (message_.empty()) {
        jsa::Value message = obj.getProperty(context, "message");
        if (!message.isUndefined()) {
          message_ = message.toString(context).utf8(context);
        }
      }

      if (stack_.empty()) {
        jsa::Value stack = obj.getProperty(context, "stack");
        if (!stack.isUndefined()) {
          stack_ = stack.toString(context).utf8(context);
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
      what_ = message_ + "\n\n" + stack_;
    }
  } catch (...) {
    message_ = "[Exception caught creating message string]";
    stack_ = "[Exception caught creating stack string]";
    what_ = "[Exception caught getting value fields]";
  }
}
} // namespace jsa
} // namespace alibaba
