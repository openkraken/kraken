/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "eventTarget.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

static std::atomic<int64_t> globalEventTargetId{0};

JSEventTarget::JSEventTarget(std::unique_ptr<JSContext> &context, const char *name) : HostObject(context, name) {
  eventTargetId = globalEventTargetId++;
}
JSEventTarget::JSEventTarget(std::unique_ptr<JSContext> &context) : HostObject(context, "EventTarget") {
  eventTargetId = globalEventTargetId++;
}

JSEventTarget::~JSEventTarget() {
  // Recycle eventTarget object could be triggered by hosting JSContext been released or reference count set to 0.
  auto data = new DisposeCallbackData(context->getContextId(), getEventTargetId());
  foundation::Task disposeTask = [](void *data) {
    auto disposeCallbackData = reinterpret_cast<DisposeCallbackData *>(data);
    foundation::UICommandTaskMessageQueue::instance(disposeCallbackData->contextId)
      ->registerCommand(disposeCallbackData->id, UICommandType::disposeEventTarget, nullptr, 0);
    delete disposeCallbackData;
  };
  foundation::UITaskMessageQueue::instance()->registerTask(disposeTask, data);
}

int64_t JSEventTarget::getEventTargetId() {
  return eventTargetId;
}

} // namespace kraken::binding::jsc
