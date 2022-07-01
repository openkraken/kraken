/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"

#include <utility>
#include "binding_call_methods.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "core/dom/document_fragment.h"
#include "core/fileapi/blob.h"
#include "core/html/html_template_element.h"
#include "core/html/parser/html_parser.h"
#include "foundation/native_value_converter.h"

namespace kraken {

Element::Element(const AtomicString& tag_name, Document* document, Node::ConstructionType construction_type)
    : ContainerNode(document, construction_type), tag_name_(tag_name) {
  GetExecutingContext()->uiCommandBuffer()->addCommand(eventTargetId(), UICommand::kCreateElement,
                                                       std::move(tag_name.ToNativeString()), (void*)bindingObject());
}

ElementAttributes& Element::EnsureElementAttributes() {
  if (attributes_ == nullptr) {
    attributes_ = ElementAttributes::Create(this);
  }
  return *attributes_;
}

bool Element::hasAttribute(const AtomicString& name, ExceptionState& exception_state) {
  return EnsureElementAttributes().hasAttribute(name, exception_state);
}

AtomicString Element::getAttribute(const AtomicString& name, ExceptionState& exception_state) {
  return EnsureElementAttributes().GetAttribute(name);
}

void Element::setAttribute(const AtomicString& name, const AtomicString& value) {
  ExceptionState exception_state;
  return setAttribute(name, value, exception_state);
}

void Element::setAttribute(const AtomicString& name, const AtomicString& value, ExceptionState& exception_state) {
  if (EnsureElementAttributes().hasAttribute(name, exception_state)) {
    AtomicString&& oldAttribute = EnsureElementAttributes().GetAttribute(name);
    if (!EnsureElementAttributes().setAttribute(name, value, exception_state)) {
      return;
    };
    _didModifyAttribute(name, oldAttribute, value);
  } else {
    if (!EnsureElementAttributes().setAttribute(name, value, exception_state)) {
      return;
    };
    _didModifyAttribute(name, AtomicString::Empty(ctx()), value);
  }

  std::unique_ptr<NativeString> args_01 = name.ToNativeString();
  std::unique_ptr<NativeString> args_02 = value.ToNativeString();

  GetExecutingContext()->uiCommandBuffer()->addCommand(eventTargetId(), UICommand::kSetAttribute, std::move(args_01),
                                                       std::move(args_02), nullptr);
}

void Element::removeAttribute(const AtomicString& name, ExceptionState& exception_state) {
  EnsureElementAttributes().removeAttribute(name, exception_state);
}

BoundingClientRect* Element::getBoundingClientRect(ExceptionState& exception_state) {
  GetExecutingContext()->FlushUICommand();
  NativeValue result = InvokeBindingMethod(binding_call_methods::kgetBoundingClientRect, 0, nullptr, exception_state);
  return BoundingClientRect::Create(
      GetExecutingContext(),
      NativeValueConverter<NativeTypePointer<NativeBoundingClientRect>>::FromNativeValue(result));
}

void Element::click(ExceptionState& exception_state) {
  GetExecutingContext()->FlushUICommand();
  InvokeBindingMethod(binding_call_methods::kclick, 0, nullptr, exception_state);
}

void Element::scroll(ExceptionState& exception_state) {
  return scroll(0, 0, exception_state);
}

void Element::scroll(double x, double y, ExceptionState& exception_state) {
  GetExecutingContext()->FlushUICommand();
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args, exception_state);
}

void Element::scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  GetExecutingContext()->FlushUICommand();
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->left()),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->top()),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args, exception_state);
}

void Element::scrollBy(ExceptionState& exception_state) {
  return scrollBy(0, 0, exception_state);
}

void Element::scrollBy(double x, double y, ExceptionState& exception_state) {
  GetExecutingContext()->FlushUICommand();
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Element::scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  GetExecutingContext()->FlushUICommand();
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->left()),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->top()),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Element::scrollTo(ExceptionState& exception_state) {
  return scroll(exception_state);
}

void Element::scrollTo(double x, double y, ExceptionState& exception_state) {
  return scroll(x, y, exception_state);
}

void Element::scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  return scroll(options, exception_state);
}

bool Element::HasTagName(const AtomicString& name) const {
  return name == tag_name_;
}

std::string Element::nodeValue() const {
  return "";
}

