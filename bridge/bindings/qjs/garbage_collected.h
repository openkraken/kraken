/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_GARBAGE_COLLECTED_H
#define KRAKENBRIDGE_GARBAGE_COLLECTED_H

#include <quickjs/quickjs.h>
#include <memory>

#include "foundation/macros.h"
#include "foundation/casting.h"
#include "gc_visitor.h"
#include "qjs_engine_patch.h"

namespace kraken {

template <typename T>
class MakeGarbageCollectedTrait;

class ExecutingContext;

/**
 * This class are mainly designed as base class for ScriptWrappable. If you wants to implement
 * a class which have corresponding object in JS environment and have the same memory life circle with JS object, use
 * ScriptWrappable instead.
 *
 * Base class for GC managed objects. Only descendent types of `GarbageCollected`
 * can be constructed using `MakeGarbageCollected()`. Must be inherited from as
 * left-most base class.
 */
template <typename T>
class GarbageCollected {
 public:
  using ParentMostGarbageCollectedType = T;

  // Must use MakeGarbageCollected.
  void* operator new(size_t) = delete;
  void* operator new[](size_t) = delete;

  /**
   * This Trace method must be override by objects inheriting from
   * GarbageCollected.
   */
  virtual void Trace(GCVisitor* visitor) const = 0;

  virtual void InitializeQuickJSObject() = 0;

 protected:
  GarbageCollected(){};
  ~GarbageCollected() = default;
  friend class MakeGarbageCollectedTrait<T>;
};

template <typename T>
class MakeGarbageCollectedTrait {
 public:
  template <typename... Args>
  static T* Allocate(Args&&... args) {
    T* object = ::new T(std::forward<Args>(args)...);
    if (auto* scriptwrappable = DynamicTo<ScriptWrappable>(object)) {
      scriptwrappable->InitializeQuickJSObject();
    }
    return object;
  }

  friend GarbageCollected<T>;
};

template <typename T, typename... Args>
T* MakeGarbageCollected(Args&&... args) {
  static_assert(std::is_base_of<typename T::ParentMostGarbageCollectedType, T>::value,
                "U of GarbageCollected<U> must be a base of T. Check "
                "GarbageCollected<T> base class inheritance.");
  return MakeGarbageCollectedTrait<T>::Allocate(std::forward<Args>(args)...);
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_GARBAGE_COLLECTED_H
