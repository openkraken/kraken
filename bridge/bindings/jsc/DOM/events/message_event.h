/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MESSAGE_EVENT_H
#define KRAKENBRIDGE_MESSAGE_EVENT_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context_internal.h"
#include <unordered_map>
#include <vector>

namespace kraken::binding::jsc {

void bindMessageEvent(std::unique_ptr<JSContext> &context);

struct NativeMessageEvent;

class JSMessageEvent : public JSEvent {
public:
  DEFINE_OBJECT_PROPERTY(MessageEvent, 2, data, origin)
  static std::unordered_map<JSContext *, JSMessageEvent *> instanceMap;
  OBJECT_INSTANCE(JSMessageEvent)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSMessageEvent() = delete;
  ~JSMessageEvent();
  explicit JSMessageEvent(JSContext *context);
};

class MessageEventInstance : public EventInstance {
public:
  MessageEventInstance() = delete;
  explicit MessageEventInstance(JSMessageEvent *jsMessageEvent, NativeMessageEvent *nativeMessageEvent);
  explicit MessageEventInstance(JSMessageEvent *jsMessageEvent, std::string eventType, JSValueRef eventInitValueRef);
  explicit MessageEventInstance(JSMessageEvent *jsMessageEvent, std::string eventType, JSValueRef data, JSValueRef origin);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~MessageEventInstance() override;

  NativeMessageEvent *nativeMessageEvent;

private:
  JSStringHolder m_data{context, ""};
  JSStringHolder m_origin{context, ""};
  int64_t code;
};

struct NativeMessageEvent {
  NativeMessageEvent() = delete;
  explicit NativeMessageEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;

  NativeString *data;
  NativeString *origin;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_MESSAGE_EVENT_H
