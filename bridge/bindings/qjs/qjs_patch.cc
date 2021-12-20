/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_patch.h"
#include <quickjs/cutils.h>
#include <quickjs/list.h>
#include <cstring>

typedef enum {
  JS_GC_PHASE_NONE,
  JS_GC_PHASE_DECREF,
  JS_GC_PHASE_REMOVE_CYCLES,
} JSGCPhaseEnum;

typedef struct JSProxyData {
  JSValue target;
  JSValue handler;
  uint8_t is_func;
  uint8_t is_revoked;
} JSProxyData;

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
  uint8_t dummy1;   /* not used by the GC */
  uint16_t dummy2;  /* not used by the GC */
  struct list_head link;
};

typedef struct JSShapeProperty {
  uint32_t hash_next : 26; /* 0 if last in list */
  uint32_t flags : 6;      /* JS_PROP_XXX */
  JSAtom atom;             /* JS_ATOM_NULL = free property entry */
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
  int prop_size;  /* allocated properties */
  int prop_count; /* include deleted properties */
  int deleted_prop_count;
  JSShape* shape_hash_next; /* in JSRuntime.shape_hash[h] list */
  JSObject* proto;
  JSShapeProperty prop[0]; /* prop_size elements */
};

struct JSClass {
  uint32_t class_id; /* 0 means free entry */
  JSAtom class_name;
  JSClassFinalizer* finalizer;
  JSClassGCMark* gc_mark;
  JSClassCall* call;
  /* pointers for exotic behavior, can be NULL if none are present */
  const JSClassExoticMethods* exotic;
};

struct JSRuntime {
  JSMallocFunctions mf;
  JSMallocState malloc_state;
  const char* rt_info;

  int atom_hash_size; /* power of two */
  int atom_count;
  int atom_size;
  int atom_count_resize; /* resize hash table at this count */
  uint32_t* atom_hash;
  JSString** atom_array;
  int atom_free_index; /* 0 = none */

  int class_count; /* size of class_array */
  JSClass* class_array;

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
  const uint8_t* stack_top;
  size_t stack_size; /* in bytes */

  JSValue current_exception;
  /* true if inside an out of memory error, to avoid recursing */
  BOOL in_out_of_memory : 8;

  struct JSStackFrame* current_stack_frame;

  JSInterruptHandler* interrupt_handler;
  void* interrupt_opaque;

  JSHostPromiseRejectionTracker* host_promise_rejection_tracker;
  void* host_promise_rejection_tracker_opaque;

  struct list_head job_list; /* list of JSJobEntry.link */

  JSModuleNormalizeFunc* module_normalize_func;
  JSModuleLoaderFunc* module_loader_func;
  void* module_loader_opaque;

  BOOL can_block : 8; /* TRUE if Atomics.wait can block */
  /* used to allocate, free and clone SharedArrayBuffers */
  JSSharedArrayBufferFunctions sab_funcs;

  /* Shape hash table */
  int shape_hash_bits;
  int shape_hash_size;
  int shape_hash_count; /* number of hashed shapes */
  JSShape** shape_hash;
#ifdef CONFIG_BIGNUM
  bf_context_t bf_ctx;
  JSNumericOperations bigint_ops;
  JSNumericOperations bigfloat_ops;
  JSNumericOperations bigdecimal_ops;
  uint32_t operator_count;
#endif
  void* user_opaque;
};

typedef struct JSRegExp {
  JSString* pattern;
  JSString* bytecode; /* also contains the flags */
} JSRegExp;

typedef struct JSString JSString;

struct JSObject {
  union {
    JSGCObjectHeader header;
    struct {
      int __gc_ref_count; /* corresponds to header.ref_count */
      uint8_t __gc_mark;  /* corresponds to header.mark/gc_obj_type */

