/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_FOUNDATION_H
#define KRAKENBRIDGE_FOUNDATION_H

#include "kraken_bridge_jsc_config.h"
#include <cstdint>
#include <unordered_map>
#include <vector>

#define KRAKEN_DISALLOW_COPY(TypeName) TypeName(const TypeName &) = delete

#define KRAKEN_DISALLOW_ASSIGN(TypeName) TypeName &operator=(const TypeName &) = delete

#define KRAKEN_DISALLOW_MOVE(TypeName)                                                                                 \
  TypeName(TypeName &&) = delete;                                                                                      \
  TypeName &operator=(TypeName &&) = delete

#define KRAKEN_DISALLOW_COPY_AND_ASSIGN(TypeName)                                                                         \
  TypeName(const TypeName &) = delete;                                                                                 \
  TypeName &operator=(const TypeName &) = delete

#define KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName)                                                                    \
  TypeName(const TypeName &) = delete;                                                                                 \
  TypeName(TypeName &&) = delete;                                                                                      \
  TypeName &operator=(const TypeName &) = delete;                                                                      \
  TypeName &operator=(TypeName &&) = delete

#define KRAKEN_DISALLOW_IMPLICIT_CONSTRUCTORS(TypeName)                                                                   \
  TypeName() = delete;                                                                                                 \
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName)

struct NativeString;
struct UICommandItem;

namespace foundation {

// An un thread safe queue used for dart side to read ui command items.
class UICommandCallbackQueue {
public:
  using Callback = void (*)(void *);
  UICommandCallbackQueue() = default;
  static KRAKEN_EXPORT UICommandCallbackQueue *instance();
  KRAKEN_EXPORT void registerCallback(const Callback &callback, void *data);
  KRAKEN_EXPORT void flushCallbacks();

private:
  struct CallbackItem {
    CallbackItem(const Callback &callback, void *data) : callback(callback), data(data){};
    Callback callback;
    void *data;
  };

  std::vector<CallbackItem> queue;
};

class UICommandTaskMessageQueue {
public:
  UICommandTaskMessageQueue() = delete;
  explicit UICommandTaskMessageQueue(int32_t contextId);
  static KRAKEN_EXPORT UICommandTaskMessageQueue *instance(int32_t contextId);

  KRAKEN_EXPORT void registerCommand(int32_t id, int32_t type, void *nativePtr, bool batchedUpdate);
  KRAKEN_EXPORT void registerCommand(int32_t id, int32_t type, void *nativePtr);
  KRAKEN_EXPORT void registerCommand(int32_t id, int32_t type, NativeString &args_01, NativeString &args_02, void *nativePtr);
  KRAKEN_EXPORT void registerCommand(int32_t id, int32_t type, NativeString &args_01, void *nativePtr);
  KRAKEN_EXPORT UICommandItem *data();
  KRAKEN_EXPORT int64_t size();
  KRAKEN_EXPORT void clear();

private:
  int32_t contextId;
  std::atomic<bool> update_batched{false};
  std::vector<UICommandItem> queue;
};

} // namespace foundation

#endif
