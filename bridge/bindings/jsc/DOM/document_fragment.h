/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_FRAGMENT_ELEMENT_H
#define KRAKENBRIDGE_DOCUMENT_FRAGMENT_ELEMENT_H

#include "bindings/jsc/DOM/element.h"
#include "bindings/jsc/js_context_internal.h"

namespace kraken::binding::jsc {

void bindDocumentFragment(std::unique_ptr<JSContext> &context);

class JSDocumentFragment : public JSNode {
public:
  static std::unordered_map<JSContext *, JSDocumentFragment *> instanceMap;
  OBJECT_INSTANCE(JSDocumentFragment)
  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class DocumentFragmentInstance : public NodeInstance {
  public:

    DocumentFragmentInstance() = delete;
    ~DocumentFragmentInstance();
    explicit DocumentFragmentInstance(JSDocumentFragment *JSDocumentFragment);

    JSDocumentFragment *nativeDocumentFragment;
  };
protected:
  ~JSDocumentFragment();
  JSDocumentFragment() = delete;
  explicit JSDocumentFragment(JSContext *context);
};


} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_FRAGMENT_ELEMENT_H