      uint8_t extensible : 1;
      uint8_t free_mark : 1;            /* only used when freeing objects with cycles */
      uint8_t is_exotic : 1;            /* TRUE if object has exotic property handlers */
      uint8_t fast_array : 1;           /* TRUE if u.array is used for get/put (for JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS and typed arrays) */
      uint8_t is_constructor : 1;       /* TRUE if object is a constructor function */
      uint8_t is_uncatchable_error : 1; /* if TRUE, error is not catchable */
      uint8_t tmp_mark : 1;             /* used in JS_WriteObjectRec() */
      uint8_t is_HTMLDDA : 1;           /* specific annex B IsHtmlDDA behavior */
      uint16_t class_id;                /* see JS_CLASS_x */
    };
  };
  /* byte offsets: 16/24 */
  JSShape* shape; /* prototype and property names + flag */
  void* prop;     /* array of properties */
  /* byte offsets: 24/40 */
  struct JSMapRecord* first_weak_ref; /* XXX: use a bit and an external hash table? */
  /* byte offsets: 28/48 */
  union {
    void* opaque;
    struct JSBoundFunction* bound_function;               /* JS_CLASS_BOUND_FUNCTION */
    struct JSCFunctionDataRecord* c_function_data_record; /* JS_CLASS_C_FUNCTION_DATA */
    struct JSForInIterator* for_in_iterator;              /* JS_CLASS_FOR_IN_ITERATOR */
    struct JSArrayBuffer* array_buffer;                   /* JS_CLASS_ARRAY_BUFFER, JS_CLASS_SHARED_ARRAY_BUFFER */
    struct JSTypedArray* typed_array;                     /* JS_CLASS_UINT8C_ARRAY..JS_CLASS_DATAVIEW */
#ifdef CONFIG_BIGNUM
    struct JSFloatEnv* float_env;           /* JS_CLASS_FLOAT_ENV */
    struct JSOperatorSetData* operator_set; /* JS_CLASS_OPERATOR_SET */
#endif
    struct JSMapState* map_state;                                      /* JS_CLASS_MAP..JS_CLASS_WEAKSET */
    struct JSMapIteratorData* map_iterator_data;                       /* JS_CLASS_MAP_ITERATOR, JS_CLASS_SET_ITERATOR */
    struct JSArrayIteratorData* array_iterator_data;                   /* JS_CLASS_ARRAY_ITERATOR, JS_CLASS_STRING_ITERATOR */
    struct JSRegExpStringIteratorData* regexp_string_iterator_data;    /* JS_CLASS_REGEXP_STRING_ITERATOR */
    struct JSGeneratorData* generator_data;                            /* JS_CLASS_GENERATOR */
    struct JSProxyData* proxy_data;                                    /* JS_CLASS_PROXY */
    struct JSPromiseData* promise_data;                                /* JS_CLASS_PROMISE */
    struct JSPromiseFunctionData* promise_function_data;               /* JS_CLASS_PROMISE_RESOLVE_FUNCTION, JS_CLASS_PROMISE_REJECT_FUNCTION */
    struct JSAsyncFunctionData* async_function_data;                   /* JS_CLASS_ASYNC_FUNCTION_RESOLVE, JS_CLASS_ASYNC_FUNCTION_REJECT */
    struct JSAsyncFromSyncIteratorData* async_from_sync_iterator_data; /* JS_CLASS_ASYNC_FROM_SYNC_ITERATOR */
    struct JSAsyncGeneratorData* async_generator_data;                 /* JS_CLASS_ASYNC_GENERATOR */
    struct {                                                           /* JS_CLASS_BYTECODE_FUNCTION: 12/24 bytes */
      /* also used by JS_CLASS_GENERATOR_FUNCTION, JS_CLASS_ASYNC_FUNCTION and JS_CLASS_ASYNC_GENERATOR_FUNCTION */
      struct JSFunctionBytecode* function_bytecode;
      void** var_refs;
      JSObject* home_object; /* for 'super' access */
    } func;
    struct { /* JS_CLASS_C_FUNCTION: 12/20 bytes */
      JSContext* realm;
      JSCFunctionType c_function;
      uint8_t length;
      uint8_t cproto;
      int16_t magic;
    } cfunc;
    /* array part for fast arrays and typed arrays */
    struct { /* JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS, JS_CLASS_UINT8C_ARRAY..JS_CLASS_FLOAT64_ARRAY */
      union {
        uint32_t size;                    /* JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS */
        struct JSTypedArray* typed_array; /* JS_CLASS_UINT8C_ARRAY..JS_CLASS_FLOAT64_ARRAY */
      } u1;
      union {
        JSValue* values;      /* JS_CLASS_ARRAY, JS_CLASS_ARGUMENTS */
        void* ptr;            /* JS_CLASS_UINT8C_ARRAY..JS_CLASS_FLOAT64_ARRAY */
        int8_t* int8_ptr;     /* JS_CLASS_INT8_ARRAY */
        uint8_t* uint8_ptr;   /* JS_CLASS_UINT8_ARRAY, JS_CLASS_UINT8C_ARRAY */
        int16_t* int16_ptr;   /* JS_CLASS_INT16_ARRAY */
        uint16_t* uint16_ptr; /* JS_CLASS_UINT16_ARRAY */
        int32_t* int32_ptr;   /* JS_CLASS_INT32_ARRAY */
        uint32_t* uint32_ptr; /* JS_CLASS_UINT32_ARRAY */
        int64_t* int64_ptr;   /* JS_CLASS_INT64_ARRAY */
        uint64_t* uint64_ptr; /* JS_CLASS_UINT64_ARRAY */
        float* float_ptr;     /* JS_CLASS_FLOAT32_ARRAY */
        double* double_ptr;   /* JS_CLASS_FLOAT64_ARRAY */
      } u;
      uint32_t count;    /* <= 2^31-1. 0 for a detached typed array */
    } array;             /* 12/20 bytes */
    JSRegExp regexp;     /* JS_CLASS_REGEXP: 8/16 bytes */
    JSValue object_data; /* for JS_SetObjectData(): 8/16/16 bytes */
  } u;
  /* byte sizes: 40/48/72 */
};

