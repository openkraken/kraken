/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "bindings/qjs/exception_message.h"
#include "core/dom/element.h"
#include "core/html/html_body_element.h"
#include "core/html/html_element.h"
#include "core/html/html_head_element.h"
#include "core/html/html_html_element.h"
#include "core/html/html_unknown_element.h"
#include "element_traversal.h"
#include "foundation/ascii_types.h"
#include "html_element_factory.h"

namespace kraken {

Document* Document::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<Document>(context);
}

Document::Document(ExecutingContext* context)
    : ContainerNode(context, this, ConstructionType::kCreateDocument), TreeScope(*this) {
  document_element_ = MakeGarbageCollected<HTMLHtmlElement>(*this);

#if FLUTTER_BACKEND
  GetExecutingContext()->dartMethodPtr()->initDocument(context->contextId(), (void*)bindingObject());
#endif
}

Element* Document::createElement(const AtomicString& name, ExceptionState& exception_state) {
  if (!IsValidName(name)) {
    exception_state.ThrowException(ctx(), ErrorType::InternalError,
                                   "The tag name provided ('" + name.ToStdString() + "') is not a valid name.");
    return nullptr;
  }

  if (auto* element = HTMLElementFactory::Create(name, *this)) {
    return element;
  }

  return MakeGarbageCollected<HTMLUnknownElement>(name, *this);
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

bool Document::ChildTypeAllowed(NodeType type) const {
  switch (type) {
    case kAttributeNode:
    case kDocumentFragmentNode:
    case kDocumentNode:
    case kTextNode:
      return false;
    case kCommentNode:
      return true;
    case kDocumentTypeNode:
    case kElementNode:
      // Documents may contain no more than one of each of these.
      // (One Element and one DocumentType.)
      for (Node& c : NodeTraversal::ChildrenOf(*this)) {
        if (c.nodeType() == type)
          return false;
      }
      return true;
  }
  return false;
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
  assert(false);
  return nullptr;
}

void Document::InitDocumentElement() {
  ExceptionState exception_state;
  AppendChild(document_element_, exception_state);
}

HTMLBodyElement* Document::body() const {
  if (!IsA<HTMLHtmlElement>(documentElement()))
    return nullptr;

  for (HTMLElement* child = Traversal<HTMLElement>::FirstChild(*documentElement()); child;
       child = Traversal<HTMLElement>::NextSibling(*child)) {
    if (IsA<HTMLBodyElement>(*child))
      return DynamicTo<HTMLBodyElement>(child);
  }

  return nullptr;
}

void Document::setBody(HTMLBodyElement* new_body, ExceptionState& exception_state) {
  if (!new_body) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   ExceptionMessage::ArgumentNullOrIncorrectType(1, "HTMLBodyElement"));
    return;
  }

  if (!documentElement()) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "No document element exists.");
    return;
  }

  if (!IsA<HTMLBodyElement>(*new_body)) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "The new body element is of type '" + new_body->tagName().ToStdString() +
                                       "'. It must be either a 'BODY' element.");
    return;
  }

  HTMLElement* old_body = body();
  if (old_body == new_body)
    return;

  if (old_body)
    documentElement()->ReplaceChild(new_body, old_body, exception_state);
  else
    documentElement()->AppendChild(new_body, exception_state);
}

HTMLHeadElement* Document::head() const {
  Node* de = documentElement();
  if (de == nullptr)
    return nullptr;

  return Traversal<HTMLHeadElement>::FirstChild(*de);
}

uint32_t Document::RequestAnimationFrame(const std::shared_ptr<FrameCallback>& callback, ExceptionState& exception_state) {
  return script_animation_controller_.RegisterFrameCallback(callback, exception_state);
}

void Document::CancelAnimationFrame(uint32_t request_id, ExceptionState& exception_state) {
  script_animation_controller_.CancelFrameCallback(GetExecutingContext(), request_id, exception_state);
}

void Document::Trace(GCVisitor* visitor) const {
  visitor->Trace(document_element_);
  script_animation_controller_.Trace(visitor);
  ContainerNode::Trace(visitor);
}

}  // namespace kraken
