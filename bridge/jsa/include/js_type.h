/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef JSA_JSTYPE_H_
#define JSA_JSTYPE_H_

#include "js_context.h"
#include <cassert>
#include <cstring>
#include <string>
#include <vector>

namespace alibaba {
namespace jsa {
// Base class for pointer-storing types.
class Pointer {
protected:
  explicit Pointer(Pointer &&other) : ptr_(other.ptr_) { other.ptr_ = nullptr; }

  ~Pointer() {
    if (ptr_) {
      ptr_->invalidate();
    }
  }

  Pointer &operator=(Pointer &&other);

  friend class JSContext;
  friend class Value;

  explicit Pointer(JSContext::PointerValue *ptr) : ptr_(ptr) {}

  // 这里需要持有真正js engine提供的对应对象(如function/string)等
  typename JSContext::PointerValue *ptr_;
};

/// Represents something that can be a JS property key.  Movable, not copyable.
class PropNameID : public Pointer {
public:
  using Pointer::Pointer;

  PropNameID(JSContext &runtime, const PropNameID &other)
      : PropNameID(runtime.clonePropNameID(other.ptr_)) {}

  PropNameID(PropNameID &&other) = default;
  PropNameID &operator=(PropNameID &&other) = default;

  /// Create a JS property name id from ascii values.  The data is
  /// copied.
  static PropNameID forAscii(JSContext &runtime, const char *str,
                             size_t length) {
    return runtime.createPropNameIDFromAscii(str, length);
  }

  /// Create a property name id from a nul-terminated C ascii name.  The data is
  /// copied.
  static PropNameID forAscii(JSContext &runtime, const char *str) {
    return forAscii(runtime, str, strlen(str));
  }

  /// Create a PropNameID from a C++ string. The string is copied.
  static PropNameID forAscii(JSContext &runtime, const std::string &str) {
    return forAscii(runtime, str.c_str(), str.size());
  }

  /// Create a PropNameID from utf8 values.  The data is copied.
  static PropNameID forUtf8(JSContext &runtime, const uint8_t *utf8,
                            size_t length) {
    return runtime.createPropNameIDFromUtf8(utf8, length);
  }

  /// Create a PropNameID from utf8-encoded octets stored in a
  /// std::string.  The string data is transformed and copied.
  static PropNameID forUtf8(JSContext &runtime, const std::string &utf8) {
    return runtime.createPropNameIDFromUtf8(
        reinterpret_cast<const uint8_t *>(utf8.data()), utf8.size());
  }

  /// Create a PropNameID from a JS string.
  static PropNameID forString(JSContext &runtime, const jsa::String &str) {
    return runtime.createPropNameIDFromString(str);
  }

  // Creates a vector of PropNameIDs constructed from given arguments.
  template <typename... Args>
  static std::vector<PropNameID> names(JSContext &runtime, Args &&... args);

  // Creates a vector of given PropNameIDs.
  template <size_t N>
  static std::vector<PropNameID> names(PropNameID(&&propertyNames)[N]);

  /// Copies the data in a PropNameID as utf8 into a C++ string.
  std::string utf8(JSContext &runtime) const { return runtime.utf8(*this); }

  static bool compare(JSContext &runtime, const jsa::PropNameID &a,
                      const jsa::PropNameID &b) {
    return runtime.compare(a, b);
  }

  friend class JSContext;
  friend class Value;
};

/// Represents a JS Symbol (es6).  Movable, not copyable.
/// TODO T40778724: this is a limited implementation sufficient for
/// the debugger not to crash when a Symbol is a property in an Object
/// or element in an array.  Complete support for creating will come
/// later.
class Symbol : public Pointer {
public:
  using Pointer::Pointer;

  Symbol(Symbol &&other) = default;
  Symbol &operator=(Symbol &&other) = default;

  /// \return whether a and b refer to the same symbol.
  static bool strictEquals(JSContext &runtime, const Symbol &a,
                           const Symbol &b) {
    return runtime.strictEquals(a, b);
  }

  /// Converts a Symbol into a C++ string as JS .toString would.  The output
  /// will look like \c Symbol(description) .
  std::string toString(JSContext &runtime) const {
    return runtime.symbolToString(*this);
  }

  friend class JSContext;
  friend class Value;
};

/// Represents a JS String.  Movable, not copyable.
class String : public Pointer {
public:
  using Pointer::Pointer;

  String(String &&other) = default;
  String &operator=(String &&other) = default;

  /// Create a JS string from ascii values.  The string data is
  /// copied.
  static String createFromAscii(JSContext &runtime, const char *str,
                                size_t length) {
    // 真正实现由runtime实现类提供
    return runtime.createStringFromAscii(str, length);
  }

