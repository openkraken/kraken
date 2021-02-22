/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ANCHOR_ELEMENT_H
#define KRAKENBRIDGE_ANCHOR_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

struct NativeAnchorElement;

class JSAnchorElement : public JSElement {
public:
  OBJECT_INSTANCE(JSAnchorElement);
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class AnchorElementInstance : public ElementInstance {
  public:
    DEFINE_OBJECT_PROPERTY(AnchorElement, 2, href, target)

    AnchorElementInstance() = delete;
    AnchorElementInstance(JSAnchorElement *jsAnchorElement);
    ~AnchorElementInstance();
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeAnchorElement *nativeAnchorElement{nullptr};
  private:
    JSStringRef _href{JSStringCreateWithUTF8CString("")};
    JSStringRef _target {JSStringCreateWithUTF8CString("")};
  };
protected:
  JSAnchorElement() = delete;
  ~JSAnchorElement();
  static std::unordered_map<JSContext *, JSAnchorElement *> instanceMap;
  explicit JSAnchorElement(JSContext *context);
};

struct NativeAnchorElement {
  NativeAnchorElement() = delete;
  explicit NativeAnchorElement(NativeElement *nativeElement) : nativeElement(nativeElement) {};

  NativeElement *nativeElement;
};

}

#endif // KRAKENBRIDGE_ANCHOR_ELEMENT_H
