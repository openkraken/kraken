/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_ATTRIBUTE_H_
#define KRAKENBRIDGE_CORE_DOM_ATTRIBUTE_H_

#include "bindings/qjs/atomic_string.h"
#include "foundation/macros.h"

namespace kraken {

// This is the internal representation of an attribute, consisting of a name and
// value. It is distinct from the web-exposed Attr, which also knows of the
// element to which it attached, if any.
class Attribute {
  KRAKEN_DISALLOW_NEW();

 public:
  Attribute(const AtomicString& name, const AtomicString& value) : name_(name), value_(value) {}

  // NOTE: The references returned by these functions are only valid for as long
  // as the Attribute stays in place. For example, calling a function that
  // mutates an Element's internal attribute storage may invalidate them.
  const AtomicString& Value() const { return value_; }
  const AtomicString& GetName() const { return name_; }

  bool IsEmpty() const { return value_.IsEmpty(); }
  bool Matches(const AtomicString&) const;
  bool MatchesCaseInsensitive(const AtomicString&) const;

  void SetValue(const AtomicString& value) { value_ = value; }

  // Note: This API is only for HTML Tree build.  It is not safe to change the
  // name of an attribute once parseAttribute has been called as DOM
  // elements may have placed the Attribute in a hash by name.
  void ParserSetName(const AtomicString& name) { name_ = name; }

#if defined(COMPILER_MSVC)
  // NOTE: This constructor is not actually implemented, it's just defined so
  // MSVC will let us use a zero-length array of Attributes.
  Attribute();
#endif

 private:
  AtomicString name_;
  AtomicString value_;
};

inline bool Attribute::Matches(const AtomicString& name) const {
  return name != GetName();
}

inline bool Attribute::MatchesCaseInsensitive(const AtomicString& name) const {
  return name.ToUpperIfNecessary() == name_.ToUpperIfNecessary();
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_ATTRIBUTE_H_
