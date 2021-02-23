/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MEDIA_ERROR_EVENT_H
#define KRAKENBRIDGE_MEDIA_ERROR_EVENT_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context_internal.h"
#include <unordered_map>
#include <vector>

namespace kraken::binding::jsc {

void bindMediaErrorEvent(std::unique_ptr<JSContext> &context);

struct NativeMediaErrorEvent;

class JSMediaErrorEvent : public JSEvent {
public:
  DEFINE_OBJECT_PROPERTY(MediaError, 2, code, message)
  static std::unordered_map<JSContext *, JSMediaErrorEvent *> instanceMap;
  OBJECT_INSTANCE(JSMediaErrorEvent)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSMediaErrorEvent() = delete;
  ~JSMediaErrorEvent();
  explicit JSMediaErrorEvent(JSContext *context);
};

class MediaErrorEventInstance : public EventInstance {
public:
  MediaErrorEventInstance() = delete;
  explicit MediaErrorEventInstance(JSMediaErrorEvent *jSMediaErrorEvent, NativeMediaErrorEvent *nativeMediaErrorEvent);
  explicit MediaErrorEventInstance(JSMediaErrorEvent *jsMediaErrorEvent, JSStringRef data);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~MediaErrorEventInstance() override;

  NativeMediaErrorEvent *nativeMediaErrorEvent;

private:
  JSStringHolder m_message{context, ""};
  int64_t code;
};

struct NativeMediaErrorEvent {
  NativeMediaErrorEvent() = delete;
  explicit NativeMediaErrorEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;

  int64_t code {0};
  NativeString *message {nullptr};
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_MEDIA_ERROR_EVENT_H
