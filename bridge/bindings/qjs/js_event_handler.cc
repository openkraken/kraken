/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "js_event_handler.h"
#include "bindings/qjs/converter_impl.h"
#include "core/dom/events/event_target.h"
#include "core/events/error_event.h"
#include "event_type_names.h"

namespace kraken {

std::unique_ptr<JSEventHandler> JSEventHandler::CreateOrNull(JSContext* ctx,
                                                             JSValue value,
                                                             JSEventHandler::HandlerType handler_type) {
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
  const bool special_error_event_handling = IsA<ErrorEvent>(event) && event.type() == event_type_names::kerror &&
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
    ScriptValue error_attribute = error_event->error();
    if (error_attribute.IsEmpty()) {
      error_attribute = ScriptValue::Empty(event.ctx());
    }
    arguments = {ScriptValue(ctx, Converter<IDLDOMString>::ToValue(ctx, error_event->message())),
                 ScriptValue(ctx, Converter<IDLDOMString>::ToValue(ctx, error_event->filename())),
                 ScriptValue(ctx, Converter<IDLInt64>::ToValue(ctx, error_event->lineno())),
                 ScriptValue(ctx, Converter<IDLInt64>::ToValue(ctx, error_event->colno())), error_attribute};
  } else {
    arguments.emplace_back(ctx, event.ToQuickJS());
  }

  ScriptValue result = event_handler_->Invoke(event.ctx(), ScriptValue(event_target.ctx(), event_target.ToQuickJS()),
                                              arguments.size(), arguments.data());
  if (result.IsException()) {
    exception_state.ThrowException(event.ctx(), result.QJSValue());
    return;
  }

  //  // There is nothing to do if |v8_return_value| is null or undefined.
  //  // See Step 5. for more information.
  if (result.IsEmpty()) {
    return;
  }

  // https://webidl.spec.whatwg.org/#invoke-a-callback-function
  // step 13: Set completion to the result of converting callResult.[[Value]] to
  //          an IDL value of the same type as the operation's return type.
  //
  // OnBeforeUnloadEventHandler returns DOMString? while OnErrorEventHandler and
  // EventHandler return any, so converting |v8_return_value| to return type is
  // necessary only for OnBeforeUnloadEventHandler.
  // TODO: special handling for beforeunload event and onerror event.
}

}  // namespace kraken
