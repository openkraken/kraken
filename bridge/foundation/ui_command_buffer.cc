/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

#include "ui_command_buffer.h"
#include "core/dart_methods.h"
#include "core/executing_context.h"

namespace kraken {

UICommandBuffer::UICommandBuffer(ExecutingContext* context) : context_(context) {
  queue.reserve(0);
}

void UICommandBuffer::addCommand(int32_t id, UICommand type, void* nativePtr) {
  UICommandItem item{id, static_cast<int32_t>(type), nativePtr};
  queue.emplace_back(item);
}

void UICommandBuffer::addCommand(int32_t id, UICommand type, NativeString* args_01, void* nativePtr) {
  assert(args_01 != nullptr);
  UICommandItem item{id, static_cast<int32_t>(type), args_01, nativePtr};
  queue.emplace_back(item);
}

void UICommandBuffer::addCommand(int32_t id,
                                 UICommand type,
                                 NativeString* args_01,
                                 NativeString* args_02,
                                 void* nativePtr) {
  assert(args_01 != nullptr);
  assert(args_02 != nullptr);
  UICommandItem item{id, static_cast<int32_t>(type), args_01, args_02, nativePtr};
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
}

}  // namespace kraken
