/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "foundation/ascii_types.h"

namespace kraken {

Element* Document::createElement(const AtomicString& name, ExceptionState& exception_state) {
  if (!IsValidName(name)) {
    exception_state.ThrowException(ctx(), ErrorType::InternalError,
                                   "The tag name provided ('" + name.ToStdString() + "') is not a valid name.");
    return nullptr;
  }
}

Text* Document::createTextNode(const AtomicString& value) {
  return nullptr;
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

}  // namespace kraken
