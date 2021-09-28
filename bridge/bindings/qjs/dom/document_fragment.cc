/*
* Copyright (C) 2021 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include "document_fragment.h"
#include "kraken_bridge.h"
#include "document.h"

namespace kraken::binding::qjs {

void bindDocumentFragment(std::unique_ptr<JSContext> &context) {
  auto *constructor = DocumentFragment::instance(context.get());
  context->defineGlobalProperty("DocumentFragment", constructor->classObject);
}

std::once_flag kDocumentFragmentFlag;

OBJECT_INSTANCE_IMPL(DocumentFragment);

JSClassID DocumentFragment::kDocumentFragmentID{0};

DocumentFragment::DocumentFragment(JSContext *context) : Node(context) {
  std::call_once(kDocumentFragmentFlag, []() {
    JS_NewClassID(&kDocumentFragmentID);
  });
}

JSClassID DocumentFragment::classId() {
  return kDocumentFragmentID;
}

JSValue DocumentFragment::instanceConstructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc,
                                              JSValue *argv) {
  return (new DocumentFragmentInstance(this))->instanceObject;
}

DocumentFragmentInstance::DocumentFragmentInstance(DocumentFragment *fragment): NodeInstance(fragment, NodeType::DOCUMENT_FRAGMENT_NODE, DocumentInstance::instance(
                                                               Document::instance(
                                                                 fragment->context())), DocumentFragment::classId(), "DocumentFragment") {
  setNodeFlag(DocumentFragmentInstance::NodeFlag::IsDocumentFragment);
  foundation::UICommandBuffer::instance(m_contextId)->addCommand(eventTargetId, UICommand::createDocumentFragment, nativeEventTarget);
}
}
