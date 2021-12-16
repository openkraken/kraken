/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/protocol/runtime_frontend.h"
#include "inspector/protocol/execution_context_created_notification.h"

namespace kraken {
namespace debugger {
void RuntimeFrontend::bindingCalled(const std::string &name, const std::string &payload, int executionContextId) {
  //            if (!m_frontendChannel)
  //                return;
  //            std::unique_ptr<BindingCalledNotification> messageData = BindingCalledNotification::create()
  //                    .setName(name)
  //                    .setPayload(payload)
  //                    .setExecutionContextId(executionContextId)
  //                    .build();
  //            m_frontendChannel->sendProtocolNotification(InternalResponse::createNotification("Runtime.bindingCalled",
  //            std::move(messageData)));
}

void RuntimeFrontend::consoleAPICalled(const std::string &type,
                                       std::unique_ptr<std::vector<std::unique_ptr<RemoteObject>>> args,
                                       int executionContextId, double timestamp, Maybe<StackTrace> stackTrace,
                                       Maybe<std::string> context) {
  //            if (!m_frontendChannel)
  //                return;
  //            std::unique_ptr<ConsoleAPICalledNotification> messageData = ConsoleAPICalledNotification::create()
  //                    .setType(type)
  //                    .setArgs(std::move(args))
  //                    .setExecutionContextId(executionContextId)
  //                    .setTimestamp(timestamp)
  //                    .build();
  //            if (stackTrace.isJust())
  //                messageData->setStackTrace(std::move(stackTrace).takeJust());
  //            if (context.isJust())
  //                messageData->setContext(std::move(context).takeJust());
  //            m_frontendChannel->sendProtocolNotification(InternalResponse::createNotification("Runtime.consoleAPICalled",
  //            std::move(messageData)));
}

void RuntimeFrontend::exceptionRevoked(const std::string &reason, int exceptionId) {
  //            if (!m_frontendChannel)
  //                return;
  //            std::unique_ptr<ExceptionRevokedNotification> messageData = ExceptionRevokedNotification::create()
  //                    .setReason(reason)
  //                    .setExceptionId(exceptionId)
  //                    .build();
  //            m_frontendChannel->sendProtocolNotification(InternalResponse::createNotification("Runtime.exceptionRevoked",
  //            std::move(messageData)));
}

void RuntimeFrontend::exceptionThrown(double timestamp, std::unique_ptr<ExceptionDetails> exceptionDetails) {
  //            if (!m_frontendChannel)
  //                return;
  //            std::unique_ptr<ExceptionThrownNotification> messageData = ExceptionThrownNotification::create()
  //                    .setTimestamp(timestamp)
  //                    .setExceptionDetails(std::move(exceptionDetails))
  //                    .build();
  //            m_frontendChannel->sendProtocolNotification(InternalResponse::createNotification("Runtime.exceptionThrown",
  //            std::move(messageData)));
}

void RuntimeFrontend::executionContextCreated(std::unique_ptr<ExecutionContextDescription> context) {
  if (!m_frontendChannel) return;
  std::unique_ptr<ExecutionContextCreatedNotification> messageData =
    ExecutionContextCreatedNotification::create().setContext(std::move(context)).build();
  rapidjson::Document doc;
  m_frontendChannel->sendProtocolNotification(
    {"Runtime.executionContextCreated", messageData->toValue(doc.GetAllocator())});
}

void RuntimeFrontend::executionContextDestroyed(int executionContextId) {
  //            if (!m_frontendChannel)
  //                return;
  //            std::unique_ptr<ExecutionContextDestroyedNotification> messageData =
  //            ExecutionContextDestroyedNotification::create()
  //                    .setExecutionContextId(executionContextId)
  //                    .build();
  //            m_frontendChannel->sendProtocolNotification(InternalResponse::createNotification("Runtime.executionContextDestroyed",
  //            std::move(messageData)));
}

void RuntimeFrontend::executionContextsCleared(std::unique_ptr<ExecutionContextDescription> context) {
  if (!m_frontendChannel) return;
  std::unique_ptr<ExecutionContextCreatedNotification> messageData =
      ExecutionContextCreatedNotification::create().setContext(std::move(context)).build();
  rapidjson::Document doc;
  m_frontendChannel->sendProtocolNotification(
      {"Runtime.executionContextCreated", messageData->toValue(doc.GetAllocator())});
}

void RuntimeFrontend::inspectRequested(std::unique_ptr<RemoteObject> object, std::unique_ptr<rapidjson::Value> hints) {
  //            if (!m_frontendChannel)
  //                return;
  //            std::unique_ptr<InspectRequestedNotification> messageData = InspectRequestedNotification::create()
  //                    .setObject(std::move(object))
  //                    .setHints(std::move(hints))
  //                    .build();
  //            m_frontendChannel->sendProtocolNotification(InternalResponse::createNotification("Runtime.inspectRequested",
  //            std::move(messageData)));
}

} // namespace debugger
} // namespace kraken
