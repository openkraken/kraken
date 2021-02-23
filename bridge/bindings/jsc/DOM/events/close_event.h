/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CLOSE_EVENT_H
#define KRAKENBRIDGE_CLOSE_EVENT_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context_internal.h"
#include <unordered_map>
#include <vector>

namespace kraken::binding::jsc {

void bindCloseEvent(std::unique_ptr<JSContext> &context);

struct NativeCloseEvent;

class JSCloseEvent : public JSEvent {
public:
  DEFINE_OBJECT_PROPERTY(CloseEvent, 3, code, reason, wasClean)

  static std::unordered_map<JSContext *, JSCloseEvent *> instanceMap;
  OBJECT_INSTANCE(JSCloseEvent)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSCloseEvent() = delete;
  ~JSCloseEvent();
  explicit JSCloseEvent(JSContext *context);
};

class CloseEventInstance : public EventInstance {
public:
  CloseEventInstance() = delete;
  explicit CloseEventInstance(JSCloseEvent *jsCloseEvent, NativeCloseEvent *nativeCloseEvent);
  explicit CloseEventInstance(JSCloseEvent *jsCloseEvent, JSStringRef data, JSValueRef closeEventInit, JSValueRef *exception);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~CloseEventInstance() override;

  NativeCloseEvent *nativeCloseEvent;

private:
  double code;
  bool wasClean;
  JSStringHolder m_reason{context, ""};
};

struct NativeCloseEvent {
  NativeCloseEvent() = delete;
  explicit NativeCloseEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;
  int64_t code;
  NativeString *reason;
  int64_t wasClean;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_CLOSE_EVENT_H
