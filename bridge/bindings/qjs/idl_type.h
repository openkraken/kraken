/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_CONVERTER_TS_TYPE_H_
#define KRAKENBRIDGE_BINDINGS_QJS_CONVERTER_TS_TYPE_H_

#include <vector>
#include "converter.h"

namespace kraken {

struct IDLTypeBase {
  using ImplType = void;
};

template<typename T>
struct IDLTypeBaseHelper {
  using ImplType = T;
};

class ScriptValue;
// Any
struct IDLAny final : public IDLTypeBaseHelper<ScriptValue> {};

template<typename T>
struct IDLOptional final : public IDLTypeBase {
  using ImplType = typename Converter<T>::ImplType;
};

// Bool
struct IDLBoolean final : public IDLTypeBaseHelper<bool> {};

// Primitive types
struct IDLUint32 final : public IDLTypeBaseHelper<uint32_t> {};
struct IDLDouble final : public IDLTypeBaseHelper<double> {};

class NativeString;
// DOMString is UTF-16 strings.
// https://stackoverflow.com/questions/35123890/what-is-a-domstring-really
struct IDLDOMString final : public IDLTypeBaseHelper<std::unique_ptr<NativeString>> {};

class AtomString;
struct IDLAtomString final : public IDLTypeBaseHelper<AtomString> {};

// https://developer.mozilla.org/en-US/docs/Web/API/USVString
struct IDLUSVString final : public IDLTypeBaseHelper<std::string> {};

// Object
struct IDLObject : public IDLTypeBaseHelper<ScriptValue> {};

class QJSFunction;
// Function callback
struct IDLCallback : public IDLTypeBaseHelper<std::shared_ptr<QJSFunction>> {
  using ImplType = typename Converter<std::shared_ptr<QJSFunction>>::ImplType;
};

// Sequence
template<typename T>
struct IDLSequence final : public IDLTypeBase {
  using ImplType = typename std::vector<T>;
};

}

#endif  // KRAKENBRIDGE_BINDINGS_QJS_CONVERTER_TS_TYPE_H_
