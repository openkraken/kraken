/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document_fragment.h"
#include "document.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

void bindDocumentFragment(std::unique_ptr<ExecutionContext>& context) {
  JSValue classObject = context->contextData()->constructorForType(&documentFragmentInfo);
  context->defineGlobalProperty("DocumentFragment", classObject);
}

JSValue DocumentFragment::constructor(ExecutionContext* context) {
  return context->contextData()->constructorForType(&documentFragmentInfo);
}

DocumentFragment * DocumentFragment::create(JSContext* ctx) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue prototype = context->contextData()->prototypeForType(&documentFragmentInfo);
  auto* documentFragment = makeGarbageCollected<DocumentFragment>()->initialize<DocumentFragment>(ctx, &classId);

  // Let documentFragment instance inherit Document prototype methods.
  JS_SetPrototype(ctx, documentFragment->toQuickJS(), prototype);

  return documentFragment;
}

DocumentFragment::DocumentFragment() {
  setNodeFlag(DocumentFragment::NodeFlag::IsDocumentFragment);
  context()->uiCommandBuffer()->addCommand(eventTargetId(), UICommand::createDocumentFragment, nativeEventTarget);
}

}  // namespace kraken::binding::qjs
