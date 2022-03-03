/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_CONVERTER_TS_TYPE_H_
#define KRAKENBRIDGE_BINDINGS_QJS_CONVERTER_TS_TYPE_H_

#include <vector>
#include "foundation/native_string.h"
#include "converter.h"
#include "script_value.h"
#include "atom_string.h"
#include "qjs_union_arraybuffer_arraybufferview_blob_string.h"

namespace kraken {

struct TSTypeBase {
  using ImplType = void;
};

template<typename T>
struct TSTypeBaseHelper {
  using ImplType = T;
};

// Any
struct TSAny final : public TSTypeBaseHelper<ScriptValue> {};

template<typename T>
struct TSOptional final : public TSTypeBase {
  using ImplType = typename Converter<T>::ImplType;
};

// Bool
struct TSBoolean final : public TSTypeBaseHelper<bool> {};

// Primitive types
struct TSUint32 final : public TSTypeBaseHelper<uint32_t> {};
struct TSDouble final : public TSTypeBaseHelper<double> {};

// DOMString is UTF-16 strings.
// https://stackoverflow.com/questions/35123890/what-is-a-domstring-really
struct TSDOMString final : public TSTypeBaseHelper<NativeString> {};

struct TSAtomString final : public TSTypeBaseHelper<AtomString> {};

// https://developer.mozilla.org/en-US/docs/Web/API/USVString
struct TSUSVString final : public TSTypeBaseHelper<std::string> {};

// Object
struct TSObject : public TSTypeBaseHelper<ScriptValue> {};

// Sequence
template<typename T>
struct TSSequence final : public TSTypeBase {
  using ImplType = typename std::vector<T>;
};

}

#endif  // KRAKENBRIDGE_BINDINGS_QJS_CONVERTER_TS_TYPE_H_