  /// Create a JS string from a nul-terminated C ascii string.  The
  /// string data is copied.
  static String createFromAscii(JSContext &runtime, const char *str) {
    return createFromAscii(runtime, str, strlen(str));
  }

  /// Create a JS string from a C++ string.  The string data is
  /// copied.
  static String createFromAscii(JSContext &runtime, const std::string &str) {
    return createFromAscii(runtime, str.c_str(), str.size());
  }

  /// Create a JS string from utf8-encoded octets.  The string data is
  /// transformed and copied.
  static String createFromUtf8(JSContext &runtime, const uint8_t *utf8,
                               size_t length) {
    return runtime.createStringFromUtf8(utf8, length);
  }

  /// Create a JS string from utf8-encoded octets stored in a
  /// std::string.  The string data is transformed and copied.
  static String createFromUtf8(JSContext &runtime, const std::string &utf8) {
    return runtime.createStringFromUtf8(
        reinterpret_cast<const uint8_t *>(utf8.data()), utf8.length());
  }

  /// \return whether a and b contain the same characters.
  static bool strictEquals(JSContext &runtime, const String &a,
                           const String &b) {
    return runtime.strictEquals(a, b);
  }

  /// Copies the data in a JS string as utf8 into a C++ string.
  std::string utf8(JSContext &runtime) const { return runtime.utf8(*this); }

  friend class JSContext;
  friend class Value;
};

class Array;
class Function;

/// Represents a JS Object.  Movable, not copyable.
class Object : public Pointer {
public:
  using Pointer::Pointer;

  Object(Object &&other) = default;
  Object &operator=(Object &&other) = default;

  /// Creates a new Object instance, like '{}' in JS.
  Object(JSContext &runtime) : Object(runtime.createObject()) {}

  static Object createFromHostObject(JSContext &runtime,
                                     std::shared_ptr<HostObject> ho) {
    return runtime.createObject(ho);
  }

  /// \return whether this and \c obj are the same JSObject or not.
  static bool strictEquals(JSContext &runtime, const Object &a,
                           const Object &b) {
    return runtime.strictEquals(a, b);
  }

  /// \return the result of `this instanceOf ctor` in JS.
  bool instanceOf(JSContext &context, const Function &ctor) {
    return context.instanceOf(*this, ctor);
  }

  /// \return the property of the object with the given ascii name.
  /// If the name isn't a property on the object, returns the
  /// undefined value.
  Value getProperty(JSContext &runtime, const char *name) const;

  /// \return the property of the object with the String name.
  /// If the name isn't a property on the object, returns the
  /// undefined value.
  Value getProperty(JSContext &runtime, const String &name) const;

  /// \return the property of the object with the given JS PropNameID
  /// name.  If the name isn't a property on the object, returns the
  /// undefined value.
  Value getProperty(JSContext &runtime, const PropNameID &name) const;

  /// \return true if and only if the object has a property with the
  /// given ascii name.
  bool hasProperty(JSContext &runtime, const char *name) const;

  /// \return true if and only if the object has a property with the
  /// given String name.
  bool hasProperty(JSContext &runtime, const String &name) const;

  /// \return true if and only if the object has a property with the
  /// given PropNameID name.
  bool hasProperty(JSContext &runtime, const PropNameID &name) const;

  /// Sets the property value from a Value or anything which can be
  /// used to make one: nullptr_t, bool, double, int, const char*,
  /// String, or Object.
  template <typename T>
  void setProperty(JSContext &runtime, const char *name, T &&value);

  /// Sets the property value from a Value or anything which can be
  /// used to make one: nullptr_t, bool, double, int, const char*,
  /// String, or Object.
  template <typename T>
  void setProperty(JSContext &runtime, const String &name, T &&value);

  /// Sets the property value from a Value or anything which can be
  /// used to make one: nullptr_t, bool, double, int, const char*,
  /// String, or Object.
  template <typename T>
  void setProperty(JSContext &runtime, const PropNameID &name, T &&value);

  /// \return true iff JS \c Array.isArray() would return \c true.  If
  /// so, then \c getArray() will succeed.
  bool isArray(JSContext &runtime) const { return runtime.isArray(*this); }

  /// \return true iff the Object is an ArrayBuffer. If so, then \c
  /// getArrayBuffer() will succeed.
  bool isArrayBuffer(JSContext &runtime) const {
    return runtime.isArrayBuffer(*this);
  }

  bool isArrayBufferView(JSContext &context) const {
    return context.isArrayBufferView(*this);
  }

  /// \return true iff the Object is callable.  If so, then \c
  /// getFunction will succeed.
  bool isFunction(JSContext &runtime) const {
    return runtime.isFunction(*this);
  }

  /// \return true iff the Object was initialized with \c createFromHostObject
  /// and the HostObject passed is of type \c T. If returns \c true then
  /// \c getHostObject<T> will succeed.
  template <typename T = HostObject>
  bool isHostObject(JSContext &runtime) const;

