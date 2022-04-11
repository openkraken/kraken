/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"

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

BoundingClientRect* Element::getBoundingClientRect() {
  return nullptr;
}

}  // namespace kraken