std::string Element::nodeName() const {
  return tag_name_.ToStdString();
}

CSSStyleDeclaration* Element::style() {
  if (!IsStyledElement())
    return nullptr;
  return &EnsureCSSStyleDeclaration();
}

CSSStyleDeclaration& Element::EnsureCSSStyleDeclaration() {
  if (cssom_wrapper_ == nullptr) {
    cssom_wrapper_ = MakeGarbageCollected<CSSStyleDeclaration>(GetExecutingContext(), eventTargetId());
  }
  return *cssom_wrapper_;
}

Element& Element::CloneWithChildren(CloneChildrenFlag flag, Document* document) const {
  Element& clone = CloneWithoutAttributesAndChildren(document ? *document : GetDocument());
  assert(IsHTMLElement() == clone.IsHTMLElement());

  clone.CloneAttributesFrom(*this);
  clone.CloneNonAttributePropertiesFrom(*this, flag);
  clone.CloneChildNodesFrom(*this, flag);
  return clone;
}

Element& Element::CloneWithoutChildren(Document* document) const {
  Element& clone = CloneWithoutAttributesAndChildren(document ? *document : GetDocument());

  assert(IsHTMLElement() == clone.IsHTMLElement());

  clone.CloneAttributesFrom(*this);
  clone.CloneNonAttributePropertiesFrom(*this, CloneChildrenFlag::kSkip);
  return clone;
}

void Element::CloneAttributesFrom(const Element& other) {
  if (other.attributes_ != nullptr) {
    EnsureElementAttributes().CopyWith(other.attributes_);
  }
  if (other.cssom_wrapper_ != nullptr) {
    EnsureCSSStyleDeclaration().CopyWith(other.cssom_wrapper_);
  }
}

bool Element::HasEquivalentAttributes(const Element& other) const {
  return attributes_ != nullptr && other.attributes_ != nullptr && other.attributes_->IsEquivalent(*attributes_);
}

void Element::Trace(GCVisitor* visitor) const {
  visitor->Trace(attributes_);
  visitor->Trace(cssom_wrapper_);
  ContainerNode::Trace(visitor);
}

Node* Element::Clone(Document& factory, CloneChildrenFlag flag) const {
  if (flag == CloneChildrenFlag::kSkip)
    return &CloneWithoutChildren(&factory);
  Element* copy = &CloneWithChildren(flag, &factory);
  return copy;
}

Element& Element::CloneWithoutAttributesAndChildren(Document& factory) const {
  return *(factory.createElement(tagName(), ASSERT_NO_EXCEPTION()));
}

class ElementSnapshotReader {
 public:
  ElementSnapshotReader(ExecutingContext* context,
                        Element* element,
                        std::shared_ptr<ScriptPromiseResolver> resolver,
                        double device_pixel_ratio)
      : context_(context), element_(element), resolver_(std::move(resolver)), device_pixel_ratio_(device_pixel_ratio) {
    Start();
  };

  void Start();
  void HandleSnapshot(uint8_t* bytes, int32_t length);
  void HandleFailed(const char* error);

 private:
  ExecutingContext* context_;
  Element* element_;
  std::shared_ptr<ScriptPromiseResolver> resolver_;
  double device_pixel_ratio_;
};

void ElementSnapshotReader::Start() {
  context_->FlushUICommand();

  auto callback = [](void* ptr, int32_t contextId, const char* error, uint8_t* bytes, int32_t length) -> void {
    auto* reader = static_cast<ElementSnapshotReader*>(ptr);
    if (error != nullptr) {
      reader->HandleFailed(error);
    } else {
      reader->HandleSnapshot(bytes, length);
    }
    delete reader;
  };

  context_->dartMethodPtr()->toBlob(this, context_->contextId(), callback, element_->eventTargetId(),
                                    device_pixel_ratio_);
}

void ElementSnapshotReader::HandleSnapshot(uint8_t* bytes, int32_t length) {
  MemberMutationScope mutation_scope{context_};
  Blob* blob = Blob::Create(context_);
  blob->AppendBytes(bytes, length);
  resolver_->Resolve<Blob*>(blob);
}

void ElementSnapshotReader::HandleFailed(const char* error) {
  MemberMutationScope mutation_scope{context_};
  ExceptionState exception_state;
  exception_state.ThrowException(context_->ctx(), ErrorType::InternalError, error);
  resolver_->Reject(exception_state);
}

