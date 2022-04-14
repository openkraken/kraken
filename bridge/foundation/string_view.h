/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_FOUNDATION_STRING_VIEW_H_
#define KRAKENBRIDGE_FOUNDATION_STRING_VIEW_H_

#include <string>
#include "ascii_types.h"
#include "native_string.h"

namespace kraken {

class StringView final {
 public:
  StringView() = delete;

  explicit StringView(const std::string& string);
  explicit StringView(const NativeString* string);
  explicit StringView(void* bytes, unsigned length, bool is_wide_char);

  bool Is8Bit() const { return is_8bit_; }

  bool IsLowerASCII() const {
    if (is_8bit_) {
      return kraken::IsLowerASCII(Characters8(), length());
    }
    return kraken::IsLowerASCII(Characters16(), length());
  }

  const char* Characters8() const { return static_cast<const char*>(bytes_); }

  const char16_t* Characters16() const { return static_cast<const char16_t*>(bytes_); }

  unsigned length() const { return length_; }

 private:
  const void* bytes_;
  unsigned length_;
  unsigned is_8bit_ : 1;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_FOUNDATION_STRING_VIEW_H_
