/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_FOUNDATION_NATIVE_VALUE_CONVERTER_H_
#define KRAKENBRIDGE_FOUNDATION_NATIVE_VALUE_CONVERTER_H_

#include "core/dom/binding_object.h"
#include "native_type.h"
#include "native_value.h"

namespace kraken {

// NativeValueConverter converts types back and forth from C++ types to NativeValue. The template
// parameter |T| determines what kind of type conversion to perform.
template <typename T, typename SFINAEHelper = void>
struct NativeValueConverter {
  using ImplType = T;
};

template <typename T>
struct NativeValueConverterBase {
  using ImplType = typename T::ImplType;
};

template <>
struct NativeValueConverter<NativeTypeNull> : public NativeValueConverterBase<NativeTypeNull> {
  static NativeValue ToNativeValue() { return Native_NewNull(); }

  static ImplType FromNativeValue(JSContext* ctx) { return ScriptValue::Empty(ctx); }
};

template <>
struct NativeValueConverter<NativeTypeString> : public NativeValueConverterBase<NativeTypeString> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewString(value); }

  static ImplType FromNativeValue(NativeValue value) { return static_cast<NativeString*>(value.u.ptr); }
};

template <>
struct NativeValueConverter<NativeTypeBool> : public NativeValueConverterBase<NativeTypeBool> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewBool(value); }

  static ImplType FromNativeValue(NativeValue value) { return value.u.int64 == 1; }
};

template <>
struct NativeValueConverter<NativeTypeInt64> : public NativeValueConverterBase<NativeTypeInt64> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewInt64(value); }

  static ImplType FromNativeValue(NativeValue value) { return value.u.int64; }
};

template <>
struct NativeValueConverter<NativeTypeDouble> : public NativeValueConverterBase<NativeTypeDouble> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewFloat64(value); }

  static ImplType FromNativeValue(NativeValue value) {
    double result;
    memcpy(&result, reinterpret_cast<void*>(&value.u.int64), sizeof(double));
    return result;
  }
};

template <>
struct NativeValueConverter<NativeTypeJSON> : public NativeValueConverterBase<NativeTypeJSON> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewJSON(value); }
  static ImplType FromNativeValue(JSContext* ctx, NativeValue value) {
    auto* str = static_cast<const char*>(value.u.ptr);
    return ScriptValue::CreateJsonObject(ctx, str, strlen(str));
  }
};

class NativeBoundingClientRect;
class BindingObject;
struct NativeBindingObject;
class NativeScreen;
class NativeCanvasRenderingContext2D;

template <>
struct NativeValueConverter<NativeTypePointer<NativeBoundingClientRect>>
    : public NativeValueConverterBase<NativeTypePointer<NativeBoundingClientRect>> {
  static NativeValue ToNativeValue(ImplType value) {
    return Native_NewPtr(JSPointerType::NativeBoundingClientRect, value);
  }
  static ImplType FromNativeValue(NativeValue value) { return static_cast<ImplType>(value.u.ptr); }
};

template <>
struct NativeValueConverter<NativeTypePointer<NativeBindingObject>>
    : public NativeValueConverterBase<NativeTypePointer<NativeBindingObject>> {
  static NativeValue ToNativeValue(ImplType value) { return Native_NewPtr(JSPointerType::BindingObject, value); }
  static ImplType FromNativeValue(NativeValue value) { return static_cast<ImplType>(value.u.ptr); }
};

template <>
struct NativeValueConverter<NativeTypePointer<NativeCanvasRenderingContext2D>>
    : public NativeValueConverterBase<NativeTypePointer<NativeCanvasRenderingContext2D>> {
  static NativeValue ToNativeValue(ImplType value) {
    return Native_NewPtr(JSPointerType::NativeCanvasRenderingContext2D, value);
  }
  static ImplType FromNativeValue(NativeValue value) { return static_cast<ImplType>(value.u.ptr); }
};

std::shared_ptr<QJSFunction> CreateSyncCallback(JSContext* ctx, int function_id);
std::shared_ptr<QJSFunction> CreateAsyncCallback(JSContext* ctx, int function_id);

template <>
struct NativeValueConverter<NativeTypeFunction> : public NativeValueConverterBase<NativeTypeFunction> {
  static NativeValue ToNativeValue(ImplType value) {
    // Not supported.
    assert(false);
  }

  static ImplType FromNativeValue(JSContext* ctx, NativeValue value) { return CreateSyncCallback(ctx, value.u.int64); };
};

template <>
struct NativeValueConverter<NativeTypeAsyncFunction> : public NativeValueConverterBase<NativeTypeAsyncFunction> {
  static NativeValue ToNativeValue(ImplType value) {
    // Not supported.
    assert(false);
  }

  static ImplType FromNativeValue(JSContext* ctx, NativeValue value) { return CreateAsyncCallback(ctx, value.u.int64); }
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_FOUNDATION_NATIVE_VALUE_CONVERTER_H_
