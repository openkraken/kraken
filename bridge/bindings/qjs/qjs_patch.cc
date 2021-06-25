/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_patch.h"
#include <cstring>
#include <quickjs/cutils.h>
#include <quickjs/list.h>

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

typedef enum {
  JS_GC_PHASE_NONE,
  JS_GC_PHASE_DECREF,
  JS_GC_PHASE_REMOVE_CYCLES,
} JSGCPhaseEnum;

typedef enum {
  JS_GC_OBJ_TYPE_JS_OBJECT,
  JS_GC_OBJ_TYPE_FUNCTION_BYTECODE,
  JS_GC_OBJ_TYPE_SHAPE,
  JS_GC_OBJ_TYPE_VAR_REF,
  JS_GC_OBJ_TYPE_ASYNC_FUNCTION,
  JS_GC_OBJ_TYPE_JS_CONTEXT,
} JSGCObjectTypeEnum;

struct JSGCObjectHeader {
  int ref_count; /* must come first, 32-bit */
  JSGCObjectTypeEnum gc_obj_type : 4;
  uint8_t mark : 4; /* used by the GC */
  uint8_t dummy1; /* not used by the GC */
  uint16_t dummy2; /* not used by the GC */
  struct list_head link;
};

typedef struct JSShapeProperty {
  uint32_t hash_next : 26; /* 0 if last in list */
  uint32_t flags : 6;   /* JS_PROP_XXX */
  JSAtom atom; /* JS_ATOM_NULL = free property entry */
} JSShapeProperty;

struct JSShape {
  /* hash table of size hash_mask + 1 before the start of the
     structure (see prop_hash_end()). */
  JSGCObjectHeader header;
  /* true if the shape is inserted in the shape hash table. If not,
     JSShape.hash is not valid */
  uint8_t is_hashed;
  /* If true, the shape may have small array index properties 'n' with 0
     <= n <= 2^31-1. If false, the shape is guaranteed not to have
     small array index properties */
  uint8_t has_small_array_index;
  uint32_t hash; /* current hash value */
  uint32_t prop_hash_mask;
  int prop_size; /* allocated properties */
  int prop_count; /* include deleted properties */
  int deleted_prop_count;
  JSShape *shape_hash_next; /* in JSRuntime.shape_hash[h] list */
  JSObject *proto;
  JSShapeProperty prop[0]; /* prop_size elements */
};

struct JSRuntime {
  JSMallocFunctions mf;
  JSMallocState malloc_state;
  const char *rt_info;

  int atom_hash_size; /* power of two */
  int atom_count;
  int atom_size;
  int atom_count_resize; /* resize hash table at this count */
  uint32_t *atom_hash;
  JSString **atom_array;
  int atom_free_index; /* 0 = none */

  int class_count;    /* size of class_array */
  JSClass *class_array;

  struct list_head context_list; /* list of JSContext.link */
  /* list of JSGCObjectHeader.link. List of allocated GC objects (used
     by the garbage collector) */
  struct list_head gc_obj_list;
  /* list of JSGCObjectHeader.link. Used during JS_FreeValueRT() */
  struct list_head gc_zero_ref_count_list;
  struct list_head tmp_obj_list; /* used during GC */
  JSGCPhaseEnum gc_phase : 8;
  size_t malloc_gc_threshold;
#ifdef DUMP_LEAKS
  struct list_head string_list; /* list of JSString.link */
#endif
  /* stack limitation */
  const uint8_t *stack_top;
  size_t stack_size; /* in bytes */

  JSValue current_exception;
  /* true if inside an out of memory error, to avoid recursing */
  BOOL in_out_of_memory : 8;

  struct JSStackFrame *current_stack_frame;

  JSInterruptHandler *interrupt_handler;
  void *interrupt_opaque;

  JSHostPromiseRejectionTracker *host_promise_rejection_tracker;
  void *host_promise_rejection_tracker_opaque;

  struct list_head job_list; /* list of JSJobEntry.link */

  JSModuleNormalizeFunc *module_normalize_func;
  JSModuleLoaderFunc *module_loader_func;
  void *module_loader_opaque;

  BOOL can_block : 8; /* TRUE if Atomics.wait can block */
  /* used to allocate, free and clone SharedArrayBuffers */
  JSSharedArrayBufferFunctions sab_funcs;

  /* Shape hash table */
  int shape_hash_bits;
  int shape_hash_size;
  int shape_hash_count; /* number of hashed shapes */
  JSShape **shape_hash;
#ifdef CONFIG_BIGNUM
  bf_context_t bf_ctx;
    JSNumericOperations bigint_ops;
    JSNumericOperations bigfloat_ops;
    JSNumericOperations bigdecimal_ops;
    uint32_t operator_count;
#endif
  void *user_opaque;
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
