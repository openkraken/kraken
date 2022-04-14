/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


#ifndef KRAKENBRIDGE_FOUNDATION_ASCII_TYPES_H_
#define KRAKENBRIDGE_FOUNDATION_ASCII_TYPES_H_

namespace kraken {

template <typename CharType>
inline bool IsASCII(CharType c) {
  return !(c & ~0x7F);
}

template <typename CharType>
inline bool IsASCIIAlpha(CharType c) {
  return (c | 0x20) >= 'a' && (c | 0x20) <= 'z';
}

template <typename CharType>
inline bool IsASCIIDigit(CharType c) {
  return c >= '0' && c <= '9';
}

template <typename CharType>
inline bool IsASCIIAlphanumeric(CharType c) {
  return IsASCIIDigit(c) || IsASCIIAlpha(c);
}

/*
 Statistics from a run of Apple's page load test for callers of IsASCIISpace:

 character          count
 ---------          -----
 non-spaces         689383
 20  space          294720
 0A  \n             89059
 09  \t             28320
 0D  \r             0
 0C  \f             0
 0B  \v             0
 */
template <typename CharType>
inline bool IsASCIISpace(CharType c) {
  return c <= ' ' && (c == ' ' || (c <= 0xD && c >= 0x9));
}

template <typename CharType>
inline bool IsASCIIUpper(CharType c) {
  return c >= 'A' && c <= 'Z';
}

template <typename CharacterType>
inline bool IsLowerASCII(const CharacterType* characters,
                         size_t length) {
  bool contains_upper_case = false;
  for (size_t i = 0; i < length; i++) {
    contains_upper_case |= IsASCIIUpper(characters[i]);
  }
  return !contains_upper_case;
}

}

#endif  // KRAKENBRIDGE_FOUNDATION_ASCII_TYPES_H_
