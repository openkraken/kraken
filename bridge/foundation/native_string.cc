/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "native_string.h"
#include <string>

namespace kraken {

NativeString* NativeString::clone() {
  auto* newNativeString = new NativeString();
  auto* newString = new uint16_t[length];

  memcpy(newString, string, length * sizeof(uint16_t));
  newNativeString->string = newString;
  newNativeString->length = length;
  return newNativeString;
}

void NativeString::free() {
  delete[] string;
}

}  // namespace kraken
