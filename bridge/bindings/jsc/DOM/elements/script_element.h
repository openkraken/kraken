/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SCRIPT_ELEMENT_H
#define KRAKENBRIDGE_SCRIPT_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

struct NativeScriptElement;

class JSScriptElement : public JSElement {
public:
  OBJECT_INSTANCE(JSScriptElement);
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class ScriptElementInstance : public ElementInstance {
  public:
    DEFINE_OBJECT_PROPERTY(ScriptElement, 1, src)

    ScriptElementInstance() = delete;
    ScriptElementInstance(JSScriptElement *jsScriptElement);
    ~ScriptElementInstance();
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  private:
    JSStringRef _src{JSStringCreateWithUTF8CString("")};
  };
protected:
  JSScriptElement() = delete;
  ~JSScriptElement();
  static std::unordered_map<JSContext *, JSScriptElement *> instanceMap;
  explicit JSScriptElement(JSContext *context);
};

}

#endif // KRAKENBRIDGE_SCRIPT_ELEMENT_H
