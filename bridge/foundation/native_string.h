/*
* Copyright (C) 2021 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#ifndef KRAKENBRIDGE_NATIVE_STRING_H
#define KRAKENBRIDGE_NATIVE_STRING_H

#include <cinttypes>

namespace kraken {

struct NativeString {
  const uint16_t* string;
  uint32_t length;

  NativeString* clone();
  void free();
};

}

#endif  // KRAKENBRIDGE_NATIVE_STRING_H
