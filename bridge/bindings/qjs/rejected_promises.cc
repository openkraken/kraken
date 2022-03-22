/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "rejected_promises.h"
#include "core/executing_context.h"

namespace kraken {

RejectedPromises::Message::Message(ExecutingContext* context, JSValue promise, JSValue reason)
    : m_runtime(context->runtime()), m_promise(JS_DupValue(context->ctx(), promise)), m_reason(JS_DupValue(context->ctx(), reason)) {}

RejectedPromises::Message::~Message() {
  JS_FreeValueRT(m_runtime, m_promise);
  JS_FreeValueRT(m_runtime, m_reason);
}

void RejectedPromises::TrackUnhandledPromiseRejection(ExecutingContext* context, JSValue promise, JSValue reason) {
  void* ptr = JS_VALUE_GET_PTR(promise);
  if (unhandled_rejections_.count(ptr) == 0) {
    unhandled_rejections_[ptr] = std::make_unique<Message>(context, promise, reason);
  }
  // One promise will never have more than one unhandled rejection.
}

void RejectedPromises::TrackHandledPromiseRejection(ExecutingContext* context, JSValue promise, JSValue reason) {
  void* ptr = JS_VALUE_GET_PTR(promise);

  // Unhandled promise are handled in a sync script call. It's file so we remove the recording of this promise.
  if (unhandled_rejections_.count(ptr) > 0) {
    unhandled_rejections_.erase(ptr);
  } else {
    // This promise are handled in the next script call, we save this operation to trigger handledRejection event.
    report_handled_rejection_.push_back(std::make_unique<Message>(context, promise, reason));
  }
}

void RejectedPromises::Process(ExecutingContext* context) {
  // Copy m_unhandledRejections to avoid endless recursion call.
  std::unordered_map<void*, std::unique_ptr<Message>> unhandledRejections;
  for (auto& entry : unhandled_rejections_) {
    unhandledRejections[entry.first] = std::unique_ptr<Message>(unhandled_rejections_[entry.first].release());
  }
  unhandled_rejections_.clear();

  // Copy m_reportHandledRejection to avoid endless recursion call.
  std::vector<std::unique_ptr<Message>> reportHandledRejection;
  reportHandledRejection.reserve(reportHandledRejection.size());
  for (auto& entry : report_handled_rejection_) {
    reportHandledRejection.push_back(std::unique_ptr<Message>(entry.release()));
  }
  report_handled_rejection_.clear();

  // Dispatch unhandled rejectionEvents.
  for (auto& entry : unhandledRejections) {
    context->ReportError(entry.second->m_reason);
    context->DispatchGlobalUnhandledRejectionEvent(context, entry.second->m_promise, entry.second->m_reason);
  }

  // Dispatch handledRejection events.
  for (auto& entry : reportHandledRejection) {
    context->DispatchGlobalRejectionHandledEvent(context, entry->m_promise, entry->m_reason);
  }
}

}  // namespace kraken
