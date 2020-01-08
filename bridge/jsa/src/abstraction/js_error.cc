/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include <js_error.h>

namespace alibaba {
namespace jsa {
JSError::JSError(JSContext &rt, Value &&value) { setValue(rt, std::move(value)); }

JSError::JSError(JSContext &rt, std::string msg) : message_(std::move(msg)) {
  try {
    setValue(rt,
             rt.global().getPropertyAsFunction(rt, "Error").call(rt, message_));
  } catch (...) {
    setValue(rt, Value());
  }
}

JSError::JSError(JSContext &rt, std::string msg, std::string stack)
    : message_(std::move(msg)), stack_(std::move(stack)) {
  try {
    Object e(rt);
    e.setProperty(rt, "message", String::createFromUtf8(rt, message_));
    e.setProperty(rt, "stack", String::createFromUtf8(rt, stack_));
    setValue(rt, std::move(e));
  } catch (...) {
    setValue(rt, Value());
  }
}

JSError::JSError(std::string what, JSContext &rt, Value &&value)
    : JSAException(std::move(what)) {
  setValue(rt, std::move(value));
}

void JSError::setValue(JSContext &rt, Value &&value) {
  value_ = std::make_shared<jsa::Value>(std::move(value));

  try {
    if ((message_.empty() || stack_.empty()) && value_->isObject()) {
      auto obj = value_->getObject(rt);

      if (message_.empty()) {
        jsa::Value message = obj.getProperty(rt, "message");
        if (!message.isUndefined()) {
          message_ = message.toString(rt).utf8(rt);
        }
      }

      if (stack_.empty()) {
        jsa::Value stack = obj.getProperty(rt, "stack");
        if (!stack.isUndefined()) {
          stack_ = stack.toString(rt).utf8(rt);
        }
      }
    }

    if (message_.empty()) {
      message_ = value_->toString(rt).utf8(rt);
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