  /// \return an Array instance which refers to the same underlying
  /// object.  If \c isArray() would return false, this will assert.
  Array getArray(JSContext &runtime) const &;

  /// \return an Array instance which refers to the same underlying
  /// object.  If \c isArray() would return false, this will assert.
  Array getArray(JSContext &runtime) &&;

  /// \return an Array instance which refers to the same underlying
  /// object.  If \c isArray() would return false, this will throw
  /// JSAException.
  Array asArray(JSContext &runtime) const &;

  /// \return an Array instance which refers to the same underlying
  /// object.  If \c isArray() would return false, this will throw
  /// JSAException.
  Array asArray(JSContext &runtime) &&;

  /// \return an ArrayBuffer instance which refers to the same underlying
  /// object.  If \c isArrayBuffer() would return false, this will assert.
  ArrayBuffer getArrayBuffer(JSContext &runtime) const &;

  /// \return an ArrayBuffer instance which refers to the same underlying
  /// object.  If \c isArrayBuffer() would return false, this will assert.
  ArrayBuffer getArrayBuffer(JSContext &runtime) &&;

  /// \return an ArrayBufferView instance which refers to the same underlying
  /// object
  ArrayBufferView getArrayBufferView(JSContext &context) const &;
  ArrayBufferView getArrayBufferView(JSContext &context) &&;

  /// \return a Function instance which refers to the same underlying
  /// object.  If \c isFunction() would return false, this will assert.
  Function getFunction(JSContext &runtime) const &;

  /// \return a Function instance which refers to the same underlying
  /// object.  If \c isFunction() would return false, this will assert.
  Function getFunction(JSContext &runtime) &&;

  /// \return a Function instance which refers to the same underlying
  /// object.  If \c isFunction() would return false, this will throw
  /// JSAException.
  Function asFunction(JSContext &runtime) const &;

  /// \return a Function instance which refers to the same underlying
  /// object.  If \c isFunction() would return false, this will throw
  /// JSAException.
  Function asFunction(JSContext &runtime) &&;

  /// \return a shared_ptr<T> which refers to the same underlying
  /// \c HostObject that was used to create this object. If \c isHostObject<T>
  /// is false, this will assert. Note that this does a type check and will
  /// assert if the underlying HostObject isn't of type \c T
  template <typename T = HostObject>
  std::shared_ptr<T> getHostObject(JSContext &runtime) const;

  /// \return a shared_ptr<T> which refers to the same underlying
  /// \c HostObject that was used to crete this object. If \c isHostObject<T>
  /// is false, this will throw.
  template <typename T = HostObject>
  std::shared_ptr<T> asHostObject(JSContext &runtime) const;

  /// \return same as \c getProperty(name).asObject(), except with
  /// a better exception message.
  Object getPropertyAsObject(JSContext &runtime, const char *name) const;

  /// \return similar to \c
  /// getProperty(name).getObject().getFunction(), except it will
  /// throw JSAException instead of asserting if the property is
  /// not an object, or the object is not callable.
  Function getPropertyAsFunction(JSContext &runtime, const char *name) const;

  /// \return an Array consisting of all enumerable property names in
  /// the object and its prototype chain.  All values in the return
  /// will be isString().  (This is probably not optimal, but it
  /// works.  I only need it in one place.)
  Array getPropertyNames(JSContext &runtime) const;

protected:
  void setPropertyValue(JSContext &runtime, const String &name,
                        const Value &value) {
    return runtime.setPropertyValue(*this, name, value);
  }

  void setPropertyValue(JSContext &runtime, const PropNameID &name,
                        const Value &value) {
    return runtime.setPropertyValue(*this, name, value);
  }

  friend class JSContext;
  friend class Value;
};

/// Represents a weak reference to a JS Object.  If the only reference
/// to an Object are these, the object is eligible for GC.  Method
/// names are inspired by C++ weak_ptr.  Movable, not copyable.
class WeakObject : public Pointer {
public:
  using Pointer::Pointer;

  WeakObject(WeakObject &&other) = default;
  WeakObject &operator=(WeakObject &&other) = default;

  /// Create a WeakObject from an Object.
  WeakObject(JSContext &runtime, const Object &o)
      : WeakObject(runtime.createWeakObject(o)) {}

  /// \return a Value representing the underlying Object if it is still valid;
  /// otherwise returns \c undefined.  Note that this method has nothing to do
  /// with threads or concurrency.  The name is based on std::weak_ptr::lock()
  /// which serves a similar purpose.
  Value lock(JSContext &runtime);

