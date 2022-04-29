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

namespace {

AtomicString::StringKind GetStringKind(const std::string& string) {
  AtomicString::StringKind predictKind =
      std::islower(string[0]) ? AtomicString::StringKind::kIsLowerCase : AtomicString::StringKind::kIsUpperCase;
  for (char i : string) {
    if (predictKind == AtomicString::StringKind::kIsUpperCase && !std::isupper(i)) {
      return AtomicString::StringKind::kIsMixed;
    } else if (predictKind == AtomicString::StringKind::kIsLowerCase && !std::islower(i)) {
      return AtomicString::StringKind::kIsMixed;
    }
  }
  return predictKind;
}

AtomicString::StringKind GetStringKind(JSValue stringValue) {
  JSString* p = JS_VALUE_GET_STRING(stringValue);

  if (p->is_wide_char) {
    return AtomicString::StringKind::kIsMixed;
  }

  return GetStringKind(reinterpret_cast<const char*>(p->u.str8));
}

}  // namespace

AtomicString::AtomicString(JSContext* ctx, const std::string& string)
    : runtime_(JS_GetRuntime(ctx)),
      ctx_(ctx),
      atom_(JS_NewAtom(ctx, string.c_str())),
      kind_(GetStringKind(string)),
      length_(string.size()) {}

AtomicString::AtomicString(JSContext* ctx, JSValue value)
    : runtime_(JS_GetRuntime(ctx)), ctx_(ctx), atom_(JS_ValueToAtom(ctx, value)) {
  if (JS_IsString(value)) {
    kind_ = GetStringKind(value);
    length_ = JS_VALUE_GET_STRING(value)->len;
  }
}

AtomicString::AtomicString(JSContext* ctx, JSAtom atom)
    : runtime_(JS_GetRuntime(ctx)), ctx_(ctx), atom_(JS_DupAtom(ctx, atom)) {
  JSValue string = JS_AtomToValue(ctx, atom);
  kind_ = GetStringKind(string);
  length_ = JS_VALUE_GET_STRING(string)->len;
  JS_FreeValue(ctx, string);
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

StringView AtomicString::ToStringView() const {
  JSValue stringValue = JS_AtomToValue(ctx_, atom_);
  JSString* string = JS_VALUE_GET_STRING(stringValue);
  assert(string->header.ref_count > 1);
  JS_FreeValue(ctx_, stringValue);
  return StringView(string->u.str8, string->len, string->is_wide_char);
}

AtomicString::AtomicString(const AtomicString& value) {
  if (&value != this) {
    atom_ = JS_DupAtom(value.ctx_, value.atom_);
  }
  ctx_ = value.ctx_;
  runtime_ = value.runtime_;
  length_ = value.length_;
  kind_ = value.kind_;
}

AtomicString& AtomicString::operator=(const AtomicString& other) {
  if (&other != this) {
    atom_ = JS_DupAtom(other.ctx_, other.atom_);
  }
  runtime_ = other.runtime_;
  ctx_ = other.ctx_;
  length_ = other.length_;
  kind_ = other.kind_;
  return *this;
}

AtomicString::AtomicString(AtomicString&& value) noexcept {
  if (&value != this) {
    atom_ = JS_DupAtom(value.ctx_, value.atom_);
  }
  ctx_ = value.ctx_;
  runtime_ = value.runtime_;
  length_ = value.length_;
  kind_ = value.kind_;
}

AtomicString& AtomicString::operator=(AtomicString&& value) noexcept {
  if (&value != this) {
    atom_ = JS_DupAtom(value.ctx_, value.atom_);
  }
  ctx_ = value.ctx_;
  runtime_ = value.runtime_;
  length_ = value.length_;
  kind_ = value.kind_;
  return *this;
}

AtomicString AtomicString::ToUpperIfNecessary() const {
  if (kind_ == StringKind::kIsUpperCase) {
    return *this;
  }
  if (atom_upper_ != JS_ATOM_NULL)
    return *this;
  AtomicString upperString = ToUpperSlow();
  atom_upper_ = upperString.atom_;
  return upperString;
}

const AtomicString AtomicString::ToUpperSlow() const {
  const char* cptr = JS_AtomToCString(ctx_, atom_);
  std::string str = std::string(cptr);
  std::transform(str.begin(), str.end(), str.begin(), toupper);
  JS_FreeCString(ctx_, cptr);
  return AtomicString(ctx_, str);
}

const AtomicString AtomicString::ToLowerIfNecessary() const {
  if (kind_ == StringKind::kIsLowerCase) {
    return *this;
  }
  if (atom_lower_ != JS_ATOM_NULL)
    return *this;
  AtomicString lowerString = ToLowerSlow();
  atom_lower_ = lowerString.atom_;
  return lowerString;
}

const AtomicString AtomicString::ToLowerSlow() const {
  const char* cptr = JS_AtomToCString(ctx_, atom_);
  std::string str = std::string(cptr);
  std::transform(str.begin(), str.end(), str.begin(), tolower);
  JS_FreeCString(ctx_, cptr);
  return AtomicString(ctx_, str);
}

}  // namespace kraken
