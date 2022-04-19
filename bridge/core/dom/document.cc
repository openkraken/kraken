/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "core/html/html_element.h"
#include "core/html/html_unknown_element.h"
#include "foundation/ascii_types.h"
#include "html_element_factory.h"

namespace kraken {

Document* Document::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<Document>(context);
}

Document::Document(ExecutingContext* context)
    : Node(context, this, ConstructionType::kCreateDocument), TreeScope(*this) {}

ScriptValue Document::createElement(const AtomicString& name, ExceptionState& exception_state) {
  if (!IsValidName(name)) {
    exception_state.ThrowException(ctx(), ErrorType::InternalError,
                                   "The tag name provided ('" + name.ToStdString() + "') is not a valid name.");
    return ScriptValue::Empty(ctx());
  }

  if (auto* element = HTMLElementFactory::Create(name, *this)) {
    return element->ToValue();
  }

  return MakeGarbageCollected<HTMLUnknownElement>(name, *this)->ToValue();
}

Text* Document::createTextNode(const AtomicString& value, ExceptionState& exception_state) {
  return Text::Create(*this, value);
}

DocumentFragment* Document::createDocumentFragment(ExceptionState& exception_state) {
  return DocumentFragment::Create(*this);
}

Comment* Document::createComment(ExceptionState& exception_state) {
  return Comment::Create(*this);
}

std::string Document::nodeName() const {
  return "#document";
}

std::string Document::nodeValue() const {
  return "";
}

Node::NodeType Document::nodeType() const {
  return kDocumentNode;
}

template <typename CharType>
static inline bool IsValidNameASCII(const CharType* characters, unsigned length) {
  CharType c = characters[0];
  if (!(IsASCIIAlpha(c) || c == ':' || c == '_'))
    return false;

  for (unsigned i = 1; i < length; ++i) {
    c = characters[i];
    if (!(IsASCIIAlphanumeric(c) || c == ':' || c == '_' || c == '-' || c == '.'))
      return false;
  }

  return true;
}

bool Document::IsValidName(const AtomicString& name) {
  unsigned length = name.length();
  if (!length)
    return false;

  auto string_view = name.ToStringView();

  if (string_view.Is8Bit()) {
    const char* characters = string_view.Characters8();
    if (IsValidNameASCII(characters, length)) {
      return true;
    }
  }

  const char16_t* characters = string_view.Characters16();

  if (IsValidNameASCII(characters, length)) {
    return true;
  }

  return false;
}

Node* Document::Clone(Document&, CloneChildrenFlag) const {
  return nullptr;
}

}  // namespace kraken
