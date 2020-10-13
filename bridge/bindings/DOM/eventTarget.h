/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENTTARGET_H
#define KRAKENBRIDGE_EVENTTARGET_H

#include "jsa.h"
#include "include/kraken_bridge.h"
#include "foundation/logging.h"
#include <condition_variable>
#include <mutex>

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

class JSEventTarget : public HostObject {
public:
  JSEventTarget() = delete;
  explicit JSEventTarget(JSContext &context);
  ~JSEventTarget() override {
    // Recycle eventTarget object could be triggered by hosting JSContext been released or reference count set to 0.
    if (context.isValid() && std::this_thread::get_id() == getUIThreadId()) {
      KRAKEN_LOG(VERBOSE) << "thread: " << std::this_thread::get_id() << "uiThread: " << getUIThreadId() <<  std::endl;
      std::mutex mutex;
      std::unique_lock<std::mutex> lock(mutex);
      nativeEventTarget->dispose(context.getContextId(), nativeEventTarget);
    }
  }

  NativeEventTarget* getEventTarget() { return nativeEventTarget; }

  Value get(JSContext &, const PropNameID &name) override;

  void set(JSContext &, const PropNameID &name, const Value &value) override;

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

private:
  NativeEventTarget * nativeEventTarget;
  JSContext &context;
};

}
}

#endif // KRAKENBRIDGE_EVENTTARGET_H
