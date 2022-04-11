/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_ATTRIBUTE_COLLECTION_H_
#define KRAKENBRIDGE_CORE_DOM_ATTRIBUTE_COLLECTION_H_

#include <vector>
#include "attribute.h"
#include "foundation/macros.h"

namespace kraken {

const size_t kNotFound = UINT_MAX;

template <typename Container, typename ContainerMemberType = Container>
class AttributeCollectionGeneric {
  KRAKEN_STACK_ALLOCATED();

 public:
  using value_type = typename Container::value_type;
  using iterator = value_type*;

  AttributeCollectionGeneric(Container& attributes) : attributes_(attributes) {}

  value_type& operator[](unsigned index) const { return at(index); }
  value_type& at(unsigned index) const {
    CHECK_LT(index, size());
    return begin()[index];
  }

  value_type* data() { return attributes_.data(); }
  const value_type* data() const { return attributes_.data(); }

  iterator begin() const { return attributes_.data(); }
  iterator end() const { return begin() + size(); }

  unsigned size() const { return attributes_.size(); }
  bool IsEmpty() const { return !size(); }

  // Find() returns nullptr if the specified name is not found.
  iterator Find(const AtomicString& name) const;
  size_t FindIndex(const AtomicString& name) const;

 protected:
  ContainerMemberType attributes_;
};

class AttributeArray {
  KRAKEN_DISALLOW_NEW();

 public:
  using value_type = const Attribute;

  AttributeArray(const Attribute* array, unsigned size) : array_(array), size_(size) {}

  const Attribute* data() const { return array_; }
  unsigned size() const { return size_; }

 private:
  const Attribute* array_;
  unsigned size_;
};

class AttributeCollection : public AttributeCollectionGeneric<const AttributeArray> {
 public:
  AttributeCollection() : AttributeCollectionGeneric<const AttributeArray>(AttributeArray(nullptr, 0)) {}

  AttributeCollection(const Attribute* array, unsigned size)
      : AttributeCollectionGeneric<const AttributeArray>(AttributeArray(array, size)) {}
};

using AttributeVector = std::vector<Attribute>;
class MutableAttributeCollection : public AttributeCollectionGeneric<AttributeVector, AttributeVector&> {
 public:
  explicit MutableAttributeCollection(AttributeVector& attributes)
      : AttributeCollectionGeneric<AttributeVector, AttributeVector&>(attributes) {}

  // These functions do no error/duplicate checking.
  void Append(const AtomicString&, const AtomicString& value);
  void Remove(unsigned index);
};

inline void MutableAttributeCollection::Append(const AtomicString& name, const AtomicString& value) {
  attributes_.emplace_back(name, value);
}

inline void MutableAttributeCollection::Remove(unsigned index) {
  attributes_.erase(attributes_.begin() + index);
}

template <typename Container, typename ContainerMemberType>
inline typename AttributeCollectionGeneric<Container, ContainerMemberType>::iterator
AttributeCollectionGeneric<Container, ContainerMemberType>::Find(const AtomicString& name) const {
  size_t index = FindIndex(name);
  return index != kNotFound ? &at(index) : nullptr;
}

template <typename Container, typename ContainerMemberType>
inline size_t AttributeCollectionGeneric<Container, ContainerMemberType>::FindIndex(const AtomicString& name) const {
  iterator end = this->end();
  size_t index = 0;
  for (iterator it = begin(); it != end; ++it, ++index) {
    if (it->GetName().Matches(name))
      return index;
  }
  return kNotFound;
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_ATTRIBUTE_COLLECTION_H_
