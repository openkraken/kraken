/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_OBJECT_ELEMENT_H
#define KRAKENBRIDGE_OBJECT_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

struct NativeObjectElement;

class JSObjectElement : public JSElement {
public:
  static JSObjectElement *instance(JSContext *context);
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class ObjectElementInstance : public ElementInstance {
  public:
    enum class ObjectProperty {
      kType,
      kData,
      kCurrentData,
      kCurrentType
    };

    static std::vector<JSStringRef> &getObjectElementPropertyNames();
    static const std::unordered_map<std::string, ObjectProperty> &getObjectElementPropertyMap();

    ObjectElementInstance() = delete;
    ~ObjectElementInstance();
    explicit ObjectElementInstance(JSObjectElement *JSObjectElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeObjectElement *nativeObjectElement;

  private:
    JSStringRef _data{nullptr};
    JSStringRef _type{nullptr};
  };
protected:
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
