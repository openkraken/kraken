/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_GARBAGE_COLLECTED_H
#define KRAKENBRIDGE_GARBAGE_COLLECTED_H

#include <quickjs/quickjs.h>
#include <memory>

#include "foundation/macros.h"
#include "gc_visitor.h"
#include "qjs_engine_patch.h"

namespace kraken {

template <typename T>
class MakeGarbageCollectedTrait;

class ExecutingContext;

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
  virtual void trace(GCVisitor* visitor) const = 0;

  /**
   * Called before underline JavaScript object been collected by GC.
   * Note: JS_FreeValue and JS_FreeAtom is not available, use JS_FreeValueRT and JS_FreeAtomRT instead.
   */
  virtual void dispose() const = 0;

  /**
   * Specifies a name for the garbage-collected object. Such names will never
   * be hidden, as they are explicitly specified by the user of this API.
   *
   * @returns a human readable name for the object.
   */
  [[nodiscard]] FORCE_INLINE virtual const char* getHumanReadableName() const { return ""; };

  FORCE_INLINE JSContext* ctx() { return m_ctx; };
  FORCE_INLINE ExecutingContext* context() const { return static_cast<ExecutingContext*>(JS_GetContextOpaque(m_ctx)); };

 protected:
  JSValue jsObject{JS_NULL};
  JSContext* m_ctx{nullptr};
  JSRuntime* m_runtime{nullptr};
  GarbageCollected(){};
  GarbageCollected(JSContext* ctx) : m_runtime(JS_GetRuntime(ctx)), m_ctx(ctx){};
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

template <typename T, typename... Args>
T* makeGarbageCollected(Args&&... args) {
  static_assert(std::is_base_of<typename T::ParentMostGarbageCollectedType, T>::value,
                "U of GarbageCollected<U> must be a base of T. Check "
                "GarbageCollected<T> base class inheritance.");
  return MakeGarbageCollectedTrait<T>::allocate(std::forward<Args>(args)...);
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_GARBAGE_COLLECTED_H
