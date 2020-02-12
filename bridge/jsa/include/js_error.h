/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#ifndef JSA_JSEXCEPTION_H_
#define JSA_JSEXCEPTION_H_

#include <js_context.h>
#include <js_type.h>
#include <cassert>
#include <exception>
#include <stdexcept>
#include <string>

namespace alibaba {
namespace jsa {
/// Base class for jsa exceptions
class JSAException : public std::exception {
protected:
  JSAException(){};
  JSAException(std::string what) : what_(std::move(what)){};

public:
  virtual const char *what() const noexcept override { return what_.c_str(); }

protected:
  std::string what_;
};

/// This exception will be thrown by API functions on errors not related to
/// JavaScript execution.
class JSANativeException : public JSAException {
public:
  JSANativeException(std::string what) : JSAException(std::move(what)) {}
};

/// This exception will be thrown by API functions whenever a JS
/// operation causes an exception as described by the spec, or as
/// otherwise described.
class JSError : public JSAException {
public:
  /// Creates a JSError referring to provided \c value
  JSError(JSContext &r, Value &&value);

  /// Creates a JSError referring to new \c Error instance capturing current
  /// JavaScript stack. The error message property is set to given \c message.
  JSError(JSContext &rt, std::string message);

  /// Creates a JSError referring to new \c Error instance capturing current
  /// JavaScript stack. The error message property is set to given \c message.
  JSError(JSContext &rt, const char *message)
      : JSError(rt, std::string(message)){};

  /// Creates a JSError referring to a JavaScript Object having message and
  /// stack properties set to provided values.
  JSError(JSContext &rt, std::string message, std::string stack);

  /// Creates a JSError referring to provided value and what string
  /// set to provided message.  This argument order is a bit weird,
  /// but necessary to avoid ambiguity with the above.
  JSError(std::string what, JSContext &rt, Value &&value);

  const std::string &getStack() const { return stack_; }

  const std::string &getMessage() const { return message_; }

  const jsa::Value &value() const {
    assert(value_);
    return *value_;
  }

private:
  // This initializes the value_ member and does some other
  // validation, so it must be called by every branch through the
  // constructors.
  void setValue(JSContext &rt, Value &&value);

  // This needs to be on the heap, because throw requires the object
  // be copyable, and Value is not.
  std::shared_ptr<jsa::Value> value_;
  std::string message_;
  std::string stack_;
};
} // namespace jsa
} // namespace alibaba

#endif // JSA_JSEXCEPTION_H_
