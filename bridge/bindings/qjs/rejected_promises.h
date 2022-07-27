/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_REJECTED_PROMISES_H_
#define BRIDGE_BINDINGS_QJS_REJECTED_PROMISES_H_

#include <quickjs/quickjs.h>
#include <memory>
#include <unordered_map>
#include <vector>

namespace webf::binding::qjs {

class ExecutionContext;

class RejectedPromises {
 public:
  class Message {
   public:
    Message(ExecutionContext* context, JSValue promise, JSValue reason);
    ~Message();

    JSRuntime* m_runtime{nullptr};
    JSValue m_promise{JS_NULL};
    JSValue m_reason{JS_NULL};
  };

  // Keeping track unhandled promise rejection in current context, and throw unhandledRejection error
  void trackUnhandledPromiseRejection(ExecutionContext* context, JSValue promise, JSValue reason);
  // When unhandled promise are handled in the future, should trigger a handledRejection event.
  void trackHandledPromiseRejection(ExecutionContext* context, JSValue promise, JSValue reason);
  // Trigger events after promise executed.
  void process(ExecutionContext* context);

 private:
  std::unordered_map<void*, std::unique_ptr<Message>> m_unhandledRejections;
  std::vector<std::unique_ptr<Message>> m_reportHandledRejection;
};

}  // namespace webf::binding::qjs

#endif  // BRIDGE_BINDINGS_QJS_REJECTED_PROMISES_H_
