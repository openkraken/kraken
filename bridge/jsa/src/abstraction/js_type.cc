/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <cassert>
#include "js_error.h"
#include "js_type.h"

namespace alibaba {
namespace jsa {
namespace {

// This is used for generating short exception strings.
std::string kindToString(const Value &v, JSContext *context = nullptr) {
  if (v.isUndefined()) {
    return "undefined";
  } else if (v.isNull()) {
    return "null";
  } else if (v.isBool()) {
    return v.getBool() ? "true" : "false";
  } else if (v.isNumber()) {
    return "a number";
  } else if (v.isString()) {
    return "a string";
  } else if (v.isSymbol()) {
    return "a symbol";
  } else {
    assert(v.isObject() && "Expecting object.");
    return context != nullptr && v.getObject(*context).isFunction(*context) ? "a function" : "an object";
  }
}

} // namespace

namespace detail {

void throwJSError(JSContext &context, const char *msg) {
  throw JSError(context, msg);
}
} // namespace detail

Pointer &Pointer::operator=(Pointer &&other) noexcept {
  if (ptr_) {
    ptr_->invalidate();
  }
  ptr_ = other.ptr_;
  other.ptr_ = nullptr;
  return *this;
}

Object Object::getPropertyAsObject(JSContext &context, const char *name) const {
  Value v = getProperty(context, name);

  if (!v.isObject()) {
    throw JSError(context, std::string("getPropertyAsObject: property '") + name + "' is " + kindToString(v, &context) +
                             ", expected an Object");
  }

  return v.getObject(context);
}

Function Object::getPropertyAsFunction(JSContext &context, const char *name) const {
  Object obj = getPropertyAsObject(context, name);
  if (!obj.isFunction(context)) {
    throw JSError(context, std::string("getPropertyAsFunction: property '") + name + "' is " +
                             kindToString(std::move(jsa::Value(context, obj)), &context) + ", expected a Function");
  }

  JSContext::PointerValue *value = obj.ptr_;
  obj.ptr_ = nullptr;
  return Function(value);
}

Array Object::asArray(JSContext &context) const & {
  if (!isArray(context)) {
    throw JSError(context, "Object is " + kindToString(Value(context, *this), &context) + ", expected an array");
  }
  return getArray(context);
}

Array Object::asArray(JSContext &context) && {
  if (!isArray(context)) {
    throw JSError(context, "Object is " + kindToString(Value(context, *this), &context) + ", expected an array");
  }
  return std::move(*this).getArray(context);
}

Function Object::asFunction(JSContext &context) const & {
  if (!isFunction(context)) {
    throw JSError(context, "Object is " + kindToString(Value(context, *this), &context) + ", expected a function");
  }
  return getFunction(context);
}

Function Object::asFunction(JSContext &context) && {
  if (!isFunction(context)) {
    throw JSError(context, "Object is " + kindToString(Value(context, *this), &context) + ", expected a function");
  }
  return std::move(*this).getFunction(context);
}

Value::Value(Value &&other) noexcept : Value(other.kind_) {
  if (kind_ == BooleanKind) {
    data_.boolean = other.data_.boolean;
  } else if (kind_ == NumberKind) {
    data_.number = other.data_.number;
  } else if (kind_ >= PointerKind) {
    new (&data_.pointer) Pointer(std::move(other.data_.pointer));
  }
  // when the other's dtor runs, nothing will happen.
  other.kind_ = UndefinedKind;
}

Value::Value(JSContext &context, const Value &other) : Value(other.kind_) {
  // data_ is uninitialized, so use placement new to create non-POD
  // types in it.  Any other kind of initialization will call a dtor
  // first, which is incorrect.
  if (kind_ == BooleanKind) {
    data_.boolean = other.data_.boolean;
  } else if (kind_ == NumberKind) {
    data_.number = other.data_.number;
  } else if (kind_ == SymbolKind) {
    // 在预分配内存中创建对象
    new (&data_.pointer) Pointer(context.cloneSymbol(other.data_.pointer.ptr_));
  } else if (kind_ == StringKind) {
    new (&data_.pointer) Pointer(context.cloneString(other.data_.pointer.ptr_));
  } else if (kind_ >= ObjectKind) {
    new (&data_.pointer) Pointer(context.cloneObject(other.data_.pointer.ptr_));
  }
}

Value::~Value() {
  if (kind_ >= PointerKind) {
    data_.pointer.~Pointer();
  }
}

Value Value::createFromJsonUtf8(JSContext &context, const uint8_t *json, size_t length) {
  Function parseJson = context.global().getPropertyAsObject(context, "JSON").getPropertyAsFunction(context, "parse");
  return parseJson.call(context, String::createFromUtf8(context, json, length));
}

bool Value::strictEquals(JSContext &context, const Value &a, const Value &b) {
  if (a.kind_ != b.kind_) {
    return false;
  }
  switch (a.kind_) {
  case UndefinedKind:
  case NullKind:
    return true;
  case BooleanKind:
    return a.data_.boolean == b.data_.boolean;
  case NumberKind:
    return a.data_.number == b.data_.number;
  case SymbolKind:
    return context.strictEquals(static_cast<const Symbol &>(a.data_.pointer),
                                static_cast<const Symbol &>(b.data_.pointer));
  case StringKind:
    return context.strictEquals(static_cast<const String &>(a.data_.pointer),
                                static_cast<const String &>(b.data_.pointer));
  case ObjectKind:
    return context.strictEquals(static_cast<const Object &>(a.data_.pointer),
                                static_cast<const Object &>(b.data_.pointer));
  }
  return false;
}

double Value::asNumber() const {
  if (!isNumber()) {
    throw JSANativeException("Value is " + kindToString(*this) + ", expected a number");
  }

  return getNumber();
}

Object Value::asObject(JSContext &context) const & {
  if (!isObject()) {
    throw JSError(context, "Value is " + kindToString(*this, &context) + ", expected an Object");
  }

  return getObject(context);
}

Object Value::asObject(JSContext &context) && {
  if (!isObject()) {
    throw JSError(context, "Value is " + kindToString(*this, &context) + ", expected an Object");
  }
  auto ptr = data_.pointer.ptr_;
  data_.pointer.ptr_ = nullptr;
  return static_cast<Object>(ptr);
}

Symbol Value::asSymbol(JSContext &context) const & {
  if (!isSymbol()) {
    throw JSError(context, "Value is " + kindToString(*this, &context) + ", expected a Symbol");
  }

  return getSymbol(context);
}

Symbol Value::asSymbol(JSContext &context) && {
  if (!isSymbol()) {
    throw JSError(context, "Value is " + kindToString(*this, &context) + ", expected a Symbol");
  }

  return std::move(*this).getSymbol(context);
}

String Value::asString(JSContext &context) const & {
  if (!isString()) {
    throw JSError(context, "Value is " + kindToString(*this, &context) + ", expected a String");
  }

  return getString(context);
}

String Value::asString(JSContext &context) && {
  if (!isString()) {
    throw JSError(context, "Value is " + kindToString(*this, &context) + ", expected a String");
  }

  return std::move(*this).getString(context);
}

String Value::toString(JSContext &context) const {
  Function toString = context.global().getPropertyAsFunction(context, "String");
  return toString.call(context, *this).getString(context);
}

std::string Value::toJSON(JSContext &context) const {
  Function stringify =
    context.global().getPropertyAsObject(context, "JSON").getPropertyAsFunction(context, "stringify");
  return stringify.call(context, *this).getString(context).utf8(context);
}

Array Array::createWithElements(JSContext &context, std::initializer_list<Value> elements) {
  Array result(context, elements.size());
  size_t index = 0;
  for (const auto &element : elements) {
    result.setValueAtIndex(context, index++, element);
  }
  return result;
}

} // namespace jsa
} // namespace alibaba
