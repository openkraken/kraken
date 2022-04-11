/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "binding_object.h"

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

BindingObject::BindingObject(ExecutingContext* context) {}

NativeValue BindingObject::InvokeBindingMethod(const AtomicString& method,
                                               int32_t argc,
                                               const NativeValue* args) const {}

NativeValue BindingObject::GetBindingProperty(const AtomicString& prop) const {
  return NativeValue();
}

NativeValue BindingObject::SetBindingProperty(const AtomicString& prop, NativeValue value) const {
  return NativeValue();
}

}  // namespace kraken
