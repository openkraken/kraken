/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WINDOW_H
#define KRAKENBRIDGE_WINDOW_H

#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/wrapper_type_info.h"
#include "core/dom/events/event_target.h"
#include "qjs_scroll_to_options.h"

namespace kraken {

class Window : public EventTargetWithInlineData {
  DEFINE_WRAPPERTYPEINFO();

 public:
  Window() = delete;
  Window(ExecutingContext* context);

  Window* open(ExceptionState& exception_state);
  Window* open(const AtomicString& url, ExceptionState& exception_state);

  [[nodiscard]] const Window* window() const { return this; }

  void scroll(ExceptionState& exception_state);
  void scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scroll(double x, double y, ExceptionState& exception_state);
  void scrollTo(ExceptionState& exception_state);
  void scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollTo(double x, double y, ExceptionState& exception_state);
  void scrollBy(ExceptionState& exception_state);
  void scrollBy(double x, double y, ExceptionState& exception_state);
  void scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);

  void postMessage(const ScriptValue& message, ExceptionState& exception_state);
  void postMessage(const ScriptValue& message, const AtomicString& target_origin, ExceptionState& exception_state);

  double requestAnimationFrame(const std::shared_ptr<QJSFunction>& callback, ExceptionState& exceptionState);

  //  DEFINE_FUNCTION(open);
  //  DEFINE_FUNCTION(scrollTo);
  //  DEFINE_FUNCTION(scrollBy);
  //  DEFINE_FUNCTION(postMessage);
  //  DEFINE_FUNCTION(requestAnimationFrame);
  //  DEFINE_FUNCTION(cancelAnimationFrame);
  //
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(devicePixelRatio);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(colorScheme);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(__location__);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(location);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(window);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(parent);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(scrollX);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(scrollY);
  //  DEFINE_PROTOTYPE_READONLY_PROPERTY(self);
  //  DEFINE_PROTOTYPE_PROPERTY(onerror);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_WINDOW_H
