/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_JS_EVENT_LISTENER_H_
#define KRAKENBRIDGE_BINDINGS_QJS_JS_EVENT_LISTENER_H_

#include "js_based_event_listener.h"
#include "foundation/casting.h"

namespace kraken {

// |JSEventListener| implements EventListener in the DOM standard.
// https://dom.spec.whatwg.org/#callbackdef-eventlistener
class JSEventListener final : public JSBasedEventListener {
 public:
  using ImplType = std::shared_ptr<JSEventListener>;

  // TODO: Support IDL EventListener callbackInterface.
  static std::unique_ptr<JSEventListener> CreateOrNull(std::shared_ptr<QJSFunction> listener) {
    return listener ? std::make_unique<JSEventListener>(listener) : nullptr;
  }

  explicit JSEventListener(std::shared_ptr<QJSFunction> listener);

  JSValue GetListenerObject(EventTarget&) override;

  JSValue GetEffectiveFunction(EventTarget&) override;

  bool IsJSEventListener() const override { return true; }

  bool Matches(const EventListener& other) const override {
    const auto* other_listener = DynamicTo<JSEventListener>(other);
    return other_listener && *event_listener_ == *other_listener->event_listener_;
  }

 private:
  void InvokeInternal(EventTarget&,
                      Event&,
                      ExceptionState& exception_state) override;

  const std::shared_ptr<QJSFunction> event_listener_;
};

}

#endif  // KRAKENBRIDGE_BINDINGS_QJS_JS_EVENT_LISTENER_H_
