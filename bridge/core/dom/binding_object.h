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

using InvokeBindingsMethodsFromNative =
    void (*)(NativeBindingObject* binding_object, NativeValue* return_value, NativeString* method, int32_t argc, NativeValue* argv);

using InvokeBindingMethodsFromDart =
    void (*)(NativeBindingObject* binding_object, NativeValue* return_value, NativeString* method, int32_t argc, NativeValue* argv);

struct NativeBindingObject {
  NativeBindingObject() = delete;
  explicit NativeBindingObject(BindingObject* target)
      : binding_target_(target), invoke_binding_methods_from_dart(HandleCallFromDartSide) {};

  static void HandleCallFromDartSide(NativeBindingObject* binding_object, NativeValue* return_value, NativeString* method, int32_t argc, NativeValue* argv);

  BindingObject* binding_target_{nullptr};
#if UNIT_TEST
  InvokeBindingMethod invokeBindingMethod{reinterpret_cast<InvokeBindingMethod>(TEST_invokeBindingMethod)};
#else
  InvokeBindingMethodsFromDart invoke_binding_methods_from_dart{nullptr};
  InvokeBindingsMethodsFromNative invoke_bindings_methods_from_native{nullptr};
};

class BindingObject {
 public:
  BindingObject() = delete;
  explicit BindingObject(ExecutingContext* context);

  // Handle call from dart side.
  virtual NativeValue HandleCallFromDartSide(NativeString* method, int32_t argc, const NativeValue* argv) const = 0;
  // Invoke methods which implemented at dart side.
  NativeValue InvokeBindingMethod(const AtomicString& method, int32_t argc, const NativeValue* args) const;
  NativeValue GetBindingProperty(const AtomicString& prop) const;
  NativeValue SetBindingProperty(const AtomicString& prop, NativeValue value) const;

 private:
  NativeBindingObject binding_object_{this};
};


}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_BINDING_OBJECT_H_
