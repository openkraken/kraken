/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENTTARGET_H
#define KRAKENBRIDGE_EVENTTARGET_H

#include "jsa.h"
#include "include/kraken_bridge.h"
#include "foundation/logging.h"
#include "foundation/ui_task_queue.h"
#include <condition_variable>
#include <mutex>
#include <iostream>

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

struct DisposeCallbackData {
  DisposeCallbackData(NativeEventTarget *target, int32_t id): nativeEventTarget(target), contextId(id) {};
  NativeEventTarget *nativeEventTarget;
  int32_t contextId;
};

class JSEventTarget : public HostObject {
public:
  JSEventTarget() = delete;
  explicit JSEventTarget(JSContext &context);
  ~JSEventTarget() override {
    // Recycle eventTarget object could be triggered by hosting JSContext been released or reference count set to 0.
    if (context.isValid() && nativeEventTarget != nullptr) {
      auto data = new DisposeCallbackData(nativeEventTarget, context.getContextId());
      foundation::Task disposeTask = [](void *data) {
        auto disposeCallbackData = static_cast<DisposeCallbackData*>(data);
        disposeCallbackData->nativeEventTarget->dispose(disposeCallbackData->contextId, disposeCallbackData->nativeEventTarget);
        delete disposeCallbackData;
      };
      foundation::UITaskMessageQueue::instance()->registerTask(disposeTask, data);
    }
  }

  NativeEventTarget* getEventTarget() { return nativeEventTarget; }

  Value get(JSContext &, const PropNameID &name) override;

  void set(JSContext &, const PropNameID &name, const Value &value) override;

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

private:
  NativeEventTarget *nativeEventTarget {nullptr};
  JSContext &context;
};

}
}

#endif // KRAKENBRIDGE_EVENTTARGET_H
