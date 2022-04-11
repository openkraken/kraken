/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "binding_call_methods.h"
#include "bindings/qjs/exception_state.h"
#include "foundation/native_value_converter.h"

namespace kraken {

Element::Element(Document* document, const AtomicString& tag_name, Node::ConstructionType construction_type)
    : ContainerNode(document, construction_type), attributes_(MakeGarbageCollected<ElementAttributes>(this)) {}

bool Element::hasAttribute(const AtomicString& name, ExceptionState& exception_state) const {
  return attributes_->HasAttribute(name);
}

AtomicString Element::getAttribute(const AtomicString& name, ExceptionState& exception_state) const {
  return attributes_->GetAttribute(name);
}

void Element::setAttribute(const AtomicString& name, const AtomicString& value) {
  ExceptionState exception_state;
  return setAttribute(name, value, exception_state);
}

void Element::setAttribute(const AtomicString& name, const AtomicString& value, ExceptionState& exception_state) {
  if (attributes_->HasAttribute(name)) {
    AtomicString&& oldAttribute = attributes_->GetAttribute(name);
    if (!attributes_->SetAttribute(name, value, exception_state)) {
      return;
    };
    _didModifyAttribute(name, oldAttribute, value);
  } else {
    if (!attributes_->SetAttribute(name, value, exception_state)) {
      return;
    };
    _didModifyAttribute(name, AtomicString::Empty(ctx()), value);
  }

  std::unique_ptr<NativeString> args_01 = name.ToNativeString();
  std::unique_ptr<NativeString> args_02 = value.ToNativeString();

  GetExecutingContext()->uiCommandBuffer()->addCommand(eventTargetId(), static_cast<int32_t>(UICommand::setAttribute),
                                                       args_01, args_02, nullptr);
}

void Element::removeAttribute(const AtomicString& name, ExceptionState& exception_state) {
  attributes_->RemoveAttribute(name);
}

BoundingClientRect* Element::getBoundingClientRect(ExceptionState& exception_state) {
  GetExecutingContext()->dartMethodPtr()->flushUICommand();
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetBoundingClientRect, 0, nullptr, exception_state);
  return BoundingClientRect::Create(
      GetExecutingContext(),
      NativeValueConverter<NativeTypePointer<NativeBoundingClientRect>>::FromNativeValue(result));
}

void Element::click(ExceptionState& exception_state) {
  GetExecutingContext()->dartMethodPtr()->flushUICommand();
  InvokeBindingMethod(binding_call_methods::kclick, 0, nullptr, exception_state);
}

}  // namespace kraken
