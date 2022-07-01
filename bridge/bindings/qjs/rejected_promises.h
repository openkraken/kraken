/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_REJECTED_PROMISES_H_
#define KRAKENBRIDGE_BINDINGS_QJS_REJECTED_PROMISES_H_

#include <quickjs/quickjs.h>
#include <memory>
#include <unordered_map>
#include <vector>

namespace kraken {

class ExecutingContext;

class RejectedPromises {
 public:
  class Message {
   public:
    Message(ExecutingContext* context, JSValue promise, JSValue reason);
    ~Message();

    JSRuntime* m_runtime{nullptr};
    JSValue m_promise{JS_NULL};
    JSValue m_reason{JS_NULL};
  };

  // Keeping track unhandled promise rejection in current context, and throw unhandledRejection error
  void TrackUnhandledPromiseRejection(ExecutingContext* context, JSValue promise, JSValue reason);
  // When unhandled promise are handled in the future, should trigger a handledRejection event.
  void TrackHandledPromiseRejection(ExecutingContext* context, JSValue promise, JSValue reason);
  // Trigger events after promise executed.
  void Process(ExecutingContext* context);

 private:
  std::unordered_map<void*, std::unique_ptr<Message>> unhandled_rejections_;
  std::vector<std::unique_ptr<Message>> report_handled_rejection_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_REJECTED_PROMISES_H_
