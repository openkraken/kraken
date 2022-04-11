/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "space_split_string.h"

namespace kraken {

// https://dom.spec.whatwg.org/#concept-ordered-set-parser
template <typename CharacterType>
inline void SpaceSplitString::Data::CreateVector(const AtomicString& source,
                                                 const CharacterType* characters,
                                                 unsigned length) {
  DCHECK_EQ(0u, vector_.size());
  HashSet<StringImpl*> token_set;
  unsigned start = 0;
  while (true) {
    while (start < length && IsHTMLSpace<CharacterType>(characters[start]))
      ++start;
    if (start >= length)
      break;
    unsigned end = start + 1;
    while (end < length && IsNotHTMLSpace<CharacterType>(characters[end]))
      ++end;

    if (start == 0 && end == length) {
      vector_.push_back(source);
      return;
    }

    AtomicString token(characters + start, end - start);
    // We skip adding |token| to |token_set| for the first token to reduce the
    // cost of HashSet<>::insert(), and adjust |token_set| when the second
    // unique token is found.
    if (vector_.size() == 0) {
      vector_.push_back(std::move(token));
    } else if (vector_.size() == 1) {
      if (vector_[0] != token) {
        token_set.insert(vector_[0].Impl());
        token_set.insert(token.Impl());
        vector_.push_back(std::move(token));
      }
    } else if (token_set.insert(token.Impl()).is_new_entry) {
      vector_.push_back(std::move(token));
    }

    start = end + 1;
  }
}

void SpaceSplitString::Data::CreateVector(const AtomicString& string) {
  unsigned length = string.length();

  if (string.Is8Bit()) {
    CreateVector(string, string.Characters8(), length);
    return;
  }

  CreateVector(string, string.Characters16(), length);
}

bool SpaceSplitString::Data::ContainsAll(Data& other) {
  if (this == &other)
    return true;

  wtf_size_t this_size = vector_.size();
  wtf_size_t other_size = other.vector_.size();
  for (wtf_size_t i = 0; i < other_size; ++i) {
    const AtomicString& name = other.vector_[i];
    wtf_size_t j;
    for (j = 0; j < this_size; ++j) {
      if (vector_[j] == name)
        break;
    }
    if (j == this_size)
      return false;
  }
  return true;
}

void SpaceSplitString::Data::Add(const AtomicString& string) {
  DCHECK(HasOneRef());
  DCHECK(!Contains(string));
  vector_.push_back(string);
}

void SpaceSplitString::Data::Remove(unsigned index) {
  DCHECK(HasOneRef());
  vector_.EraseAt(index);
}

void SpaceSplitString::Add(const AtomicString& string) {
  if (Contains(string))
    return;
  EnsureUnique();
  if (data_)
    data_->Add(string);
  else
    data_ = Data::Create(string);
}

bool SpaceSplitString::Remove(const AtomicString& string) {
  if (!data_)
    return false;
  unsigned i = 0;
  bool changed = false;
  while (i < data_->size()) {
    if ((*data_)[i] == string) {
      if (!changed)
        EnsureUnique();
      data_->Remove(i);
      changed = true;
      continue;
    }
    ++i;
  }
  return changed;
}

void SpaceSplitString::Remove(wtf_size_t index) {
  DCHECK_LT(index, size());
  EnsureUnique();
  data_->Remove(index);
}

void SpaceSplitString::ReplaceAt(wtf_size_t index, const AtomicString& token) {
  DCHECK_LT(index, data_->size());
  EnsureUnique();
  (*data_)[index] = token;
}

AtomicString SpaceSplitString::SerializeToString() const {
  size_t size = this->size();
  if (size == 0)
    return g_empty_atom;
  if (size == 1)
    return (*data_)[0];
  StringBuilder builder;
  builder.Append((*data_)[0]);
  for (wtf_size_t i = 1; i < size; ++i) {
    builder.Append(' ');
    builder.Append((*data_)[i]);
  }
  return builder.ToAtomicString();
}

void SpaceSplitString::Set(const AtomicString& input_string) {
  if (input_string.IsNull()) {
    Clear();
    return;
  }
  data_ = Data::Create(input_string);
}

SpaceSplitString::Data::~Data() {}

std::shared_ptr<SpaceSplitString::Data> SpaceSplitString::Data::Create(const AtomicString& string) {
  Data*& data = SharedDataMap().insert({string.Impl(), nullptr}).stored_value->value;
  if (!data) {
    data = new Data(string);
    return base::AdoptRef(data);
  }
  return data;
}

std::unique_ptr<SpaceSplitString::Data> SpaceSplitString::Data::CreateUnique(const Data& other) {
  return std::make_unique<SpaceSplitString::Data>(other);
}

SpaceSplitString::Data::Data(const AtomicString& string) : key_string_(string) {
  DCHECK(!string.IsNull());
  CreateVector(string);
}

SpaceSplitString::Data::Data(const SpaceSplitString::Data& other) : RefCounted<Data>(), vector_(other.vector_) {
  // Note that we don't copy key_string_ to indicate to the destructor that
  // there's nothing to be removed from the SharedDataMap().
}

SpaceSplitString::DataMap& SpaceSplitString::SharedDataMap() {
  thread_local static DataMap map;
  return map;
}

}  // namespace kraken
