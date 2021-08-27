/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document_fragment.h"

namespace kraken::binding::jsc {

void bindDocumentFragmentElement(std::unique_ptr<JSContext> &context) {
  auto DocumentFragmentElement = JSDocumentFragmentElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "DocumentFragmentElement", DocumentFragmentElement->classObject);
}

std::unordered_map<JSContext *, JSDocumentFragmentElement *> JSDocumentFragmentElement::instanceMap{};

JSDocumentFragmentElement::~JSDocumentFragmentElement() {
  instanceMap.erase(context);
}

JSDocumentFragmentElement::JSDocumentFragmentElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSDocumentFragmentElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new DocumentFragmentElementInstance(this);
  return instance->object;
}

JSDocumentFragmentElement::DocumentFragmentElementInstance::DocumentFragmentElementInstance(JSDocumentFragmentElement *jsDocumentFragmentElement)
  : ElementInstance(jsDocumentFragmentElement, "documentfragment", false), nativeDocumentFragmentElement(new NativeDocumentFragmentElement(nativeElement)) {
  std::string tagName = "documentfragment";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  foundation::UICommandBuffer::instance(context->getContextId())
    ->addCommand(eventTargetId, UICommand::createElement, args_01, nativeDocumentFragmentElement);
}

JSDocumentFragmentElement::DocumentFragmentElementInstance::~DocumentFragmentElementInstance() {
  ::foundation::UICommandCallbackQueue::instance()->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeDocumentFragmentElement *>(ptr);
  }, nativeDocumentFragmentElement);
}

} // namespace kraken::binding::jsc
