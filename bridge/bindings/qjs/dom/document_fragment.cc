/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "document_fragment.h"
#include "document.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

void bindDocumentFragment(ExecutionContext* context) {
  auto* constructor = DocumentFragment::instance(context);
  context->defineGlobalProperty("DocumentFragment", constructor->jsObject);
}

std::once_flag kDocumentFragmentFlag;

JSClassID DocumentFragment::kDocumentFragmentID{0};

DocumentFragment::DocumentFragment(ExecutionContext* context) : Node(context) {
  std::call_once(kDocumentFragmentFlag, []() { JS_NewClassID(&kDocumentFragmentID); });
  JS_SetPrototype(m_ctx, m_prototypeObject, Node::instance(m_context)->prototype());
}

JSClassID DocumentFragment::classId() {
  return kDocumentFragmentID;
}

JSValue DocumentFragment::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  return (new DocumentFragmentInstance(this))->jsObject;
}

DocumentFragmentInstance::DocumentFragmentInstance(DocumentFragment* fragment) : NodeInstance(fragment, NodeType::DOCUMENT_FRAGMENT_NODE, DocumentFragment::classId(), "DocumentFragment") {
  setNodeFlag(DocumentFragmentInstance::NodeFlag::IsDocumentFragment);
  m_context->uiCommandBuffer()->addCommand(m_eventTargetId, UICommand::createDocumentFragment, nativeEventTarget);
}
}  // namespace kraken::binding::qjs
