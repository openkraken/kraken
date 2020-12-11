/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_INPUT_ELEMENT_H
#define KRAKENBRIDGE_INPUT_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

struct NativeInputElement;

void bindInputElement(std::unique_ptr<JSContext> &context);

class JSInputElement : public JSElement {
public:
  static std::unordered_map<JSContext *, JSInputElement *> &getInstanceMap();
  static JSInputElement *instance(JSContext *context);
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class InputElementInstance : public ElementInstance {
  public:
    enum class InputProperty {
      kWidth,
      kHeight,
      kValue,
      kAccept,
      kAutocomplete,
      kAutofocus,
      kChecked,
      kDisabled,
      kMin,
      kMax,
      kMinlength,
      kMaxlength,
      kSize,
      kMultiple,
      kName,
      kStep,
      kPattern,
      kRequired,
      kReadonly,
      kPlaceholder,
      kType,
    };

    static std::vector<JSStringRef> &getInputElementPropertyNames();
    static const std::unordered_map<std::string, InputProperty> &getInputElementPropertyMap();

    InputElementInstance() = delete;
    ~InputElementInstance();
    explicit InputElementInstance(JSInputElement *JSInputElement);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeInputElement *nativeInputElement;
  };
protected:
  JSInputElement() = delete;
  explicit JSInputElement(JSContext *context);
  ~JSInputElement();
};

using GetInputWidth = double(*)(NativeInputElement *nativeInputElement);
using GetInputHeight = double(*)(NativeInputElement *nativeInputElement);

struct NativeInputElement {
  NativeInputElement() = delete;
  explicit NativeInputElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;

  GetInputWidth getInputWidth;
  GetInputHeight getInputHeight;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_Input_ELEMENT_H
