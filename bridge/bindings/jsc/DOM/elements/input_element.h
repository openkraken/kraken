/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_INPUT_ELEMENT_H
#define KRAKENBRIDGE_INPUT_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

struct NativeInputElement;

void bindInputElement(std::unique_ptr<JSContext> &context);

class JSInputElement : public JSElement {
public:
  static std::unordered_map<JSContext *, JSInputElement *> instanceMap;
  static JSInputElement *instance(JSContext *context);
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;
  static JSValueRef focus(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                          const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef blur(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);

  class InputElementInstance : public ElementInstance {
  public:
    DEFINE_OBJECT_PROPERTY(InputElement, 21, width, height, value, accept, autocomplete, autofocus, checked, disabled,
                           min, max, minlength, maxlength, size, multiple, name, step, pattern, required, readonly,
                           placeholder, type);
    DEFINE_PROTOTYPE_OBJECT_PROPERTY(InputElement, 2, focus, blur);

    InputElementInstance() = delete;
    ~InputElementInstance();
    explicit InputElementInstance(JSInputElement *JSInputElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeInputElement *nativeInputElement;

  private:
  };

protected:
  JSInputElement() = delete;
  explicit JSInputElement(JSContext *context);
  ~JSInputElement();

  JSFunctionHolder m_focus{context, prototypeObject, this, "focus", focus};
  JSFunctionHolder m_blur{context, prototypeObject, this, "blur", blur};
};

using GetInputWidth = double (*)(NativeInputElement *nativeInputElement);
using GetInputHeight = double (*)(NativeInputElement *nativeInputElement);
using InputVoidCallback = void (*)(NativeInputElement *nativeInputElement);

struct NativeInputElement {
  NativeInputElement() = delete;
  explicit NativeInputElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;

  GetInputWidth getInputWidth;
  GetInputHeight getInputHeight;
  InputVoidCallback focus;
  InputVoidCallback blur;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_Input_ELEMENT_H
