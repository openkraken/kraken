/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_FRAGMENT_ELEMENT_H
#define KRAKENBRIDGE_DOCUMENT_FRAGMENT_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

void bindDocumentFragmentElement(std::unique_ptr<JSContext> &context);

struct NativeDocumentFragmentElement;

class JSDocumentFragmentElement : public JSElement {
public:
  static std::unordered_map<JSContext *, JSDocumentFragmentElement *> instanceMap;
  OBJECT_INSTANCE(JSDocumentFragmentElement)
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class DocumentFragmentElementInstance : public ElementInstance {
  public:

    DocumentFragmentElementInstance() = delete;
    ~DocumentFragmentElementInstance();
    explicit DocumentFragmentElementInstance(JSDocumentFragmentElement *JSDocumentFragmentElement);

    NativeDocumentFragmentElement *nativeDocumentFragmentElement;

  private:
    JSStringHolder m_data{context, ""};
    JSStringHolder m_type{context, ""};
  };
protected:
  ~JSDocumentFragmentElement();
  JSDocumentFragmentElement() = delete;
  explicit JSDocumentFragmentElement(JSContext *context);
};

struct NativeDocumentFragmentElement {
  NativeDocumentFragmentElement() = delete;
  explicit NativeDocumentFragmentElement(NativeElement *nativeElement) : nativeElement(nativeElement){};

  NativeElement *nativeElement;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_FRAGMENT_ELEMENT_H
