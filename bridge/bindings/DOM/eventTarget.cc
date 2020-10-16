/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "eventTarget.h"
#include "dart_methods.h"

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

static std::atomic<int64_t> globalEventTargetId{0};

JSEventTarget::JSEventTarget(JSContext &context) : context(context) {
  eventTargetId = globalEventTargetId++;
}

JSEventTarget::~JSEventTarget() {
  // Recycle eventTarget object could be triggered by hosting JSContext been released or reference count set to 0.
  auto data = new DisposeCallbackData(context.getContextId(), getEventTargetId());
  foundation::Task disposeTask = [](void *data) {
    auto disposeCallbackData = static_cast<DisposeCallbackData *>(data);
    getDartMethod()->disposeEventTarget(disposeCallbackData->contextId, disposeCallbackData->id);
    printf("dispose eventTarget: %lld \n", disposeCallbackData->id);
    delete disposeCallbackData;
  };
  foundation::UITaskMessageQueue::instance()->registerTask(disposeTask, data);
}

Value JSEventTarget::get(JSContext &, const PropNameID &name) {
  return Value::undefined();
}

void JSEventTarget::set(JSContext &, const PropNameID &name, const Value &value) {}

std::vector<PropNameID> JSEventTarget::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> propertyNames;
  return propertyNames;
}

int64_t JSEventTarget::getEventTargetId() {
  return eventTargetId;
}

} // namespace binding
} // namespace kraken
