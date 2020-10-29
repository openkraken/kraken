/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "eventTarget.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

static std::atomic<int64_t> globalEventTargetId{0};

JSEventTarget::JSEventTarget(JSContext *context, const char *name) : HostClass(context, name) {}
JSEventTarget::JSEventTarget(JSContext *context) : HostClass(context, "EventTarget") {}

JSEventTarget::EventTargetInstance::EventTargetInstance(JSEventTarget *eventTarget)
  : Instance(eventTarget) {
  eventTargetId = globalEventTargetId++;
}

JSEventTarget::EventTargetInstance::~EventTargetInstance() {
  // Recycle eventTarget object could be triggered by hosting JSContext been released or reference count set to 0.
  auto data = new DisposeCallbackData(hostClass->context->getContextId(), eventTargetId);
  foundation::Task disposeTask = [](void *data) {
    auto disposeCallbackData = reinterpret_cast<DisposeCallbackData *>(data);
    foundation::UICommandTaskMessageQueue::instance(disposeCallbackData->contextId)
      ->registerCommand(disposeCallbackData->id, UICommandType::disposeEventTarget, nullptr, 0);
    delete disposeCallbackData;
  };
  foundation::UITaskMessageQueue::instance()->registerTask(disposeTask, data);
}

} // namespace kraken::binding::jsc
