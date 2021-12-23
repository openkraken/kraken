/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_FOUNDATION_UI_COMMAND_BUFFER_H_
#define KRAKENBRIDGE_FOUNDATION_UI_COMMAND_BUFFER_H_

#include "include/kraken_bridge.h"

namespace foundation {

class UICommandBuffer {
 public:
  UICommandBuffer() = delete;
  explicit UICommandBuffer(int32_t contextId);
  void addCommand(int32_t id, int32_t type, void* nativePtr, bool batchedUpdate);
  void addCommand(int32_t id, int32_t type, void* nativePtr);
  void addCommand(int32_t id, int32_t type, NativeString& args_01, NativeString& args_02, void* nativePtr);
  void addCommand(int32_t id, int32_t type, NativeString& args_01, void* nativePtr);
  UICommandItem* data();
  int64_t size();
  void clear();

 private:
  int32_t contextId;
  std::atomic<bool> update_batched{false};
  std::vector<UICommandItem> queue;
};

}  // namespace foundation

#endif  // KRAKENBRIDGE_FOUNDATION_UI_COMMAND_BUFFER_H_
