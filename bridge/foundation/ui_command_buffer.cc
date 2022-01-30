/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_command_buffer.h"
#include "core/dart_methods.h"
#include "core/executing_context.h"

namespace kraken {

UICommandBuffer::UICommandBuffer(ExecutionContext* context) : m_context(context) {}

void UICommandBuffer::addCommand(int32_t id, int32_t type, void* nativePtr, bool batchedUpdate) {
  if (batchedUpdate) {
    m_context->dartMethodPtr()->requestBatchUpdate(m_context->getContextId());
    update_batched = true;
  }

  UICommandItem item{id, type, nativePtr};
  queue.emplace_back(item);
}

void UICommandBuffer::addCommand(int32_t id, int32_t type, void* nativePtr) {
  if (!update_batched) {
#if FLUTTER_BACKEND
    m_context->dartMethodPtr()->requestBatchUpdate(m_context->getContextId());
#endif
    update_batched = true;
  }

  UICommandItem item{id, type, nativePtr};
  queue.emplace_back(item);
}

void UICommandBuffer::addCommand(int32_t id, int32_t type, NativeString& args_01, void* nativePtr) {
  if (!update_batched) {
#if FLUTTER_BACKEND
    m_context->dartMethodPtr()->requestBatchUpdate(m_context->getContextId());
    update_batched = true;
#endif
  }

  UICommandItem item{id, type, args_01, nativePtr};
  queue.emplace_back(item);
}

void UICommandBuffer::addCommand(int32_t id, int32_t type, NativeString& args_01, NativeString& args_02, void* nativePtr) {
#if FLUTTER_BACKEND
  if (!update_batched) {
    m_context->dartMethodPtr()->requestBatchUpdate(m_context->getContextId());
    update_batched = true;
  }
#endif
  UICommandItem item{id, type, args_01, args_02, nativePtr};
  queue.emplace_back(item);
}

UICommandItem* UICommandBuffer::data() {
  return queue.data();
}

int64_t UICommandBuffer::size() {
  return queue.size();
}

void UICommandBuffer::clear() {
  for (auto command : queue) {
    delete[] reinterpret_cast<const uint16_t*>(command.string_01);
    delete[] reinterpret_cast<const uint16_t*>(command.string_02);
  }
  queue.clear();
  update_batched = false;
}

}  // namespace kraken
