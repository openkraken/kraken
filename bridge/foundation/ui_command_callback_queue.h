/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_UI_COMMAND_CALLBACK_QUEUE_H
#define KRAKENBRIDGE_UI_COMMAND_CALLBACK_QUEUE_H

#include "closure.h"
#include "include/kraken_bridge.h"
#include "logging.h"
#include <unordered_map>
#include <vector>

namespace foundation {

// An un thread safe queue used for dart side to read ui command items.
class UICommandCallbackQueue {
public:
  using Callback = void(*)(void*);
  UICommandCallbackQueue() = default;

  static UICommandCallbackQueue *instance(int32_t contextId);
  void registerCallback(const Callback &callback, void *data);
  void flushCallbacks();
private:
  struct CallbackItem {
    CallbackItem(const Callback &callback, void *data): callback(callback), data(data) {};
    Callback callback;
    void *data;
  };

  std::vector<CallbackItem> queue;
};

} // namespace foundation

#endif // KRAKENBRIDGE_UI_COMMAND_CALLBACK_QUEUE_H
