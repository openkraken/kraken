/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "js_event_handler.h"
#include "core/dom/events/error_event.h"
#include "core/dom/events/event_target.h"
#include "event_type_names.h"

namespace kraken {

std::unique_ptr<JSEventHandler> JSEventHandler::CreateOrNull(JSContext* ctx, JSValue value, JSEventHandler::HandlerType handler_type) {
  if (!JS_IsFunction(ctx, value)) {
    return nullptr;
  }

  return std::make_unique<JSEventHandler>(QJSFunction::Create(ctx, value), handler_type);
}

bool JSEventHandler::Matches(const EventListener& other) const {
  return this == &other;
}

// https://html.spec.whatwg.org/C/#the-event-handler-processing-algorithm
void JSEventHandler::InvokeInternal(EventTarget& event_target, Event& event, ExceptionState& exception_state) {
  // Step 1. Let callback be the result of getting the current value of the
  //         event handler given eventTarget and name.
  // Step 2. If callback is null, then return.
  JSValue listener_value = GetListenerObject(*event.currentTarget());
  if (JS_IsNull(listener_value))
    return;

  // Step 3. Let special error event handling be true if event is an ErrorEvent
  // object, event's type is error, and event's currentTarget implements the
  // WindowOrWorkerGlobalScope mixin. Otherwise, let special error event
  // handling be false.
  const bool special_error_event_handling =
      IsA<ErrorEvent>(event) && event.type() == event_type_names::kError &&
          event.currentTarget()->IsWindowOrWorkerGlobalScope();

  // Step 4. Process the Event object event as follows:
  //   If special error event handling is true
  //     Invoke callback with five arguments, the first one having the value of
  //     event's message attribute, the second having the value of event's
  //     filename attribute, the third having the value of event's lineno
  //     attribute, the fourth having the value of event's colno attribute, the
  //     fifth having the value of event's error attribute, and with the
  //     callback this value set to event's currentTarget. Let return value be
  //     the callback's return value.
  //   Otherwise
  //     Invoke callback with one argument, the value of which is the Event
  //     object event, with the callback this value set to event's
  //     currentTarget. Let return value be the callback's return value.
  //   If an exception gets thrown by the callback, end these steps and allow
  //   the exception to propagate. (It will propagate to the DOM event dispatch
  //   logic, which will then report the exception.)

  std::vector<ScriptValue> arguments;
  JSContext* ctx = event_target.ctx();

  if (special_error_event_handling) {
    // TODO: Implement error event handling.
    auto* error_event = To<ErrorEvent>(&event);
    // The error argument should be initialized to null for dedicated workers.
    // https://html.spec.whatwg.org/C/#runtime-script-errors-2
//    ScriptValue error_attribute = error_event->error(script_state_of_listener);
//    if (error_attribute.IsEmpty() ||
//        error_event->target()->InterfaceName() == event_target_names::kWorker) {
//      error_attribute = ScriptValue::CreateNull(isolate);
//    }
//    arguments = {
//        ScriptValue(isolate,
//                    ToV8Traits<IDLString>::ToV8(script_state_of_listener,
//                                                error_event->message())
//                        .ToLocalChecked()),
//        ScriptValue(isolate,
//                    ToV8Traits<IDLString>::ToV8(script_state_of_listener,
//                                                error_event->filename())
//                        .ToLocalChecked()),
//        ScriptValue(isolate,
//                    ToV8Traits<IDLUnsignedLong>::ToV8(script_state_of_listener,
//                                                      error_event->lineno())
//                        .ToLocalChecked()),
//        ScriptValue(isolate, ToV8Traits<IDLUnsignedLong>::ToV8(
//            script_state_of_listener, error_event->colno())
//            .ToLocalChecked()),
//        error_attribute};
  } else {
    arguments.emplace_back(ctx, event.ToQuickJS());
  }

//  if (!event_handler_->IsRunnableOrThrowException(
//      event.ShouldDispatchEvenWhenExecutionContextIsPaused()
//      ? V8EventHandlerNonNull::IgnorePause::kIgnore
//      : V8EventHandlerNonNull::IgnorePause::kDontIgnore)) {
//    return;
//  }
//  ScriptValue result;
//  if (!event_handler_
//      ->InvokeWithoutRunnabilityCheck(event.currentTarget(), arguments)
//      .To(&result) ||
//      isolate->IsExecutionTerminating())
//    return;
//  v8::Local<v8::Value> v8_return_value = result.V8Value();
//
//  // There is nothing to do if |v8_return_value| is null or undefined.
//  // See Step 5. for more information.
//  if (v8_return_value->IsNullOrUndefined())
//    return;
//
//  // https://webidl.spec.whatwg.org/#invoke-a-callback-function
//  // step 13: Set completion to the result of converting callResult.[[Value]] to
//  //          an IDL value of the same type as the operation's return type.
//  //
//  // OnBeforeUnloadEventHandler returns DOMString? while OnErrorEventHandler and
//  // EventHandler return any, so converting |v8_return_value| to return type is
//  // necessary only for OnBeforeUnloadEventHandler.
//  String result_for_beforeunload;
//  if (IsOnBeforeUnloadEventHandler()) {
//    event_handler_->EvaluateAsPartOfCallback(Bind(
//        [](v8::Local<v8::Value>& v8_return_value,
//           String& result_for_beforeunload) {
//          // TODO(yukiy): use |NativeValueTraits|.
//          V8StringResource<kTreatNullAsNullString> native_result(
//              v8_return_value);
//
//          // |native_result.Prepare()| throws exception if it fails to convert
//          // |native_result| to String.
//          if (!native_result.Prepare())
//            return;
//          result_for_beforeunload = native_result;
//        },
//        std::ref(v8_return_value), std::ref(result_for_beforeunload)));
//    if (!result_for_beforeunload)
//      return;
//  }

  // Step 5. Process return value as follows:
  //   If event is a BeforeUnloadEvent object and event's type is beforeunload
  //     If return value is not null, then:
  //       1. Set event's canceled flag.
  //       2. If event's returnValue attribute's value is the empty string, then
  //          set event's returnValue attribute's value to return value.
  //   If special error event handling is true
  //     If return value is true, then set event's canceled flag.
  //   Otherwise
  //     If return value is false, then set event's canceled flag.
  //       Note: If we've gotten to this "Otherwise" clause because event's type
  //             is beforeunload but event is not a BeforeUnloadEvent object,
  //             then return value will never be false, since in such cases
  //             return value will have been coerced into either null or a
  //             DOMString.
//  auto* before_unload_event = DynamicTo<BeforeUnloadEvent>(&event);
//  const bool is_beforeunload_event =
//      before_unload_event && event.type() == event_type_names::kBeforeunload;
//  if (is_beforeunload_event) {
//    if (result_for_beforeunload) {
//      event.preventDefault();
//      if (before_unload_event->returnValue().IsEmpty())
//        before_unload_event->setReturnValue(result_for_beforeunload);
//    }
//  } else if (!IsOnBeforeUnloadEventHandler()) {
//    if (special_error_event_handling && v8_return_value->IsBoolean() &&
//        v8_return_value.As<v8::Boolean>()->Value())
//      event.preventDefault();
//    else if (!special_error_event_handling && v8_return_value->IsBoolean() &&
//        !v8_return_value.As<v8::Boolean>()->Value())
//      event.preventDefault();
//  }
}

}
