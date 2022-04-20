/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_LEGACY_ELEMENT_ATTRIBUTES_H_
#define KRAKENBRIDGE_CORE_DOM_LEGACY_ELEMENT_ATTRIBUTES_H_

#include <unordered_map>
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/script_wrappable.h"
#include "space_split_string.h"

namespace kraken {

class ExceptionState;
class Element;

// TODO: refactor for better W3C standard support and higher performance.
class ElementAttributes : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = ElementAttributes*;

  static ElementAttributes* Create(Element* element) { return MakeGarbageCollected<ElementAttributes>(element); }
  static ElementAttributes* Create(ExecutingContext* context, ExceptionState& exception_state) {
    return MakeGarbageCollected<ElementAttributes>(context);
  }

  ElementAttributes(Element) = delete;
  ElementAttributes(Element* element);
  ElementAttributes(ExecutingContext* context);

  AtomicString GetAttribute(const AtomicString& name);
  bool setAttribute(const AtomicString& name, const AtomicString& value, ExceptionState& exception_state);
  bool hasAttribute(const AtomicString& name, ExceptionState& exception_state);
  void removeAttribute(const AtomicString& name, ExceptionState& exception_state);
  void CopyWith(ElementAttributes* attributes);
  std::shared_ptr<SpaceSplitString> ClassName();
  std::string ToString();

  bool IsEquivalent(const ElementAttributes& other) const;

  void Trace(GCVisitor* visitor) const override;

 private:
  std::unordered_map<AtomicString, AtomicString, AtomicString::KeyHasher> attributes_;
  std::shared_ptr<SpaceSplitString> class_name_{std::make_shared<SpaceSplitString>("")};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_LEGACY_ELEMENT_ATTRIBUTES_H_