  friend class JSContext;
};

/// Represents a JS Object which can be efficiently used as an array
/// with integral indices.
class Array : public Object {
public:
  Array(Array &&) = default;
  /// Creates a new Array instance, with \c length undefined elements.
  Array(JSContext &runtime, size_t length)
      : Array(runtime.createArray(length)) {}

  Array &operator=(Array &&) = default;

  /// \return the size of the Array, according to its length property.
  /// (C++ naming convention)
  size_t size(JSContext &runtime) const { return runtime.size(*this); }

  /// \return the size of the Array, according to its length property.
  /// (JS naming convention)
  size_t length(JSContext &runtime) const { return size(runtime); }

  /// \return the property of the array at index \c i.  If there is no
  /// such property, returns the undefined value.  If \c i is out of
  /// range [ 0..\c length ] throws a JSAException.
  Value getValueAtIndex(JSContext &runtime, size_t i) const;

  /// Sets the property of the array at index \c i.  The argument
  /// value behaves as with Object::setProperty().  If \c i is out of
  /// range [ 0..\c length ] throws a JSAException.
  template <typename T>
  void setValueAtIndex(JSContext &runtime, size_t i, T &&value);

  /// There is no current API for changing the size of an array once
  /// created.  We'll probably need that eventually.

  /// Creates a new Array instance from provided values
  template <typename... Args>
  static Array createWithElements(JSContext &, Args &&... args);

  /// Creates a new Array instance from intitializer list.
  static Array createWithElements(JSContext &runtime,
                                  std::initializer_list<Value> elements);

private:
  friend class Object;
  friend class Value;

  void setValueAtIndexImpl(JSContext &runtime, size_t i, const Value &value) {
    return runtime.setValueAtIndexImpl(*this, i, value);
  }

  Array(JSContext::PointerValue *value) : Object(value) {}
};

/// Represents a JSArrayBuffer
class ArrayBuffer : public Object {
public:
  ArrayBuffer(ArrayBuffer &&) = default;
  ArrayBuffer &operator=(ArrayBuffer &&) = default;

  /// \return the size of the ArrayBuffer, according to its byteLength property.
  /// (C++ naming convention)
  size_t size(JSContext &runtime) const { return runtime.size(*this); }
  size_t length(JSContext &runtime) const { return runtime.size(*this); }

  /// create an arrayBuffer with int8 array,
  static ArrayBuffer
  createWithUnit8(JSContext &context, uint8_t *data, size_t length,
                  ArrayBufferDeallocator<uint8_t> deallocator) {
    return context.createArrayBuffer(data, length, deallocator);
  }

  template <typename T> T *data(JSContext &runtime) {
    return static_cast<T *>(runtime.data(*this));
  }

private:
  friend class Object;
  friend class Value;

  ArrayBuffer(JSContext::PointerValue *value) : Object(value) {}
};

/// ArrayBufferView is a helper type representing any of the following
/// JavaScript TypedArray types:
class ArrayBufferView : public Object {
public:
  ArrayBufferView(ArrayBufferView &&) = default;
  ArrayBufferView &operator=(ArrayBufferView &&) = default;

  /// return the bytesize of ArrayBufferView
  size_t size(JSContext &context) const { return context.size(*this); }

  template <typename T> T *data(JSContext &context) {
    return static_cast<T *>(context.data(*this));
  }

  ArrayBufferViewType getType(JSContext &context) {
    return context.arrayBufferViewType(*this);
  }

private:
  friend class Object;
  friend class Value;

  ArrayBufferView(JSContext::PointerValue *value) : Object(value){};
};

/// Represents a JS Object which is guaranteed to be Callable.
class Function : public Object {
public:
  Function(Function &&) = default;
  Function &operator=(Function &&) = default;

  /// Create a function which, when invoked, calls C++ code. If the
  /// function throws an exception, a JS Error will be created and
  /// thrown.
  /// \param name the name property for the function.
  /// \param paramCount the length property for the function, which
  /// may not be the number of arguments the function is passed.
  static Function createFromHostFunction(JSContext &runtime,
                                         const jsa::PropNameID &name,
                                         unsigned int paramCount,
                                         jsa::HostFunctionType func);

  /// Calls the function with \c count \c args.  The \c this value of
  /// the JS function will be undefined.
  Value call(JSContext &runtime, const Value *args, size_t count) const;

  /// Calls the function with a \c std::initializer_list of Value
  /// arguments. The \c this value of the JS function will be
  /// undefined.
  Value call(JSContext &runtime, std::initializer_list<Value> args) const;

  /// Calls the function with any number of arguments similarly to
  /// Object::setProperty().  The \c this value of the JS function
  /// will be undefined.
  template <typename... Args>
  Value call(JSContext &runtime, Args &&... args) const;

  /// Calls the function with \c count \c args and \c jsThis value passed
  /// as this value.
  Value callWithThis(JSContext &Runtime, const Object &jsThis,
                     const Value *args, size_t count) const;

