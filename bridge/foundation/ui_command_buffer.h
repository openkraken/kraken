/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_FOUNDATION_UI_COMMAND_BUFFER_H_
#define KRAKENBRIDGE_FOUNDATION_UI_COMMAND_BUFFER_H_

#include <vector>
#include <cinttypes>
#include "native_value.h"
#include "bindings/qjs/native_string_utils.h"

namespace kraken {

class ExecutionContext;

enum UICommand {
  createElement,
  createTextNode,
  createComment,
  disposeEventTarget,
  addEvent,
  removeNode,
  insertAdjacentNode,
  setStyle,
  setProperty,
  removeProperty,
  cloneNode,
  removeEvent,
  createDocumentFragment,
};

struct UICommandItem {
  UICommandItem(int32_t id, int32_t type, NativeString args_01, NativeString args_02, void* nativePtr)
    : type(type),
      string_01(reinterpret_cast<int64_t>(args_01.string)),
      args_01_length(args_01.length),
      string_02(reinterpret_cast<int64_t>(args_02.string)),
      args_02_length(args_02.length),
      id(id),
      nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, NativeString args_01, void* nativePtr)
    : type(type), string_01(reinterpret_cast<int64_t>(args_01.string)), args_01_length(args_01.length), id(id), nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, void* nativePtr) : type(type), id(id), nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  int32_t type;
  int32_t id;
  int32_t args_01_length{0};
  int32_t args_02_length{0};
  int64_t string_01{0};
  int64_t string_02{0};
  int64_t nativePtr{0};
};

class UICommandBuffer {
 public:
  UICommandBuffer() = delete;
  explicit UICommandBuffer(ExecutionContext* context);
  void addCommand(int32_t id, int32_t type, void* nativePtr, bool batchedUpdate);
  void addCommand(int32_t id, int32_t type, void* nativePtr);
  void addCommand(int32_t id, int32_t type, NativeString& args_01, NativeString& args_02, void* nativePtr);
  void addCommand(int32_t id, int32_t type, NativeString& args_01, void* nativePtr);
  UICommandItem* data();
  int64_t size();
  void clear();

 private:
  ExecutionContext *m_context{nullptr};
  std::atomic<bool> update_batched{false};
  std::vector<UICommandItem> queue;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_FOUNDATION_UI_COMMAND_BUFFER_H_
