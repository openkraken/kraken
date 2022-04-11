/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_LEGACY_ELEMENT_ATTRIBUTES_H_
#define KRAKENBRIDGE_CORE_DOM_LEGACY_ELEMENT_ATTRIBUTES_H_

#include <unordered_map>
#include "space_split_string.h"
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/script_wrappable.h"

namespace kraken {

class ExceptionState;
class Element;

// TODO: refactor for better W3C standard support and higher performance.
class ElementAttributes : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();
 public:

  ElementAttributes(Element) = delete;
  ElementAttributes(Element* element);
  FORCE_INLINE const char* GetHumanReadableName() const override { return "ElementAttributes"; }
  void Trace(GCVisitor* visitor) const override;

  AtomicString GetAttribute(const AtomicString& name);
  bool SetAttribute(const AtomicString& name, const AtomicString& value, ExceptionState& exception_state);
  bool HasAttribute(const AtomicString& name);
  void RemoveAttribute(const AtomicString& name);
  void CopyWith(ElementAttributes* attributes);
  std::shared_ptr<SpaceSplitString> ClassName();
  std::string ToString();

 private:
  std::unordered_map<AtomicString, AtomicString, AtomicString::KeyHasher> attributes_;
  std::shared_ptr<SpaceSplitString> class_name_{std::make_shared<SpaceSplitString>("")};
};


}

#endif  // KRAKENBRIDGE_CORE_DOM_LEGACY_ELEMENT_ATTRIBUTES_H_
