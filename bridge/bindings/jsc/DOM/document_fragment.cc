/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document_fragment.h"

namespace kraken::binding::jsc {

void bindDocumentFragment(std::unique_ptr<JSContext> &context) {
  auto DocumentFragment = JSDocumentFragment::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "DocumentFragment", DocumentFragment->classObject);
}

std::unordered_map<JSContext *, JSDocumentFragment *> JSDocumentFragment::instanceMap{};

JSDocumentFragment::~JSDocumentFragment() {
  instanceMap.erase(context);
}

JSDocumentFragment::JSDocumentFragment(JSContext *context) : JSNode(context) {}
JSObjectRef JSDocumentFragment::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                              const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new DocumentFragmentInstance(this);
  return instance->object;
}

JSDocumentFragment::DocumentFragmentInstance::DocumentFragmentInstance(JSDocumentFragment *jsDocumentFragment)
  : NodeInstance(jsDocumentFragment, NodeType::DOCUMENT_FRAGMENT_NODE) {
  setNodeFlag(DocumentFragmentInstance::NodeFlag::IsDocumentFragment);
  std::string tagName = "documentfragment";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  foundation::UICommandBuffer::instance(context->getContextId())
    ->addCommand(eventTargetId, UICommand::createDocumentFragment, args_01, nativeNode);
}

JSDocumentFragment::DocumentFragmentInstance::~DocumentFragmentInstance() {}

} // namespace kraken::binding::jsc
