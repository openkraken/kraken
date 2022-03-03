/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_CONVERTER_IMPL_H_
#define KRAKENBRIDGE_BINDINGS_QJS_CONVERTER_IMPL_H_

#include "converter.h"
#include "ts_type.h"

namespace kraken {

template <typename T>
struct Converter<TSOptional<T>, typename std::enable_if_t<std::is_pointer<typename Converter<T>::ImplType>>> : public ConverterBase<TSOptional<T>> {
  using ImplType = typename Converter<T>::ImplType;

  static ImplType FromValue(JSContext* ctx, JSValue value, ExceptionState* exception) {
    if (JS_IsUndefined(value)) {
      return nullptr;
    }
    return Converter<T>::FromValue(ctx, value);
  }
};

// Any
template <>
struct Converter<TSAny> : public ConverterBase<TSAny> {
  static ImplType FromValue(JSContext* ctx, JSValue value) {
    assert(!JS_IsException(value));
    return ScriptValue(ctx, value);
  }

  static JSValue ToValue(JSContext* ctx, const ScriptValue& value) { return value.toQuickJS(); }
};

// Boolean
template <>
struct Converter<TSBoolean> : public ConverterBase<TSBoolean> {
  static ImplType FromValue(JSContext* ctx, JSValue value) {
    assert(!JS_IsException(value));
    return JS_ToBool(ctx, value);
  };

  static JSValue ToValue(JSContext* ctx, bool value) { return JS_NewBool(ctx, value); };
};

// Uint32
template <>
struct Converter<TSUint32> : public ConverterBase<TSUint32> {
  static ImplType FromValue(JSContext* ctx, JSValue value) {
    assert(!JS_IsException(value));
    uint32_t v;
    JS_ToUint32(ctx, &v, value);
    return v;
  }

  static JSValue ToValue(JSContext* ctx, uint32_t v) { return JS_NewUint32(ctx, v); }
};

template <>
struct Converter<TSDouble> : public ConverterBase<TSDouble> {
  static ImplType FromValue(JSContext* ctx, JSValue value) {
    assert(!JS_IsException(value));
    double v;
    JS_ToFloat64(ctx, &v, value);
    return v;
  }

  static JSValue ToValue(JSContext* ctx, double v) { return JS_NewFloat64(ctx, v); }
};

template <>
struct Converter<TSDOMString> : public ConverterBase<TSDOMString> {
  static std::unique_ptr<NativeString> FromValue(JSContext* ctx, JSValue value) {
    assert(!JS_IsException(value));
    return jsValueToNativeString(ctx, value);
  }

  static JSValue ToValue(JSContext* ctx, uint16_t* bytes, size_t length) { return JS_NewUnicodeString(ctx, bytes, length); }
};

template <>
struct Converter<TSAtomString> : public ConverterBase<TSAtomString> {
  static AtomString FromValue(JSContext* ctx, JSValue value) {
    assert(!JS_IsException(value));
    JSAtom atom = JS_ValueToAtom(ctx, value);
    AtomString result = AtomString(ctx, atom);
    JS_FreeAtom(ctx, atom);
    return result;
  }

  static JSValue ToValue(JSContext* ctx, const AtomString& atom_string) { return atom_string.ToQuickJS(); }
};

template <typename T>
struct Converter<TSSequence<T>> : public ConverterBase<TSSequence<T>> {
  using ImplType = typename TSSequence<T>::ImplType;

  static ImplType FromValue(JSContext* ctx, JSValue value) {
    assert(!JS_IsException(value));
    assert(JS_IsArray(ctx, value));

    std::vector<T> v;
    uint32_t length = Converter<TSUint32>::FromValue(ctx, JS_GetPropertyStr(ctx, value, "length"));

    v.reserve(length);
    v.resize(length);

    for (uint32_t i = 0; i < length; i++) {
      auto&& item = Converter<T>::FromValue(ctx, JS_GetPropertyUint32(ctx, value, i));
    }

    return v;
  }
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_CONVERTER_IMPL_H_
