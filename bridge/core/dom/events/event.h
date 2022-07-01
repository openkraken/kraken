/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_H
#define KRAKENBRIDGE_EVENT_H

#include <cinttypes>
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/executing_context.h"
#include "foundation/native_string.h"
#include "qjs_event_init.h"

namespace kraken {

class EventTarget;
class ExceptionState;

// Dart generated nativeEvent member are force align to 64-bit system. So all members in NativeEvent should have 64 bit
// width.
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
// Use pointer instead of int64_t on 64 bit system can help compiler to choose best register for better running
// performance.
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
  using ImplType = Event*;

  enum class Bubbles {
    kNo,
    kYes,
  };

  enum class Cancelable {
    kNo,
    kYes,
  };

  enum class ComposedMode {
    kComposed,
    kScoped,
  };

  enum class PassiveMode {
    // Not passive, default initialized.
    kNotPassiveDefault,
    // Not passive, explicitly specified.
    kNotPassive,
    // Passive, explicitly specified.
    kPassive,
    // Passive, not explicitly specified and forced due to document level
    // listener.
    kPassiveForcedDocumentLevel,
    // Passive, default initialized.
    kPassiveDefault,
  };

  enum PhaseType { kNone = 0, kCapturingPhase = 1, kAtTarget = 2, kBubblingPhase = 3 };

  static Event* Create(ExecutingContext* context) { return MakeGarbageCollected<Event>(context); };
  static Event* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state) {
    return MakeGarbageCollected<Event>(context, type);
  };
  static Event* Create(ExecutingContext* context,
                       const AtomicString& type,
                       const std::shared_ptr<EventInit>& init,
                       ExceptionState& exception_state) {
    return MakeGarbageCollected<Event>(context, type, init);
  };

  static Event* From(ExecutingContext* context, NativeEvent* native_event);

  Event() = delete;
  explicit Event(ExecutingContext* context);
  explicit Event(ExecutingContext* context, const AtomicString& event_type);
  explicit Event(ExecutingContext* context, const AtomicString& type, const std::shared_ptr<EventInit>& init);
  explicit Event(ExecutingContext* context,
                 const AtomicString& event_type,
                 Bubbles bubbles,
                 Cancelable cancelable,
                 ComposedMode composed_mode,
                 double timeStamp);

  bool propagationStopped() const { return propagation_stopped_; }
  bool bubbles() { return bubbles_; };
  double timeStamp() { return time_stamp_; }
  bool propagationImmediatelyStopped(ExceptionState& exception_state) { return immediate_propagation_stopped_; }
  bool cancelable() const { return cancelable_; }
  const AtomicString& type() { return type_; };
  void SetType(const AtomicString& type);
  EventTarget* target() const;
  void SetTarget(EventTarget* target);
  EventTarget* currentTarget() const;
  void SetCurrentTarget(EventTarget* target);

  uint8_t eventPhase() const { return event_phase_; }
  void SetEventPhase(uint8_t event_phase) { event_phase_ = event_phase; }

  // These events are general classes of events.
  virtual bool IsUIEvent() const;
  virtual bool IsMouseEvent() const;
  virtual bool IsFocusEvent() const;
  virtual bool IsKeyboardEvent() const;
  virtual bool IsTouchEvent() const;
  virtual bool IsGestureEvent() const;
  virtual bool IsPointerEvent() const;
  virtual bool IsInputEvent() const;

  // Drag events are a subset of mouse events.
  virtual bool IsDragEvent() const;

  virtual bool IsBeforeUnloadEvent() const;
  virtual bool IsErrorEvent() const;

  // This callback is invoked when an event listener has been dispatched
  // at the current target. It should only be used to influence UMA metrics
  // and not change functionality since observing the presence of listeners
  // is dangerous.
  virtual void DoneDispatchingEventAtCurrentTarget() {}

  bool cancelBubble() const { return propagationStopped(); }
  void setCancelBubble(bool cancel, ExceptionState& exception_state) {
    if (cancel) {
      propagation_stopped_ = true;
    }
  };

  bool IsBeingDispatched() { return eventPhase(); }

  // IE legacy
  EventTarget* srcElement() const;

  void stopPropagation(ExceptionState& exception_state) { propagation_stopped_ = true; }
  void SetStopPropagation(bool stop_propagation) { propagation_stopped_ = stop_propagation; }
  void stopImmediatePropagation(ExceptionState& exception_state) { immediate_propagation_stopped_ = true; }
  void SetStopImmediatePropagation(bool stop_immediate_propagation) {
    immediate_propagation_stopped_ = stop_immediate_propagation;
  }
  void initEvent(const AtomicString& event_type, bool bubbles, bool cancelable, ExceptionState& exception_state);

  bool ImmediatePropagationStopped() const { return immediate_propagation_stopped_; }
  bool WasInitialized() { return was_initialized_; }

  void SetHandlingPassive(PassiveMode);

  bool isTrusted() const { return is_trusted_; }
  void SetTrusted(bool value) { is_trusted_ = value; }

  bool defaultPrevented() const { return default_prevented_; }
  void preventDefault(ExceptionState& exception_state);

  bool DefaultHandled() const { return default_handled_; }
  void SetDefaultHandled() { default_handled_ = true; }

  void SetFireOnlyCaptureListenersAtTarget(bool fire_only_capture_listeners_at_target) {
    assert(event_phase_ == kAtTarget);
    fire_only_capture_listeners_at_target_ = fire_only_capture_listeners_at_target;
  }

  void SetFireOnlyNonCaptureListenersAtTarget(bool fire_only_non_capture_listeners_at_target) {
    assert(event_phase_ = kAtTarget);
    fire_only_non_capture_listeners_at_target_ = fire_only_non_capture_listeners_at_target;
  }

  bool FireOnlyCaptureListenersAtTarget() const { return fire_only_capture_listeners_at_target_; }
  bool FireOnlyNonCaptureListenersAtTarget() const { return fire_only_non_capture_listeners_at_target_; }

  void Trace(GCVisitor* visitor) const override;

 protected:
  PassiveMode HandlingPassive() const { return handling_passive_; }

  AtomicString type_;

  unsigned bubbles_ : 1;
  unsigned cancelable_ : 1;
  unsigned composed_ : 1;
  double time_stamp_{0.0};

  unsigned propagation_stopped_ : 1;
  unsigned immediate_propagation_stopped_ : 1;
  unsigned default_prevented_ : 1;
  unsigned default_handled_ : 1;
  unsigned was_initialized_ : 1;
  unsigned is_trusted_ : 1;

  PassiveMode handling_passive_;
  uint8_t event_phase_ = PhaseType::kNone;

  // Whether preventDefault was called on uncancelable event.
  unsigned prevent_default_called_on_uncancelable_event_ : 1;

  unsigned fire_only_capture_listeners_at_target_ : 1;
  unsigned fire_only_non_capture_listeners_at_target_ : 1;

  EventTarget* target_{nullptr};
  EventTarget* current_target_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_EVENT_H
