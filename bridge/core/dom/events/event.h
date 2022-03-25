/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_H
#define KRAKENBRIDGE_EVENT_H

#include <cinttypes>
#include "bindings/qjs/script_wrappable.h"
#include "foundation/native_string.h"
#include "core/executing_context.h"

namespace kraken {

class EventTarget;
class ExceptionState;

// Dart generated nativeEvent member are force align to 64-bit system. So all members in NativeEvent should have 64 bit width.
#if ANDROID_32_BIT
struct NativeEvent {
  int64_t type{0};
  int64_t bubbles{0};
  int64_t cancelable{0};
  int64_t timeStamp{0};
  int64_t defaultPrevented{0};
  // The pointer address of target EventTargetInstance object.
  int64_t target{0};
  // The pointer address of current target EventTargetInstance object.
  int64_t currentTarget{0};
};
#else
// Use pointer instead of int64_t on 64 bit system can help compiler to choose best register for better running performance.
struct NativeEvent {
  NativeString* type{nullptr};
  int64_t bubbles{0};
  int64_t cancelable{0};
  int64_t timeStamp{0};
  int64_t defaultPrevented{0};
  // The pointer address of target EventTargetInstance object.
  void* target{nullptr};
  // The pointer address of current target EventTargetInstance object.
  void* currentTarget{nullptr};
};
#endif

struct RawEvent {
  uint64_t* bytes;
  int64_t length;
};

class Event : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static Event* Create(ExecutingContext* context) { return makeGarbageCollected<Event>(context); };
  static Event* From(ExecutingContext* context, NativeEvent* native_event) {
  }

  Event() = delete;
  explicit Event(ExecutingContext* context);
  explicit Event(ExecutingContext* context, NativeEvent* native_event);

  void Trace(GCVisitor* visitor) const override;
  void Dispose() const override;
  const char* GetHumanReadableName() const override;
  bool propagationStopped() const { return propagation_stopped_; }
  bool bubbles() { return bubbles_; };
  double timeStamp() { return time_stamp_; }
  bool propagationImmediatelyStopped(ExceptionState& exception_state) { return propagation_immediately_stopped_; }
  bool cancelable() const { return cancelable_; }
  FORCE_INLINE NativeString* type() { return type_; };
  void SetType(NativeString* type);
  EventTarget* target() const;
  void SetTarget(EventTarget* target);
  EventTarget* currentTarget() const;
  void SetCurrentTarget(EventTarget* target);

  bool cancelBubble() const {
    return propagationStopped();
  }
  void setCancelBubble(bool cancel) {
    if (cancel) {
      propagation_stopped_ = true;
    }
  };

  // IE legacy
  EventTarget* srcElement() const;

  void stopPropagation() { propagation_stopped_ = true; }
  void SetStopPropagation(bool stop_propagation) {
    propagation_stopped_ = stop_propagation;
  }
  void stopImmediatePropagation(ExceptionState& exception_state) { propagation_immediately_stopped_ = true; }
  void SetStopImmediatePropagation(bool stop_immediate_propagation) {
    propagation_immediately_stopped_ = stop_immediate_propagation;
  }

  bool defaultPrevented() const { return default_prevented_; }
  void preventDefault(ExceptionState& exception_state);

 protected:
  bool bubbles_{false};
  bool cancelable_{false};
  double time_stamp_{0.0};
  bool default_prevented_{false};
  EventTarget* target_{nullptr};
  EventTarget* current_target_{nullptr};
  bool propagation_stopped_{false};
  bool propagation_immediately_stopped_{false};
  NativeString* type_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_EVENT_H
