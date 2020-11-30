/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_INPUT_EVENT_H
#define KRAKENBRIDGE_INPUT_EVENT_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context.h"
#include <vector>
#include <unordered_map>

namespace kraken::binding::jsc {

void bindInputEvent(std::unique_ptr<JSContext> &context);

struct NativeInputEvent;

class JSInputEvent : public JSEvent {
public:
  enum class InputEventProperty { kInputType, kData };

  static std::vector<JSStringRef> &getInputEventPropertyNames();
  const static std::unordered_map<std::string, InputEventProperty> &getInputEventPropertyMap();

  static std::unordered_map<JSContext *, JSInputEvent *> &getInstanceMap();
  static JSInputEvent *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSInputEvent() = delete;
  ~JSInputEvent();
  explicit JSInputEvent(JSContext *context);
};

class InputEventInstance : public EventInstance {
public:
  InputEventInstance() = delete;
  explicit InputEventInstance(JSInputEvent *jsInputEvent, NativeInputEvent *nativeInputEvent);
  explicit InputEventInstance(JSInputEvent *jsInputEvent, JSStringRef data, JSValueRef inputEventInit, JSValueRef *exception);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~InputEventInstance() override;

  NativeInputEvent *nativeInputEvent;
private:
  JSStringHolder m_data{context, ""};
  JSStringHolder m_inputType{context, ""};
};

struct NativeInputEvent {
  NativeInputEvent() = delete;
  explicit NativeInputEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;
  NativeString *inputType;
  NativeString *data;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_INPUT_EVENT_H