  /// Calls the function with a \c std::initializer_list of Value
  /// arguments. The \c this value of the JS function will be
  /// undefined.
  Value callWithThis(JSContext &runtime, const Object &jsThis,
                     std::initializer_list<Value> args) const;

  /// Calls the function with any number of arguments similarly to
  /// Object::setProperty().  The \c this value of the JS function
  /// will be undefined.
  template <typename... Args>
  Value callWithThis(JSContext &runtime, const Object &jsThis,
                     Args &&... args) const;

  /// Calls the function as a constructor with \c count \c args. Equivalent
  /// to calling `new Func` where `Func` is the js function reqresented by
  /// this.
  Value callAsConstructor(JSContext &runtime, const Value *args,
                          size_t count) const;

  /// Same as above `callAsConstructor`, except use an initializer_list to
  /// supply the arguments.
  Value callAsConstructor(JSContext &runtime,
                          std::initializer_list<Value> args) const;

  /// Same as above `callAsConstructor`, but automatically converts/wraps
  /// any argument with a jsa Value.
  template <typename... Args>
  Value callAsConstructor(JSContext &runtime, Args &&... args) const;

  /// Returns whether this was created with Function::createFromHostFunction.
  /// If true then you can use getHostFunction to get the underlying
  /// HostFunctionType.
  bool isHostFunction(JSContext &runtime) const {
    return runtime.isHostFunction(*this);
  }

  /// Returns the underlying HostFunctionType iff isHostFunction returns true
  /// and asserts otherwise. You can use this to use std::function<>::target
  /// to get the object that was passed to create the HostFunctionType.
  ///
  /// Note: The reference returned is borrowed from the JS object underlying
  ///       \c this, and thus only lasts as long as the object underlying
  ///       \c this does.
  HostFunctionType &getHostFunction(JSContext &runtime) const {
    assert(isHostFunction(runtime));
    return runtime.getHostFunction(*this);
  }

private:
  friend class Object;
  friend class Value;

  Function(JSContext::PointerValue *value) : Object(value) {}
};

/// Represents any JS Value (undefined, null, boolean, number, symbol,
/// string, or object).  Movable, or explicitly copyable (has no copy
/// ctor).
class Value {
public:
  /// Default ctor creates an \c undefined JS value.
  Value() : Value(UndefinedKind) {}

  /// Creates a \c null JS value.
  /* implicit */ Value(std::nullptr_t) : kind_(NullKind) {}

  /// Creates a boolean JS value.
  /* implicit */ Value(bool b) : Value(BooleanKind) { data_.boolean = b; }

  /// Creates a number JS value.
  /* implicit */ Value(double d) : Value(NumberKind) { data_.number = d; }

  /// Creates a number JS value.
  /* implicit */ Value(int i) : Value(NumberKind) { data_.number = i; }

  /// Moves a Symbol, String, or Object rvalue into a new JS value.
  template <typename T>
  /* implicit */ Value(T &&other) : Value(kindOf(other)) {
    static_assert(std::is_base_of<Symbol, T>::value ||
                      std::is_base_of<String, T>::value ||
                      std::is_base_of<Object, T>::value,
                  "Value cannot be implictly move-constructed from this type");
    new (&data_.pointer) T(std::move(other));
  }

  /// Value("foo") will treat foo as a bool.  This makes doing that a
  /// compile error.
  template <typename T = void> Value(const char *) {
    static_assert(!std::is_same<void, T>::value,
                  "Value cannot be constructed directly from const char*");
  }

  Value(Value &&value);

  /// Copies a Symbol lvalue into a new JS value.
  Value(JSContext &runtime, const Symbol &sym) : Value(SymbolKind) {
    new (&data_.pointer) String(runtime.cloneSymbol(sym.ptr_));
  }

  /// Copies a String lvalue into a new JS value.
  Value(JSContext &runtime, const String &str) : Value(StringKind) {
    new (&data_.pointer) String(runtime.cloneString(str.ptr_));
  }

  /// Copies a Object lvalue into a new JS value.
  Value(JSContext &runtime, const Object &obj) : Value(ObjectKind) {
    new (&data_.pointer) Object(runtime.cloneObject(obj.ptr_));
  }

  /// Creates a JS value from another Value lvalue.
  Value(JSContext &runtime, const Value &value);

  /// Value(context, "foo") will treat foo as a bool.  This makes doing
  /// that a compile error.
  template <typename T = void> Value(JSContext &, const char *) {
    static_assert(!std::is_same<T, void>::value,
                  "Value cannot be constructed directly from const char*");
  }

  ~Value();
  // \return the undefined \c Value.
  static Value undefined() { return Value(); }

