/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "atomic_string.h"
#include "built_in_string.h"

namespace kraken {

AtomicString AtomicString::Empty(JSContext* ctx) {
  AtomicString tmp = built_in_string::kempty_string;
  return tmp;
}

AtomicString AtomicString::From(JSContext* ctx, NativeString* native_string) {
  JSValue str = JS_NewUnicodeString(ctx, native_string->string(), native_string->length());
  auto result = AtomicString(ctx, str);
  JS_FreeValue(ctx, str);
  return result;
}

bool AtomicString::IsNull() const {
  return atom_ == JS_ATOM_NULL;
}

bool AtomicString::IsEmpty() const {
  return *this == built_in_string::kempty_string;
}

std::string AtomicString::ToStdString() const {
  const char* buf = JS_AtomToCString(ctx_, atom_);
  std::string result = std::string(buf);
  JS_FreeCString(ctx_, buf);
  return result;
}

std::unique_ptr<NativeString> AtomicString::ToNativeString() const {
  JSValue stringValue = JS_AtomToValue(ctx_, atom_);
  uint32_t length;
  uint16_t* bytes = JS_ToUnicode(ctx_, stringValue, &length);
  JS_FreeValue(ctx_, stringValue);
  return std::make_unique<NativeString>(bytes, length);
}

AtomicString::AtomicString(const AtomicString& value) {
  if (&value != this) {
    atom_ = JS_DupAtom(value.ctx_, value.atom_);
  }
  ctx_ = value.ctx_;
  runtime_ = value.runtime_;
}

AtomicString& AtomicString::operator=(const AtomicString& other) {
  if (&other != this) {
    atom_ = JS_DupAtom(other.ctx_, other.atom_);
  }
  runtime_ = other.runtime_;
  ctx_ = other.ctx_;
  return *this;
}

AtomicString::AtomicString(AtomicString&& value) noexcept {
  if (&value != this) {
    atom_ = JS_DupAtom(value.ctx_, value.atom_);
  }
  ctx_ = value.ctx_;
  runtime_ = value.runtime_;
}

AtomicString& AtomicString::operator=(AtomicString&& value) noexcept {
  if (&value != this) {
    atom_ = JS_DupAtom(value.ctx_, value.atom_);
  }
  ctx_ = value.ctx_;
  runtime_ = value.runtime_;
  return *this;
}
}  // namespace kraken
