/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "rejected_promises.h"
#include "executing_context.h"

namespace kraken::binding::qjs {

RejectedPromises::Message::Message(ExecutionContext* context, JSValue promise, JSValue reason)
    : m_runtime(context->runtime()), m_promise(JS_DupValue(context->ctx(), promise)), m_reason(JS_DupValue(context->ctx(), reason)) {}

RejectedPromises::Message::~Message() {
  JS_FreeValueRT(m_runtime, m_promise);
  JS_FreeValueRT(m_runtime, m_reason);
}

void RejectedPromises::trackUnhandledPromiseRejection(ExecutionContext* context, JSValue promise, JSValue reason) {
  void* ptr = JS_VALUE_GET_PTR(promise);
  if (m_unhandledRejections.count(ptr) == 0) {
    m_unhandledRejections[ptr] = std::make_unique<Message>(context, promise, reason);
  }
  // One promise will never have more than one unhandled rejection.
}

void RejectedPromises::trackHandledPromiseRejection(ExecutionContext* context, JSValue promise, JSValue reason) {
  void* ptr = JS_VALUE_GET_PTR(promise);

  // Unhandled promise are handled in a sync script call. It's file so we remove the recording of this promise.
  if (m_unhandledRejections.count(ptr) > 0) {
    m_unhandledRejections.erase(ptr);
  } else {
    // This promise are handled in the next script call, we save this operation to trigger handledRejection event.
    m_reportHandledRejection.push_back(std::make_unique<Message>(context, promise, reason));
  }
}

void RejectedPromises::process(ExecutionContext* context) {
  // Copy m_unhandledRejections to avoid endless recursion call.
  std::unordered_map<void*, std::unique_ptr<Message>> unhandledRejections;
  for (auto& entry : m_unhandledRejections) {
    unhandledRejections[entry.first] = std::unique_ptr<Message>(m_unhandledRejections[entry.first].release());
  }
  m_unhandledRejections.clear();

  // Copy m_reportHandledRejection to avoid endless recursion call.
  std::vector<std::unique_ptr<Message>> reportHandledRejection;
  reportHandledRejection.reserve(reportHandledRejection.size());
  for (auto& entry : m_reportHandledRejection) {
    reportHandledRejection.push_back(std::unique_ptr<Message>(entry.release()));
  }
  m_reportHandledRejection.clear();

  // Dispatch unhandled rejectionEvents.
  for (auto& entry : unhandledRejections) {
    context->reportError(entry.second->m_reason);
    context->dispatchGlobalUnhandledRejectionEvent(context, entry.second->m_promise, entry.second->m_reason);
  }

  // Dispatch handledRejection events.
  for (auto& entry : reportHandledRejection) {
    context->dispatchGlobalRejectionHandledEvent(context, entry->m_promise, entry->m_reason);
  }
}

}  // namespace kraken::binding::qjs
