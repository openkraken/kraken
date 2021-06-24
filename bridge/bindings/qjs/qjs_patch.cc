/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_patch.h"
#include <cstring>
#include <quickjs/cutils.h>

struct JSString {
  JSRefCountHeader header; /* must come first, 32-bit */
  uint32_t len : 31;
  uint8_t is_wide_char : 1; /* 0 = 8 bits, 1 = 16 bits characters */
  /* for JS_ATOM_TYPE_SYMBOL: hash = 0, atom_type = 3,
     for JS_ATOM_TYPE_PRIVATE: hash = 1, atom_type = 3
     XXX: could change encoding to have one more bit in hash */
  uint32_t hash : 30;
  uint8_t atom_type : 2; /* != 0 if atom, JS_ATOM_TYPE_x */
  uint32_t hash_next; /* atom_index for JS_ATOM_TYPE_SYMBOL */
#ifdef DUMP_LEAKS
  struct list_head link; /* string list */
#endif
  union {
    uint8_t str8[0]; /* 8 bit strings will get an extra null terminator */
    uint16_t str16[0];
  } u;
};

typedef struct JSString JSString;

uint16_t *JS_ToUnicode(JSContext *ctx, JSValueConst value, uint32_t *length) {
  if (JS_VALUE_GET_TAG(value) != JS_TAG_STRING) {
    value = JS_ToString(ctx, value);
    if (JS_IsException(value))
      return NULL;
  } else {
    value = JS_DupValue(ctx, value);
  }

  JSString *string = JS_VALUE_GET_STRING(value);

  if (!string->is_wide_char) {
    uint8_t *p = string->u.str8;
    uint32_t len = *length = string->len;
    auto *newBuf = (uint16_t*) malloc(sizeof(uint16_t) * len);
    for (size_t i = 0; i < len; i ++) {
      newBuf[i] = p[i];
      newBuf[i+1] = 0x00;
    }
    JS_FreeValue(ctx, value);
    return newBuf;
  } else {
    *length = string->len;
  }

  JS_FreeValue(ctx, value);

  return string->u.str16;
}

static JSString *js_alloc_string_rt(JSRuntime *rt, int max_len, int is_wide_char)
{
  JSString *str;
  str = static_cast<JSString*>(js_malloc_rt(rt, sizeof(JSString) + (max_len << is_wide_char) + 1 - is_wide_char));
  if (unlikely(!str))
    return NULL;
  str->header.ref_count = 1;
  str->is_wide_char = is_wide_char;
  str->len = max_len;
  str->atom_type = 0;
  str->hash = 0;          /* optional but costless */
  str->hash_next = 0;     /* optional */
#ifdef DUMP_LEAKS
  list_add_tail(&str->link, &rt->string_list);
#endif
  return str;
}

static JSString *js_alloc_string(JSRuntime *runtime, JSContext *ctx, int max_len, int is_wide_char)
{
  JSString *p;
  p = js_alloc_string_rt(runtime, max_len, is_wide_char);
  if (unlikely(!p)) {
    JS_ThrowOutOfMemory(ctx);
    return NULL;
  }
  return p;
}


JSValue JS_NewUnicodeString(JSRuntime *runtime, JSContext *ctx, const uint16_t *code, uint32_t length) {
  JSString *str;
  str = js_alloc_string(runtime, ctx, length, 1);
  if (!str)
    return JS_EXCEPTION;
  memcpy(str->u.str16, code, length * 2);
  return JS_MKPTR(JS_TAG_STRING, str);
}
