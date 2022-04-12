/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_H
#define KRAKENBRIDGE_JS_CONTEXT_H

#include <quickjs/list.h>
#include <quickjs/quickjs.h>
#include <atomic>
#include <cassert>
#include <cmath>
#include <cstring>
#include <locale>
#include <memory>
#include <mutex>
#include <unordered_map>
#include "bindings/qjs/binding_initializer.h"
#include "bindings/qjs/pending_promises.h"
#include "bindings/qjs/rejected_promises.h"
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/script_wrappable.h"
#include "foundation/macros.h"
#include "foundation/ui_command_buffer.h"

#include "dart_methods.h"
#include "executing_context_data.h"
#include "frame/dom_timer_coordinator.h"
#include "frame/module_callback_coordinator.h"
#include "frame/module_listener_container.h"
#include "script_state.h"

namespace kraken {

struct NativeByteCode {
  uint8_t* bytes;
  int32_t length;
};

class ExecutingContext;
class Document;

using JSExceptionHandler = std::function<void(ExecutingContext* context, const char* message)>;

bool isContextValid(int32_t contextId);

// An environment in which script can execute. This class exposes the common
// properties of script execution environments on the kraken.
// Window : Document : ExecutionContext = 1 : 1 : 1 at any point in time.
class ExecutingContext {
 public:
  ExecutingContext() = delete;
  ExecutingContext(int32_t contextId, const JSExceptionHandler& handler, void* owner);
  ~ExecutingContext();

  static ExecutingContext* From(JSContext* ctx);

  bool EvaluateJavaScript(const uint16_t* code, size_t codeLength, const char* sourceURL, int startLine);
  bool EvaluateJavaScript(const char16_t* code, size_t length, const char* sourceURL, int startLine);
  bool EvaluateJavaScript(const char* code, size_t codeLength, const char* sourceURL, int startLine);
  bool EvaluateByteCode(uint8_t* bytes, size_t byteLength);
  bool IsValid() const;
  JSValue Global();
  JSContext* ctx();
  FORCE_INLINE int32_t contextId() const { return context_id_; };
  void* owner();
  bool HandleException(JSValue* exc);
  bool HandleException(ScriptValue* exc);
  void ReportError(JSValueConst error);
  void DrainPendingPromiseJobs();
  void DefineGlobalProperty(const char* prop, JSValueConst value);
  ExecutionContextData* contextData();
  uint8_t* DumpByteCode(const char* code, uint32_t codeLength, const char* sourceURL, size_t* bytecodeLength);

  // Gets the DOMTimerCoordinator which maintains the "active timer
  // list" of tasks created by setTimeout and setInterval. The
  // DOMTimerCoordinator is owned by the ExecutionContext and should
  // not be used after the ExecutionContext is destroyed.
  DOMTimerCoordinator* Timers();

  // Gets the ModuleListeners which registered by `kraken.addModuleListener API`.
  ModuleListenerContainer* ModuleListeners();

  // Gets the ModuleCallbacks which from the 4th parameter of `kraken.invokeModule` function.
  ModuleCallbackCoordinator* ModuleCallbacks();

  // Get all pending promises which are not resolved or rejected.
  PendingPromises* GetPendingPromises() { return &pending_promises_; };

  // Get current script state.
  ScriptState* GetScriptState() { return &script_state_; }

  FORCE_INLINE Document* document() { return document_; };
  FORCE_INLINE UICommandBuffer* uiCommandBuffer() { return &ui_command_buffer_; };
  FORCE_INLINE std::unique_ptr<DartMethodPointer>& dartMethodPtr() { return dart_method_ptr_; }

  std::chrono::time_point<std::chrono::system_clock> time_origin_;

  int32_t unique_id_;
  struct list_head node_job_list;
  struct list_head module_job_list;
  struct list_head module_callback_job_list;

  static void DispatchGlobalUnhandledRejectionEvent(ExecutingContext* context,
                                                    JSValueConst promise,
                                                    JSValueConst error);
  static void DispatchGlobalRejectionHandledEvent(ExecutingContext* context, JSValueConst promise, JSValueConst error);
  static void DispatchGlobalErrorEvent(ExecutingContext* context, JSValueConst error);

  // Bytecodes which registered by kraken plugins.
  static std::unordered_map<std::string, NativeByteCode> pluginByteCode;

 private:
  static void promiseRejectTracker(JSContext* ctx,
                                   JSValueConst promise,
                                   JSValueConst reason,
                                   JS_BOOL is_handled,
                                   void* opaque);

  // From C++ standard, https://isocpp.org/wiki/faq/dtors#order-dtors-for-members
  // Members first initialized and destructed at the last.
  // Always keep ScriptState at the top of all stack allocated members to make sure it destructed in the last.
  ScriptState script_state_;

  int32_t context_id_;
  JSExceptionHandler handler_;
  void* owner_;
  JSValue global_object_{JS_NULL};
  bool ctx_invalid_{false};
  Document* document_{nullptr};
  DOMTimerCoordinator timers_;
  ModuleListenerContainer module_listener_container_;
  ModuleCallbackCoordinator module_callbacks_;
  ExecutionContextData context_data_{this};
  UICommandBuffer ui_command_buffer_{this};
  std::unique_ptr<DartMethodPointer> dart_method_ptr_ = std::make_unique<DartMethodPointer>();
  RejectedPromises rejected_promises_;
  PendingPromises pending_promises_;
};

class ObjectProperty {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(ObjectProperty);

 public:
  ObjectProperty() = delete;

  // Define an property on object with a JSValue.
  explicit ObjectProperty(ExecutingContext* context, JSValueConst thisObject, const char* property, JSValue value)
      : m_value(value) {
    JS_DefinePropertyValueStr(context->ctx(), thisObject, property, value, JS_PROP_ENUMERABLE);
  }

  JSValue value() const { return m_value; }

 private:
  JSValue m_value{JS_NULL};
};

std::unique_ptr<ExecutingContext> createJSContext(int32_t contextId, const JSExceptionHandler& handler, void* owner);

// JS array operation utilities.
void arrayPushValue(JSContext* ctx, JSValue array, JSValue val);
void arrayInsert(JSContext* ctx, JSValue array, uint32_t start, JSValue targetValue);
int32_t arrayGetLength(JSContext* ctx, JSValue array);
int32_t arrayFindIdx(JSContext* ctx, JSValue array, JSValue target);
void arraySpliceValue(JSContext* ctx, JSValue array, uint32_t start, uint32_t deleteCount);
void arraySpliceValue(JSContext* ctx, JSValue array, uint32_t start, uint32_t deleteCount, JSValue replacedValue);

// JS object operation utilities.
JSValue objectGetKeys(JSContext* ctx, JSValue obj);

}  // namespace kraken

#endif  // KRAKENBRIDGE_JS_CONTEXT_H
