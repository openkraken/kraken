/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEMPLATE_ELEMENT_H
#define KRAKENBRIDGE_TEMPLATE_ELEMENT_H

#include "bindings/jsc/DOM/document_fragment.h"
#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

struct NativeTemplateElement {
  NativeTemplateElement() = delete;
  NativeTemplateElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;
};

void bindTemplateElement(std::unique_ptr<JSContext> &context);

class JSTemplateElement : public JSElement {
public:
  DEFINE_OBJECT_PROPERTY(TemplateElement, 2, content, innerHTML);
  static std::unordered_map<JSContext *, JSTemplateElement *> instanceMap;
  OBJECT_INSTANCE(JSTemplateElement)
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class TemplateElementInstance : public ElementInstance {
    public:
      TemplateElementInstance() = delete;
      ~TemplateElementInstance();
      explicit TemplateElementInstance(JSTemplateElement *JSTemplateElement);
      JSValueRef getProperty(std::string &name, JSValueRef *exception);
      bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception);

      NativeTemplateElement *nativeTemplateElement;

    private:
      JSDocumentFragment::DocumentFragmentInstance* m_content;
    };

    protected:
      ~JSTemplateElement();
      JSTemplateElement() = delete;
      explicit JSTemplateElement(JSContext *context);
    };

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_TEMPLATE_ELEMENT_H