  // \return the null \c Value.
  static Value null() { return Value(nullptr); }

  // \return a \c Value created from a utf8-encoded JSON string.
  static Value createFromJsonUtf8(JSContext &runtime, const uint8_t *json,
                                  size_t length);

  /// \return according to the SameValue algorithm see more here:
  //  https://www.ecma-international.org/ecma-262/5.1/#sec-11.9.4
  static bool strictEquals(JSContext &runtime, const Value &a, const Value &b);

  Value &operator=(Value &&other) {
    this->~Value();
    new (this) Value(std::move(other));
    return *this;
  }

  bool isUndefined() const { return kind_ == UndefinedKind; }

  bool isNull() const { return kind_ == NullKind; }

  bool isBool() const { return kind_ == BooleanKind; }

  bool isNumber() const { return kind_ == NumberKind; }

  bool isString() const { return kind_ == StringKind; }

  bool isSymbol() const { return kind_ == SymbolKind; }

  bool isObject() const { return kind_ == ObjectKind; }

  /// \return the boolean value, or asserts if not a boolean.
  bool getBool() const {
    assert(isBool());
    return data_.boolean;
  }

  /// \return the number value, or asserts if not a number.
  double getNumber() const {
    assert(isNumber());
    return data_.number;
  }

  /// \return the number value, or throws JSAException if not a
  /// number.
  double asNumber() const;

  /// \return the Symbol value, or asserts if not a symbol.
  Symbol getSymbol(JSContext &runtime) const & {
    assert(isSymbol());
    return Symbol(runtime.cloneSymbol(data_.pointer.ptr_));
  }

  /// \return the Symbol value, or asserts if not a symbol.
  /// Can be used on rvalue references to avoid cloning more symbols.
  Symbol getSymbol(JSContext &) && {
    assert(isSymbol());
    auto ptr = data_.pointer.ptr_;
    data_.pointer.ptr_ = nullptr;
    return static_cast<Symbol>(ptr);
  }

  /// \return the Symbol value, or throws JSAException if not a
  /// symbol
  Symbol asSymbol(JSContext &runtime) const &;
  Symbol asSymbol(JSContext &runtime) &&;

  /// \return the String value, or asserts if not a string.
  String getString(JSContext &runtime) const & {
    assert(isString());
    return String(runtime.cloneString(data_.pointer.ptr_));
  }

  /// \return the String value, or asserts if not a string.
  /// Can be used on rvalue references to avoid cloning more strings.
  String getString(JSContext &) && {
    assert(isString());
    auto ptr = data_.pointer.ptr_;
    data_.pointer.ptr_ = nullptr;
    return static_cast<String>(ptr);
  }

  /// \return the String value, or throws JSAException if not a
  /// string.
  String asString(JSContext &runtime) const &;
  String asString(JSContext &runtime) &&;

  /// \return the Object value, or asserts if not an object.
  Object getObject(JSContext &runtime) const & {
    assert(isObject());
    return Object(runtime.cloneObject(data_.pointer.ptr_));
  }

  /// \return the Object value, or asserts if not an object.
  /// Can be used on rvalue references to avoid cloning more objects.
  Object getObject(JSContext &) && {
    assert(isObject());
    auto ptr = data_.pointer.ptr_;
    data_.pointer.ptr_ = nullptr;
    return static_cast<Object>(ptr);
  }

  /// \return the Object value, or throws JSAException if not an
  /// object.
  Object asObject(JSContext &runtime) const &;
  Object asObject(JSContext &runtime) &&;

  // \return a String like JS .toString() would do.
  String toString(JSContext &runtime) const;

  std::string toJSON(JSContext &context) const;

private:
  friend class JSContext;

  enum ValueKind {
    UndefinedKind,
    NullKind,
    BooleanKind,
    NumberKind,
    SymbolKind,
    StringKind,
    ObjectKind,
    PointerKind = SymbolKind,
  };

  union Data {
    // Value's ctor and dtor will manage the lifecycle of the contained Data.
    Data() {
      static_assert(sizeof(Data) == sizeof(uint64_t),
                    "Value data should fit in a 64-bit register");
    }
    ~Data() {}

    // scalars
    bool boolean;
    double number;
    // pointers
    Pointer pointer; // Symbol, String, Object, Array, Function
  };

  Value(ValueKind kind) : kind_(kind) {}

  constexpr static ValueKind kindOf(const Symbol &) { return SymbolKind; }
  constexpr static ValueKind kindOf(const String &) { return StringKind; }
  constexpr static ValueKind kindOf(const Object &) { return ObjectKind; }

  ValueKind kind_;
  Data data_;

