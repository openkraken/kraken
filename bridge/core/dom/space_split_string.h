/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_SPACE_SPLIT_STRING_H_
#define KRAKENBRIDGE_CORE_DOM_SPACE_SPLIT_STRING_H_

#include <memory>
#include <vector>
#include <unordered_map>
#include "bindings/qjs/atomic_string.h"

namespace kraken {

class SpaceSplitString {
 public:
  SpaceSplitString() = default;
  explicit SpaceSplitString(const AtomicString& string) { Set(string); }

  bool operator!=(const SpaceSplitString& other) const { return data_ != other.data_; }

  void Set(const AtomicString&);
  void Clear() { data_ = nullptr; }

  bool Contains(const AtomicString& string) const { return data_ && data_->Contains(string); }
  bool ContainsAll(const SpaceSplitString& names) const {
    return !names.data_ || (data_ && data_->ContainsAll(*names.data_));
  }
  void Add(const AtomicString&);
  bool Remove(const AtomicString&);
  void Remove(size_t index);
  void ReplaceAt(size_t index, const AtomicString&);

  // https://dom.spec.whatwg.org/#concept-ordered-set-serializer
  // The ordered set serializer takes a set and returns the concatenation of the
  // strings in set, separated from each other by U+0020, if set is non-empty,
  // and the empty string otherwise.
  AtomicString SerializeToString() const;

  size_t size() const { return data_ ? data_->size() : 0; }
  bool IsNull() const { return !data_; }
  const AtomicString& operator[](size_t i) const { return (*data_)[i]; }

 private:
  class Data {
   public:
    static std::shared_ptr<Data> Create(const AtomicString&);
    static std::unique_ptr<Data> CreateUnique(const Data&);

    ~Data();

    bool Contains(const AtomicString& string) const { return std::find(vector_.begin(), vector_.end(), string) != vector_.end(); }

    bool ContainsAll(Data&);

    void Add(const AtomicString&);
    void Remove(unsigned index);

    bool IsUnique() const { return key_string_.IsNull(); }
    size_t size() const { return vector_.size(); }
    const AtomicString& operator[](size_t i) const { return vector_[i]; }
    AtomicString& operator[](size_t i) { return vector_[i]; }

    explicit Data(const Data&);
   private:
    explicit Data(const AtomicString&);

    void CreateVector(const AtomicString&);
    template <typename CharacterType>
    inline void CreateVector(const AtomicString&, const CharacterType*, unsigned);

    AtomicString key_string_;
    std::vector<AtomicString> vector_;
  };

  // We can use a non-ref-counted StringImpl* as the key because the associated
  // Data object will keep it alive via the key_string_ member.
   typedef std::unordered_map<JSAtom, Data*> DataMap;
   static DataMap& SharedDataMap();

  void EnsureUnique() {
    if (data_ && !data_->IsUnique())
      data_ = Data::CreateUnique(*data_);
  }

  std::shared_ptr<Data> data_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_DOM_SPACE_SPLIT_STRING_H_
