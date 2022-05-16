/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_BINDING_OBJECT_H_
#define KRAKENBRIDGE_CORE_DOM_BINDING_OBJECT_H_

#include <cinttypes>
#include "bindings/qjs/atomic_string.h"
#include "foundation/native_value.h"

namespace kraken {

class BindingObject;
class NativeBindingObject;
class ExceptionState;

using InvokeBindingsMethodsFromNative = void (*)(const NativeBindingObject* binding_object,
                                                 NativeValue* return_value,
                                                 NativeString* method,
                                                 int32_t argc,
                                                 const NativeValue* argv);

using InvokeBindingMethodsFromDart = void (*)(NativeBindingObject* binding_object,
                                              NativeValue* return_value,
                                              NativeString* method,
                                              int32_t argc,
                                              NativeValue* argv);

struct NativeBindingObject {
  NativeBindingObject() = delete;
  explicit NativeBindingObject(BindingObject* target)
      : binding_target_(target), invoke_binding_methods_from_dart(HandleCallFromDartSide){};

  static void HandleCallFromDartSide(NativeBindingObject* binding_object,
                                     NativeValue* return_value,
                                     NativeString* method,
                                     int32_t argc,
                                     NativeValue* argv);

  BindingObject* binding_target_{nullptr};
  InvokeBindingMethodsFromDart invoke_binding_methods_from_dart{nullptr};
  InvokeBindingsMethodsFromNative invoke_bindings_methods_from_native{nullptr};
};

class BindingObject {
 public:
  BindingObject() = delete;
  ~BindingObject() = default;
  explicit BindingObject(ExecutingContext* context);

  // Handle call from dart side.
  virtual NativeValue HandleCallFromDartSide(NativeString* method, int32_t argc, const NativeValue* argv) const = 0;
  // Invoke methods which implemented at dart side.
  NativeValue InvokeBindingMethod(const AtomicString& method,
                                  int32_t argc,
                                  const NativeValue* args,
                                  ExceptionState& exception_state) const;
  NativeValue GetBindingProperty(const AtomicString& prop, ExceptionState& exception_state) const;
  NativeValue SetBindingProperty(const AtomicString& prop, NativeValue value, ExceptionState& exception_state) const;

  const NativeBindingObject* bindingObject() const { return &binding_object_; }

 private:
  ExecutingContext* context_{nullptr};
  NativeBindingObject binding_object_{this};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_BINDING_OBJECT_H_
