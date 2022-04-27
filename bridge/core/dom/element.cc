/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "binding_call_methods.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "core/fileapi/blob.h"
#include "core/html/html_template_element.h"
#include "foundation/native_value_converter.h"

namespace kraken {

Element::Element(const AtomicString& tag_name, Document* document, Node::ConstructionType construction_type)
    : ContainerNode(document, construction_type), tag_name_(tag_name) {}

ElementAttributes& Element::EnsureElementAttributes() {
  if (attributes_ == nullptr) {
    attributes_.Initialize(ElementAttributes::Create(this));
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

  GetExecutingContext()->uiCommandBuffer()->addCommand(eventTargetId(), static_cast<int32_t>(UICommand::setAttribute),
                                                       args_01.release(), args_02.release(), nullptr);
}

void Element::removeAttribute(const AtomicString& name, ExceptionState& exception_state) {
  EnsureElementAttributes().removeAttribute(name, exception_state);
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

void Element::scroll(ExceptionState& exception_state) {
  return scroll(0, 0, exception_state);
}

void Element::scroll(double x, double y, ExceptionState& exception_state) {
  GetExecutingContext()->dartMethodPtr()->flushUICommand();
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args, exception_state);
}

// TODO: add this support.
void Element::scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  exception_state.ThrowException(ctx(), ErrorType::InternalError,
                                 "scroll API which accept scrollToOptions not supported.");
}

void Element::scrollBy(ExceptionState& exception_state) {
  return scrollBy(0, 0, exception_state);
}

void Element::scrollBy(double x, double y, ExceptionState& exception_state) {
  GetExecutingContext()->dartMethodPtr()->flushUICommand();
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Element::scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  exception_state.ThrowException(ctx(), ErrorType::InternalError,
                                 "scrollBy API which accept scrollToOptions not supported.");
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

bool Element::HasEquivalentAttributes(const Element& other) const {
  return attributes_ != nullptr && other.attributes_ != nullptr && other.attributes_->IsEquivalent(*attributes_);
}

void Element::Trace(GCVisitor* visitor) const {
  visitor->Trace(attributes_);
  ContainerNode::Trace(visitor);
}

Node* Element::Clone(Document& factory, CloneChildrenFlag flag) const {
  return nullptr;
}

class ElementSnapshotReader {
 public:
  ElementSnapshotReader(ExecutingContext* context,
                        Element* element,
                        ScriptPromiseResolver* resolver,
                        double device_pixel_ratio)
      : context_(context), element_(element), resolver_(resolver), device_pixel_ratio_(device_pixel_ratio) {
    Start();
  };

  void Start();
  void HandleSnapshot(uint8_t* bytes, int32_t length);
  void HandleFailed(const char* error);

 private:
  ExecutingContext* context_;
  Element* element_;
  ScriptPromiseResolver* resolver_;
  double device_pixel_ratio_;
};

void ElementSnapshotReader::Start() {
  context_->dartMethodPtr()->flushUICommand();

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
  Blob* blob = Blob::Create(context_);
  blob->AppendBytes(bytes, length);
  resolver_->Resolve<Blob*>(blob);
}

void ElementSnapshotReader::HandleFailed(const char* error) {
  ExceptionState exception_state;
  exception_state.ThrowException(context_->ctx(), ErrorType::InternalError, error);
  resolver_->Reject(exception_state);
}

ScriptPromise Element::toBlob(ExceptionState& exception_state) {
  return toBlob(1.0, exception_state);
}

ScriptPromise Element::toBlob(double device_pixel_ratio, ExceptionState& exception_state) {
  auto* resolver = ScriptPromiseResolver::Create(GetExecutingContext());
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

std::string Element::outerHTML() const {
  //  std::string s = "<" + tag_name_.ToStdString();
  //
  //  // Read attributes
  //  std::string attributes = attributes_->ToString();
  //  // Read style
  //  std::string style = m_style->toString();
  //
  //  if (!attributes.empty()) {
  //    s += " " + attributes;
  //  }
  //  if (!style.empty()) {
  //    s += " style=\"" + style;
  //  }
  //
  //  s += ">";
  //
  //  std::string childHTML = innerHTML();
  //  s += childHTML;
  //  s += "</" + TagName().ToStdString() + ">";

  //  return s;
}

void Element::setOuterHTML(const AtomicString& value, ExceptionState& exception_state) {}

std::string Element::innerHTML() const {
  std::string s;

  // If Element is TemplateElement, the innerHTML content is the content of documentFragment.
  const Node* parent = To<Node>(this);

  //  if (auto* template_element = DynamicTo<HTMLTemplateElement>(this)) {
  //    parent = DynamicTo<Node>(template_element->content());
  //  }

  // TODO: add innerHTML support.
  //  // Children toString
  //  int32_t childLen = arrayGetLength(m_ctx, parent->childNodes);
  //
  //  if (childLen == 0)
  //    return s;
  //
  //  for (int i = 0; i < childLen; i++) {
  //    JSValue c = JS_GetPropertyUint32(m_ctx, parent->childNodes, i);
  //    auto* node = static_cast<NodeInstance*>(JS_GetOpaque(c, Node::classId(c)));
  //    if (node->nodeType == NodeType::ELEMENT_NODE) {
  //      s += reinterpret_cast<ElementInstance*>(node)->outerHTML();
  //    } else if (node->nodeType == NodeType::TEXT_NODE) {
  //      s += reinterpret_cast<TextNodeInstance*>(node)->toString();
  //    }
  //
  //    JS_FreeValue(m_ctx, c);
  //  }
  //  return s;
}

void Element::setInnerHTML(const AtomicString& value, ExceptionState& exception_state) {}

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
