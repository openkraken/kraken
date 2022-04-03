/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "native_string.h"
#include <string>

namespace kraken {

NativeString* NativeString::clone() {
  auto* newNativeString = new NativeString(nullptr, 0);
  auto* newString = new uint16_t[length_];

  memcpy(newString, string_, length_ * sizeof(uint16_t));
  newNativeString->string_ = newString;
  newNativeString->length_ = length_;
  return newNativeString;
}

NativeString::~NativeString() {
  delete[] string_;
}

}  // namespace kraken
