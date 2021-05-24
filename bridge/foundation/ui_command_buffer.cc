/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "dart_methods.h"
#include "include/kraken_bridge.h"

namespace foundation {

UICommandBuffer::UICommandBuffer(int32_t contextId) : contextId(contextId) {}

void UICommandBuffer::addCommand(int32_t id, int32_t type, void *nativePtr, bool batchedUpdate) {
  if (batchedUpdate) {
    kraken::getDartMethod()->requestBatchUpdate(contextId);
    update_batched = true;
  }

  UICommandItem item{id, type, nativePtr};
  queue.emplace_back(item);
}

void UICommandBuffer::addCommand(int32_t id, int32_t type, void *nativePtr) {
  if (!update_batched) {
    kraken::getDartMethod()->requestBatchUpdate(contextId);
    update_batched = true;
  }

  UICommandItem item{id, type, nativePtr};
  queue.emplace_back(item);
}

void UICommandBuffer::addCommand(int32_t id, int32_t type, NativeString &args_01, void *nativePtr) {
  if (!update_batched) {
    kraken::getDartMethod()->requestBatchUpdate(contextId);
    update_batched = true;
  }

  UICommandItem item{id, type, args_01, nativePtr};
  queue.emplace_back(item);
}

void UICommandBuffer::addCommand(int32_t id, int32_t type, NativeString &args_01, NativeString &args_02,
                                                void *nativePtr) {
  if (!update_batched) {
    kraken::getDartMethod()->requestBatchUpdate(contextId);
    update_batched = true;
  }
  UICommandItem item{id, type, args_01, args_02, nativePtr};
  queue.emplace_back(item);
}

UICommandBuffer *UICommandBuffer::instance(int32_t contextId) {
  static std::unordered_map<int32_t, UICommandBuffer *> instanceMap;

  if (instanceMap.count(contextId) == 0) {
    instanceMap[contextId] = new UICommandBuffer(contextId);
  }

  return instanceMap[contextId];
}

UICommandItem *UICommandBuffer::data() {
  return queue.data();
}

int64_t UICommandBuffer::size() {
  return queue.size();
}

void UICommandBuffer::clear() {
  for (auto command : queue) {
    delete[] reinterpret_cast<const uint16_t *>(command.string_01);
    delete[] reinterpret_cast<const uint16_t *>(command.string_02);
  }
  queue.clear();
  update_batched = false;
}

} // namespace foundation
