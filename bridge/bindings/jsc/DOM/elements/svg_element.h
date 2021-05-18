/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SVG_ELEMENT_H
#define KRAKENBRIDGE_SVG_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

void bindSVGElement(std::unique_ptr<JSContext> &context);

struct NativeSVGElement;

class JSSVGElement : public JSElement {
public:
  static std::unordered_map<JSContext *, JSSVGElement *> instanceMap;
  OBJECT_INSTANCE(JSSVGElement)
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class SVGElementInstance : public ElementInstance {
  public:

    SVGElementInstance() = delete;
    ~SVGElementInstance();
    explicit SVGElementInstance(JSSVGElement *JSSVGElement);

    NativeSVGElement *nativeSVGElement;

  private:
    JSStringHolder m_data{context, ""};
    JSStringHolder m_type{context, ""};
  };
protected:
  ~JSSVGElement();
  JSSVGElement() = delete;
  explicit JSSVGElement(JSContext *context);
};

struct NativeSVGElement {
  NativeSVGElement() = delete;
  explicit NativeSVGElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_SVG_ELEMENT_H
