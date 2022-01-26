/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_REJECTED_PROMISES_H_
#define KRAKENBRIDGE_BINDINGS_QJS_REJECTED_PROMISES_H_

#include <quickjs/quickjs.h>
#include <memory>
#include <unordered_map>
#include <vector>

namespace kraken::binding::qjs {

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

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_BINDINGS_QJS_REJECTED_PROMISES_H_