ScriptPromise Element::toBlob(ExceptionState& exception_state) {
  return toBlob(1.0, exception_state);
}

ScriptPromise Element::toBlob(double device_pixel_ratio, ExceptionState& exception_state) {
  auto resolver = ScriptPromiseResolver::Create(GetExecutingContext());
  new ElementSnapshotReader(GetExecutingContext(), this, resolver, device_pixel_ratio);
  return resolver->Promise();
}

double Element::clientHeight() const {
  ExceptionState exception_state;
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(
      GetBindingProperty(binding_call_methods::kclientHeight, exception_state));
}

double Element::clientWidth() const {
  ExceptionState exception_state;
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(
      GetBindingProperty(binding_call_methods::kclientWidth, exception_state));
}

double Element::clientLeft() const {
  ExceptionState exception_state;
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(
      GetBindingProperty(binding_call_methods::kclientLeft, exception_state));
}

double Element::clientTop() const {
  ExceptionState exception_state;
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(
      GetBindingProperty(binding_call_methods::kclientTop, exception_state));
}

double Element::scrollTop() const {
  ExceptionState exception_state;
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(
      GetBindingProperty(binding_call_methods::kscrollTop, exception_state));
}

void Element::setScrollTop(double v, ExceptionState& exception_state) {
  SetBindingProperty(binding_call_methods::kscrollTop, NativeValueConverter<NativeTypeDouble>::ToNativeValue(v),
                     exception_state);
}

double Element::scrollLeft() const {
  ExceptionState exception_state;
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(
      GetBindingProperty(binding_call_methods::kclientTop, exception_state));
}

void Element::setScrollLeft(double v, ExceptionState& exception_state) {
  SetBindingProperty(binding_call_methods::kscrollLeft, NativeValueConverter<NativeTypeDouble>::ToNativeValue(v),
                     exception_state);
}

std::string Element::outerHTML() {
  std::string s = "<" + tagName().ToStdString();

  // Read attributes
  if (attributes_ != nullptr) {
    s += " " + attributes_->ToString();
  }
  if (cssom_wrapper_ != nullptr) {
    s += " style=\"" + cssom_wrapper_->ToString();
  }

  s += ">";

  std::string childHTML = innerHTML();
  s += childHTML;
  s += "</" + tagName().ToStdString() + ">";

  return s;
}

std::string Element::innerHTML() {
  std::string s;

  // If Element is TemplateElement, the innerHTML content is the content of documentFragment.
  Node* parent = To<Node>(this);

  if (auto* template_element = DynamicTo<HTMLTemplateElement>(this)) {
    parent = To<Node>(template_element->content());
  }

  if (parent->firstChild() == nullptr)
    return s;

  auto* child = parent->firstChild();
  while (child != nullptr) {
    if (auto* element = DynamicTo<Element>(child)) {
      s += element->outerHTML();
    } else if (auto* text = DynamicTo<Text>(child)) {
      s += text->data().ToStdString();
    }
    child = child->nextSibling();
  }

  return s;
}

void Element::setInnerHTML(const AtomicString& value, ExceptionState& exception_state) {
  auto html = value.ToStdString();
  if (auto* template_element = DynamicTo<HTMLTemplateElement>(this)) {
    HTMLParser::parseHTMLFragment(html.c_str(), html.size(), template_element->content());
  } else {
    HTMLParser::parseHTMLFragment(html.c_str(), html.size(), this);
  }
}

void Element::_notifyNodeRemoved(Node* node) {}

void Element::_notifyChildRemoved() {}

void Element::_notifyNodeInsert(Node* insertNode){

};

void Element::_notifyChildInsert() {}

void Element::_didModifyAttribute(const AtomicString& name, const AtomicString& oldId, const AtomicString& newId) {}

void Element::_beforeUpdateId(JSValue oldIdValue, JSValue newIdValue) {}

Node::NodeType Element::nodeType() const {
  return kElementNode;
}

bool Element::ChildTypeAllowed(NodeType type) const {
  switch (type) {
    case kElementNode:
    case kTextNode:
    case kCommentNode:
      return true;
    default:
      break;
  }
  return false;
}

}  // namespace kraken
