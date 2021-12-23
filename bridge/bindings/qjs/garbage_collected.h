/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_GARBAGE_COLLECTED_H
#define KRAKENBRIDGE_GARBAGE_COLLECTED_H

#include <quickjs/quickjs.h>
#include "include/kraken_foundation.h"
#include "qjs_patch.h"

namespace kraken::binding::qjs {

template <typename T>
class MakeGarbageCollectedTrait;

/**
 * Base class for GC managed objects. Only descendent types of `GarbageCollected`
 * can be constructed using `MakeGarbageCollected()`. Must be inherited from as
 * left-most base class.
 *
 * \code
 * // Example using final class.
 * class FinalType final : public GarbageCollected<FinalType> {
 *  public:
 *   void Trace(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) const {
 *     // trace all memory wants to collected by GC.
 *   }
 * };
 */
template <typename T>
class GarbageCollected {
 public:
  using ParentMostGarbageCollectedType = T;

  virtual T* initialize(JSContext* ctx, JSClassID* classId);

  // Must use MakeGarbageCollected.
  void* operator new(size_t) = delete;
  void* operator new[](size_t) = delete;

  // The garbage collector is taking care of reclaiming the object.
  void operator delete(void*) = delete;
  void operator delete[](void*) = delete;

  /**
   * This Trace method must be override by objects inheriting from
   * GarbageCollected.
   */
  virtual void trace(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) const {};

  /**
   * Specifies a name for the garbage-collected object. Such names will never
   * be hidden, as they are explicitly specified by the user of this API.
   *
   * @returns a human readable name for the object.
   */
  [[nodiscard]] FORCE_INLINE virtual const char* getHumanReadableName() const { return ""; };

  FORCE_INLINE JSValue toQuickJS() { return jsObject; };

  FORCE_INLINE JSContext* ctx() { return m_ctx; }

  // A anchor to efficiently bind the current object to a linked-list.
  list_head link;

 protected:
  JSValue jsObject{JS_NULL};
  JSContext* m_ctx{nullptr};
  GarbageCollected(){};
  friend class MakeGarbageCollectedTrait<T>;
};

template <typename T>
class MakeGarbageCollectedTrait {
 public:
  template <typename... Args>
  static T* allocate(Args&&... args) {
    T* object = ::new T(std::forward<Args>(args)...);
    return object;
  }

  friend GarbageCollected<T>;
};

template <typename T>
T* GarbageCollected<T>::initialize(JSContext* ctx, JSClassID* classId) {
  JSRuntime* runtime = JS_GetRuntime(ctx);

  /// When classId is 0, it means this class are not initialized. We should create a JSClassDef to describe the behavior of this class and associate with classID.
  /// ClassId should be a static value to make sure JSClassDef when this class are created at the first class.
  if (*classId == 0 || !JS_HasClassId(runtime, *classId)) {
    /// Allocate a new unique classID from QuickJS.
    JS_NewClassID(classId);
    /// Basic template to describe the behavior about this class.
    JSClassDef def{};

    def.class_name = getHumanReadableName();

    /// This callback will be called when QuickJS GC is running at marking stage.
    /// Users of this class should override `void trace(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func)` to tell GC
    /// which member of their class should be collected by GC.
    def.gc_mark = [](JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) {
      auto* object = static_cast<T*>(JS_GetOpaque(val, JSValueGetClassId(val)));
      object->trace(rt, val, mark_func);
    };

    /// This callback will be called when QuickJS GC will release the `jsObject` object memory of this class.
    /// The deconstruct method of this class will be called and all memory about this class will be freed when finalize completed.
    def.finalizer = [](JSRuntime* rt, JSValue val) {
      auto* object = static_cast<T*>(JS_GetOpaque(val, JSValueGetClassId(val)));
      free(object);
    };

    JS_NewClass(runtime, *classId, &def);
  }

  /// The JavaScript object underline this class. This `jsObject` is the JavaScript object which can be directly access within JavaScript code.
  /// When the reference count of `jsObject` decrease to 0, QuickJS will trigger `finalizer` callback and free `jsObject` memory.
  /// When QuickJS GC found `jsObject` at marking stage, `gc_mark` callback will be triggered.
  jsObject = JS_NewObjectClass(ctx, *classId);
  JS_SetOpaque(jsObject, this);

  m_ctx = ctx;

  return static_cast<T*>(this);
}

template <typename T, typename... Args>
T* makeGarbageCollected(Args&&... args) {
  static_assert(std::is_base_of<typename T::ParentMostGarbageCollectedType, T>::value,
                "U of GarbageCollected<U> must be a base of T. Check "
                "GarbageCollected<T> base class inheritance.");
  return MakeGarbageCollectedTrait<T>::allocate(std::forward<Args>(args)...);
}

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_GARBAGE_COLLECTED_H
