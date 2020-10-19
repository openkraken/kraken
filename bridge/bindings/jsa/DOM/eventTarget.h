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
#include "foundation/ui_command_queue.h"
#include "dart_methods.h"
#include <condition_variable>
#include <atomic>

namespace kraken {
namespace binding {
namespace jsa {
using namespace alibaba::jsa;

struct DisposeCallbackData {
  DisposeCallbackData(int32_t contextId, int64_t id) : contextId(contextId), id(id){};
  int64_t id;
  int32_t contextId;
};

class JSEventTarget : public HostObject {
public:
  JSEventTarget() = delete;
  explicit JSEventTarget(JSContext &context);
  ~JSEventTarget() override;

  NativeEventTarget *getEventTarget() {
    return nativeEventTarget;
  }

  Value get(JSContext &, const PropNameID &name) override;

  void set(JSContext &, const PropNameID &name, const Value &value) override;

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

  int64_t getEventTargetId();

private:
  NativeEventTarget *nativeEventTarget{nullptr};
  JSContext &context;
  int64_t eventTargetId;
};

}
}
}

#endif // KRAKENBRIDGE_EVENTTARGET_H