  // In the future: Value becomes NaN-boxed. See T40538354.
};

namespace detail {

inline Value toValue(JSContext &, std::nullptr_t) { return Value::null(); }
inline Value toValue(JSContext &, bool b) { return Value(b); }
inline Value toValue(JSContext &, double d) { return Value(d); }
inline Value toValue(JSContext &, float f) {
  return Value(static_cast<double>(f));
}
inline Value toValue(JSContext &, int i) { return Value(i); }
inline Value toValue(JSContext &runtime, const char *str) {
  return String::createFromAscii(runtime, str);
}
inline Value toValue(JSContext &runtime, const std::string &str) {
  return String::createFromAscii(runtime, str);
}
template <typename T> inline Value toValue(JSContext &runtime, const T &other) {
  static_assert(std::is_base_of<Pointer, T>::value,
                "This type cannot be converted to Value");
  return Value(runtime, other);
}
inline Value toValue(JSContext &runtime, const Value &value) {
  return Value(runtime, value);
}
inline Value &&toValue(JSContext &, Value &&value) { return std::move(value); }

inline PropNameID toPropNameID(JSContext &runtime, const char *name) {
  return PropNameID::forAscii(runtime, name);
}
inline PropNameID toPropNameID(JSContext &runtime, const std::string &name) {
  return PropNameID::forUtf8(runtime, name);
}
inline PropNameID &&toPropNameID(JSContext &, PropNameID &&name) {
  return std::move(name);
}

void throwJSError(JSContext &, const char *msg);

} // namespace detail

inline Value Object::getProperty(JSContext &runtime, const char *name) const {
  return getProperty(runtime, String::createFromAscii(runtime, name));
}

inline Value Object::getProperty(JSContext &runtime, const String &name) const {
  return runtime.getProperty(*this, name);
}

inline Value Object::getProperty(JSContext &runtime,
                                 const PropNameID &name) const {
  return runtime.getProperty(*this, name);
}

inline bool Object::hasProperty(JSContext &runtime, const char *name) const {
  return hasProperty(runtime, String::createFromAscii(runtime, name));
}

inline bool Object::hasProperty(JSContext &runtime, const String &name) const {
  return runtime.hasProperty(*this, name);
}

inline bool Object::hasProperty(JSContext &runtime,
                                const PropNameID &name) const {
  return runtime.hasProperty(*this, name);
}

template <typename T>
void Object::setProperty(JSContext &runtime, const char *name, T &&value) {
  setProperty(runtime, String::createFromAscii(runtime, name),
              std::forward<T>(value));
}

template <typename T>
void Object::setProperty(JSContext &runtime, const String &name, T &&value) {
  setPropertyValue(runtime, name,
                   detail::toValue(runtime, std::forward<T>(value)));
}

template <typename T>
void Object::setProperty(JSContext &runtime, const PropNameID &name,
                         T &&value) {
  setPropertyValue(runtime, name,
                   detail::toValue(runtime, std::forward<T>(value)));
}

inline Array Object::getArray(JSContext &runtime) const & {
  assert(runtime.isArray(*this));
  (void)runtime; // when assert is disabled we need to mark this as used
  return Array(runtime.cloneObject(ptr_));
}

inline Array Object::getArray(JSContext &runtime) && {
  assert(runtime.isArray(*this));
  (void)runtime; // when assert is disabled we need to mark this as used
  JSContext::PointerValue *value = ptr_;
  ptr_ = nullptr;
  return Array(value);
}

inline ArrayBuffer Object::getArrayBuffer(JSContext &runtime) const & {
  assert(runtime.isArrayBuffer(*this));
  (void)runtime; // when assert is disabled we need to mark this as used
  return ArrayBuffer(runtime.cloneObject(ptr_));
}

inline ArrayBuffer Object::getArrayBuffer(JSContext &runtime) && {
  assert(runtime.isArrayBuffer(*this));
  (void)runtime; // when assert is disabled we need to mark this as used
  JSContext::PointerValue *value = ptr_;
  ptr_ = nullptr;
  return ArrayBuffer(value);
}

inline ArrayBufferView
Object::getArrayBufferView(alibaba::jsa::JSContext &context) const & {
  assert(context.isArrayBufferView(*this));
  return ArrayBufferView(context.cloneObject(ptr_));
}

inline ArrayBufferView Object::getArrayBufferView(JSContext &context) && {
  JSContext::PointerValue *value = ptr_;
  ptr_ = nullptr;
  return ArrayBufferView(value);
}

inline Function Object::getFunction(JSContext &runtime) const & {
  assert(runtime.isFunction(*this));
  return Function(runtime.cloneObject(ptr_));
}

inline Function Object::getFunction(JSContext &runtime) && {
  assert(runtime.isFunction(*this));
  (void)runtime; // when assert is disabled we need to mark this as used
  JSContext::PointerValue *value = ptr_;
  ptr_ = nullptr;
  return Function(value);
}

template <typename T>
inline bool Object::isHostObject(JSContext &runtime) const {
  return runtime.isHostObject(*this) &&
         std::dynamic_pointer_cast<T>(runtime.getHostObject(*this));
}

template <>
inline bool Object::isHostObject<HostObject>(JSContext &runtime) const {
  return runtime.isHostObject(*this);
}

template <typename T>
inline std::shared_ptr<T> Object::getHostObject(JSContext &runtime) const {
  assert(isHostObject<T>(runtime));
  return std::static_pointer_cast<T>(runtime.getHostObject(*this));
}

template <typename T>
inline std::shared_ptr<T> Object::asHostObject(JSContext &runtime) const {
  if (!isHostObject<T>(runtime)) {
    detail::throwJSError(runtime, "Object is not a HostObject of desired type");
  }
  return std::static_pointer_cast<T>(runtime.getHostObject(*this));
}

template <>
inline std::shared_ptr<HostObject>
Object::getHostObject<HostObject>(JSContext &runtime) const {
  assert(runtime.isHostObject(*this));
  return runtime.getHostObject(*this);
}

inline Array Object::getPropertyNames(JSContext &runtime) const {
  return runtime.getPropertyNames(*this);
}

inline Value WeakObject::lock(JSContext &runtime) {
  return runtime.lockWeakObject(*this);
}

template <typename T>
void Array::setValueAtIndex(JSContext &runtime, size_t i, T &&value) {
  setValueAtIndexImpl(runtime, i,
                      detail::toValue(runtime, std::forward<T>(value)));
}

inline Value Array::getValueAtIndex(JSContext &runtime, size_t i) const {
  return runtime.getValueAtIndex(*this, i);
}

inline Function Function::createFromHostFunction(JSContext &runtime,
                                                 const jsa::PropNameID &name,
                                                 unsigned int paramCount,
                                                 jsa::HostFunctionType func) {
  return runtime.createFunctionFromHostFunction(name, paramCount,
                                                std::move(func));
}

inline Value Function::call(JSContext &runtime, const Value *args,
                            size_t count) const {
  return runtime.call(*this, Value::undefined(), args, count);
}

inline Value Function::call(JSContext &runtime,
                            std::initializer_list<Value> args) const {
  return call(runtime, args.begin(), args.size());
}

template <typename... Args>
inline Value Function::call(JSContext &runtime, Args &&... args) const {
  // A more awesome version of this would be able to create raw values
  // which can be used directly without wrapping and unwrapping, but
  // this will do for now.
  return call(runtime, {detail::toValue(runtime, std::forward<Args>(args))...});
}

inline Value Function::callWithThis(JSContext &runtime, const Object &jsThis,
                                    const Value *args, size_t count) const {
  return runtime.call(*this, Value(runtime, jsThis), args, count);
}

inline Value Function::callWithThis(JSContext &runtime, const Object &jsThis,
                                    std::initializer_list<Value> args) const {
  return callWithThis(runtime, jsThis, args.begin(), args.size());
}

template <typename... Args>
inline Value Function::callWithThis(JSContext &runtime, const Object &jsThis,
                                    Args &&... args) const {
  // A more awesome version of this would be able to create raw values
  // which can be used directly without wrapping and unwrapping, but
  // this will do for now.
  return callWithThis(runtime, jsThis,
                      {detail::toValue(runtime, std::forward<Args>(args))...});
}

template <typename... Args>
inline Array Array::createWithElements(JSContext &runtime, Args &&... args) {
  return createWithElements(
      runtime, {detail::toValue(runtime, std::forward<Args>(args))...});
}

template <typename... Args>
inline std::vector<PropNameID> PropNameID::names(JSContext &runtime,
                                                 Args &&... args) {
  return names({detail::toPropNameID(runtime, std::forward<Args>(args))...});
}

template <size_t N>
inline std::vector<PropNameID>
PropNameID::names(PropNameID(&&propertyNames)[N]) {
  std::vector<PropNameID> result;
  result.reserve(N);
  for (auto &name : propertyNames) {
    result.push_back(std::move(name));
  }
  return result;
}

inline Value Function::callAsConstructor(JSContext &runtime, const Value *args,
                                         size_t count) const {
  return runtime.callAsConstructor(*this, args, count);
}

inline Value
Function::callAsConstructor(JSContext &runtime,
                            std::initializer_list<Value> args) const {
  return callAsConstructor(runtime, args.begin(), args.size());
}

template <typename... Args>
inline Value Function::callAsConstructor(JSContext &runtime,
                                         Args &&... args) const {
  return callAsConstructor(
      runtime, {detail::toValue(runtime, std::forward<Args>(args))...});
}

} // namespace jsa
} // namespace alibaba

#endif // JSA_JSTYPE_H_
