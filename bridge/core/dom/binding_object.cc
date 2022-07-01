/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "binding_object.h"
#include "binding_call_methods.h"
#include "bindings/qjs/exception_state.h"
#include "core/executing_context.h"
#include "foundation/logging.h"

namespace kraken {

void NativeBindingObject::HandleCallFromDartSide(NativeBindingObject* binding_object,
                                                 NativeValue* return_value,
                                                 NativeString* method,
                                                 int32_t argc,
                                                 NativeValue* argv) {
  NativeValue result = binding_object->binding_target_->HandleCallFromDartSide(method, argc, argv);
  if (return_value != nullptr)
    *return_value = result;
}

BindingObject::BindingObject(ExecutingContext* context) : context_(context) {}
BindingObject::~BindingObject() {
  delete binding_object_;
}

void BindingObject::BindDartObject(NativeBindingObject* native_binding_object) {
  native_binding_object->binding_target_ = this;
  native_binding_object->invoke_binding_methods_from_dart = NativeBindingObject::HandleCallFromDartSide;
  binding_object_ = native_binding_object;
}

NativeValue BindingObject::InvokeBindingMethod(const AtomicString& method,
                                               int32_t argc,
                                               const NativeValue* argv,
                                               ExceptionState& exception_state) const {
  if (binding_object_->invoke_bindings_methods_from_native == nullptr) {
    exception_state.ThrowException(context_->ctx(), ErrorType::InternalError,
                                   "Failed to call dart method: invokeBindingMethod not initialized.");
    return Native_NewNull();
  }

  KRAKEN_LOG(VERBOSE) << " binding object_ " << &binding_object_;
  NativeValue return_value = Native_NewNull();
  binding_object_->invoke_bindings_methods_from_native(binding_object_, &return_value,
                                                       method.ToNativeString().release(), argc, argv);
  return return_value;
}

NativeValue BindingObject::GetBindingProperty(const AtomicString& prop, ExceptionState& exception_state) const {
  context_->FlushUICommand();
  const NativeValue argv[] = {Native_NewString(prop.ToNativeString().release())};
  return InvokeBindingMethod(binding_call_methods::kgetPropertyMagic, 1, argv, exception_state);
}

NativeValue BindingObject::SetBindingProperty(const AtomicString& prop,
                                              NativeValue value,
                                              ExceptionState& exception_state) const {
  context_->FlushUICommand();
  const NativeValue argv[] = {Native_NewString(prop.ToNativeString().release()), value};
  return InvokeBindingMethod(binding_call_methods::ksetPropertyMagic, 2, argv, exception_state);
}

}  // namespace kraken
