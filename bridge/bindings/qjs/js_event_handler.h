/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_JS_EVENT_HANDLER_H_
#define KRAKENBRIDGE_BINDINGS_QJS_JS_EVENT_HANDLER_H_

#include "js_based_event_listener.h"
#include "foundation/casting.h"

namespace kraken {

// |JSEventHandler| implements EventHandler in the HTML standard.
// https://html.spec.whatwg.org/C/#event-handler-attributes
class JSEventHandler : public JSBasedEventListener {
 public:
  enum class HandlerType {
    kEventHandler,
    // For kOnErrorEventHandler
    // https://html.spec.whatwg.org/C/#onerroreventhandler
    kOnErrorEventHandler,
    // For OnBeforeUnloadEventHandler
    // https://html.spec.whatwg.org/C/#onbeforeunloadeventhandler
    kOnBeforeUnloadEventHandler,
  };

  static std::unique_ptr<JSEventHandler> CreateOrNull(JSContext* ctx, HandlerType handler_type);
  static JSValue ToQuickJS(JSContext* ctx, EventTarget* event_target, EventListener* listener) {
    if (auto* event_handler = DynamicTo<JSEventHandler>(listener)) {
      return event_handler->GetListenerObject(*event_target);
    }
    return JS_NULL;
  }


 private:

};

}

#endif  // KRAKENBRIDGE_BINDINGS_QJS_JS_EVENT_HANDLER_H_
