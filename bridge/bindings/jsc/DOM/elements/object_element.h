/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_OBJECT_ELEMENT_H
#define KRAKENBRIDGE_OBJECT_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

struct NativeObjectElement;

class JSObjectElement : public JSElement {
public:
  static std::unordered_map<JSContext *, JSObjectElement *> instanceMap;
  OBJECT_INSTANCE(JSObjectElement)
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class ObjectElementInstance : public ElementInstance {
  public:
    DEFINE_OBJECT_PROPERTY(ObjectElement, 4, type, data, currentData, currentType)

    ObjectElementInstance() = delete;
    ~ObjectElementInstance();
    explicit ObjectElementInstance(JSObjectElement *JSObjectElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeObjectElement *nativeObjectElement;

  private:
    JSStringHolder m_data{context, ""};
    JSStringHolder m_type{context, ""};
  };
protected:
  ~JSObjectElement();
  JSObjectElement() = delete;
  explicit JSObjectElement(JSContext *context);
};

struct NativeObjectElement {
  NativeObjectElement() = delete;
  explicit NativeObjectElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_OBJECT_ELEMENT_H
