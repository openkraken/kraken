/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "native_string.h"
#include <string>

namespace kraken {

NativeString::NativeString(const uint16_t* string, uint32_t length) : length_(length) {
  string_ = static_cast<const uint16_t*>(malloc(length * sizeof(uint16_t)));
  memcpy((void*)string_, string, length * sizeof(uint16_t));
}

NativeString::NativeString(const NativeString* source) : length_(source->length()) {
  string_ = static_cast<const uint16_t*>(malloc(source->length() * sizeof(uint16_t)));
  memcpy((void*)string_, source->string_, source->length() * sizeof(u_int16_t));
}

NativeString::~NativeString() {
  delete[] string_;
}

}  // namespace kraken
