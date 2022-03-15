/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CONVERTER_H
#define KRAKENBRIDGE_CONVERTER_H

#include <cassert>

namespace kraken {

// The template parameter |T| determines what kind of type conversion to perform.
// It is not supposed to be used directly: there needs to be a specialization for each type which represents
// a JavaScript type that will be converted to a C++ representation.
// Its main goal is to provide a standard interface for converting JS types
// into C++ ones.
template <typename T, typename SFINAEHelper = void>
struct Converter {
  using ImplType = T;
};

template <typename T>
struct ConverterBase {
  using ImplType = typename T::ImplType;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CONVERTER_H
