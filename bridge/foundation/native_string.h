/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NATIVE_STRING_H
#define KRAKENBRIDGE_NATIVE_STRING_H

#include <cinttypes>

namespace kraken {

struct NativeString {
  NativeString(const uint16_t* string, uint32_t length): string_(string), length_(length) {};
  ~NativeString();
  NativeString* clone();

  inline const uint16_t* string() const{return string_;}
  inline uint32_t length() const { return length_; }

 private:
  const uint16_t* string_;
  uint32_t length_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_NATIVE_STRING_H
