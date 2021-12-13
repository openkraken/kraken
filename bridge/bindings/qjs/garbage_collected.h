/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_GARBAGE_COLLECTED_H
#define KRAKENBRIDGE_GARBAGE_COLLECTED_H

#include <quickjs/quickjs.h>

namespace kraken::binding::qjs {

/**
 * Base class for GC managed objects. Only descendent types of `GarbageCollected`
 * can be constructed using `MakeGarbageCollected()`. Must be inherited from as
 * left-most base class.
 *
 * Types inheriting from GarbageCollected must provide a method of
 * signature `void Trace(cppgc::Visitor*) const` that dispatchs all managed
 * pointers to the visitor and delegates to garbage-collected base classes.
 * The method must be virtual if the type is not directly a child of
 * GarbageCollected and marked as final.
 *
 * \code
 * // Example using final class.
 * class FinalType final : public GarbageCollected<FinalType> {
 *  public:
 *   void Trace(cppgc::Visitor* visitor) const {
 *     // Dispatch using visitor->Trace(...);
 *   }
 * };
 *
 * // Example using non-final base class.
 * class NonFinalBase : public GarbageCollected<NonFinalBase> {
 *  public:
 *   virtual void Trace(cppgc::Visitor*) const {}
 * };
 *
 * class FinalChild final : public NonFinalBase {
 *  public:
 *   void Trace(cppgc::Visitor* visitor) const final {
 *     // Dispatch using visitor->Trace(...);
 *     NonFinalBase::Trace(visitor);
 *   }
 * };
 * \endcode
 */
template <typename T>
class GarbageCollected {
 public:
  using ParentMostGarbageCollectedType = T;

  // Must use MakeGarbageCollected.
  void* operator new(size_t) = delete;
  void* operator new[](size_t) = delete;

  // The garbage collector is taking care of reclaiming the object.
  void operator delete(void*) = delete void operator delete[](void*) = delete;

  /**
   * This Trace method must be override by objects inheriting from
   * GarbageCollected.
   */
  virtual void trace(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) const {};

 protected:
  GarbageCollected() = default;
};

template <typename T>
T* MakeGarbageCollected(Args&&... args) {
  static_assert(std::is_base_of<typename T::ParentMostGarbageCollectedType, T>::value,
                "U of GarbageCollected<U> must be a base of T. Check "
                "GarbageCollected<T> base class inheritance.");
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_GARBAGE_COLLECTED_H