uint16_t* JS_ToUnicode(JSContext* ctx, JSValueConst value, uint32_t* length) {
  if (JS_VALUE_GET_TAG(value) != JS_TAG_STRING) {
    value = JS_ToString(ctx, value);
    if (JS_IsException(value))
      return nullptr;
  } else {
    value = JS_DupValue(ctx, value);
  }

  uint16_t* buffer;
  JSString* string = JS_VALUE_GET_STRING(value);

  if (!string->is_wide_char) {
    uint8_t* p = string->u.str8;
    uint32_t len = *length = string->len;
    buffer = (uint16_t*)malloc(sizeof(uint16_t) * len * 2);
    for (size_t i = 0; i < len; i++) {
      buffer[i] = p[i];
      buffer[i + 1] = 0x00;
    }
  } else {
    *length = string->len;
    buffer = (uint16_t*)malloc(sizeof(uint16_t) * string->len);
    memcpy(buffer, string->u.str16, sizeof(uint16_t) * string->len);
  }

  JS_FreeValue(ctx, value);
  return buffer;
}

static JSString* js_alloc_string_rt(JSRuntime* rt, int max_len, int is_wide_char) {
  JSString* str;
  str = static_cast<JSString*>(js_malloc_rt(rt, sizeof(JSString) + (max_len << is_wide_char) + 1 - is_wide_char));
  if (unlikely(!str))
    return NULL;
  str->header.ref_count = 1;
  str->is_wide_char = is_wide_char;
  str->len = max_len;
  str->atom_type = 0;
  str->hash = 0;      /* optional but costless */
  str->hash_next = 0; /* optional */
#ifdef DUMP_LEAKS
  list_add_tail(&str->link, &rt->string_list);
#endif
  return str;
}

static JSString* js_alloc_string(JSRuntime* runtime, JSContext* ctx, int max_len, int is_wide_char) {
  JSString* p;
  p = js_alloc_string_rt(runtime, max_len, is_wide_char);
  if (unlikely(!p)) {
    JS_ThrowOutOfMemory(ctx);
    return NULL;
  }
  return p;
}

JSValue JS_NewUnicodeString(JSRuntime* runtime, JSContext* ctx, const uint16_t* code, uint32_t length) {
  JSString* str;
  str = js_alloc_string(runtime, ctx, length, 1);
  if (!str)
    return JS_EXCEPTION;
  memcpy(str->u.str16, code, length * 2);
  return JS_MKPTR(JS_TAG_STRING, str);
}

JSClassID JSValueGetClassId(JSValue obj) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return -1;
  p = JS_VALUE_GET_OBJ(obj);
  return p->class_id;
}

bool JS_IsProxy(JSValue value) {
  if (!JS_IsObject(value))
    return false;
  JSObject* p = JS_VALUE_GET_OBJ(value);
  return p->class_id == JS_CLASS_PROXY;
}

bool JS_HasClassId(JSRuntime* runtime, JSClassID classId) {
  if (runtime->class_count <= classId)
    return false;
  return runtime->class_array[classId].class_id == classId;
}

JSValue JS_GetProxyTarget(JSValue value) {
  JSObject* p = JS_VALUE_GET_OBJ(value);
  return p->u.proxy_data->target;
}
