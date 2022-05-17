/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "window.h"
#include "binding_call_methods.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "core/dom/document.h"
#include "core/events/message_event.h"
#include "event_type_names.h"
#include "foundation/native_value_converter.h"

namespace kraken {

Window::Window(ExecutingContext* context) : EventTargetWithInlineData(context) {
  KRAKEN_LOG(VERBOSE) << "Add Create Window Command";
  context->uiCommandBuffer()->addCommand(context->contextId(), UICommand::kCreateWindow, (void*)bindingObject());
}

Window* Window::open(ExceptionState& exception_state) {
  return this;
}

Window* Window::open(const AtomicString& url, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeString>::ToNativeValue(url.ToNativeString().release()),
  };
  InvokeBindingMethod(binding_call_methods::kopen, 1, args, exception_state);
}

void Window::scroll(ExceptionState& exception_state) {
  return scroll(0, 0, exception_state);
}

void Window::scroll(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args, exception_state);
}

void Window::scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->left()),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->top()),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args, exception_state);
}

void Window::scrollBy(ExceptionState& exception_state) {
  return scrollBy(0, 0, exception_state);
}

void Window::scrollBy(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Window::scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->left()),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->top()),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Window::scrollTo(ExceptionState& exception_state) {
  return scroll(exception_state);
}

void Window::scrollTo(double x, double y, ExceptionState& exception_state) {
  return scroll(x, y, exception_state);
}

void Window::scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  return scroll(options, exception_state);
}

void Window::postMessage(const ScriptValue& message, ExceptionState& exception_state) {
  auto event_init = MessageEventInit::Create();
  event_init->setData(message);
  auto* message_event =
      MessageEvent::Create(GetExecutingContext(), event_type_names::kmessage, event_init, exception_state);
  dispatchEvent(message_event, exception_state);
}

void Window::postMessage(const ScriptValue& message,
                         const AtomicString& target_origin,
                         ExceptionState& exception_state) {
  auto event_init = MessageEventInit::Create();
  event_init->setData(message);
  event_init->setOrigin(target_origin);
  auto* message_event =
      MessageEvent::Create(GetExecutingContext(), event_type_names::kmessage, event_init, exception_state);
  dispatchEvent(message_event, exception_state);
}

double Window::requestAnimationFrame(const std::shared_ptr<QJSFunction>& callback, ExceptionState& exceptionState) {
  if (GetExecutingContext()->dartMethodPtr()->flushUICommand == nullptr) {
    exceptionState.ThrowException(ctx(), ErrorType::InternalError,
                                  "Failed to execute 'flushUICommand': dart method (flushUICommand) executed "
                                  "with unexpected error.");
    return 0;
  }

  GetExecutingContext()->dartMethodPtr()->flushUICommand();
  auto frame_callback = FrameCallback::Create(GetExecutingContext(), callback);
  uint32_t request_id = GetExecutingContext()->document()->RequestAnimationFrame(frame_callback, exceptionState);
  // `-1` represents some error occurred.
  if (request_id == -1) {
    exceptionState.ThrowException(
        ctx(), ErrorType::InternalError,
        "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) executed "
        "with unexpected error.");
    return 0;
  }
  return request_id;
}

void Window::cancelAnimationFrame(double request_id, ExceptionState& exception_state) {
  GetExecutingContext()->document()->CancelAnimationFrame(static_cast<uint32_t>(request_id), exception_state);
}

}  // namespace kraken
