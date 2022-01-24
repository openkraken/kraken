/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_FRAGMENT_H
#define KRAKENBRIDGE_DOCUMENT_FRAGMENT_H

#include "node.h"

namespace kraken::binding::qjs {

void bindDocumentFragment(std::unique_ptr<ExecutionContext>& context);

class DocumentFragment : public Node {
 public:
  static JSClassID classId;
  // Return the constructor class object of DocumentFragment.
  static JSValue constructor(ExecutionContext* context);
  DocumentFragment* create(JSContext* ctx);
  DocumentFragment();

 private:
  friend Node;
};

auto documentFragmentCreator = [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) -> JSValue {
  auto* eventTarget = EventTarget::create(ctx);
  return eventTarget->toQuickJS();
};

const WrapperTypeInfo documentFragmentInfo = {"DocumentFragment", &nodeTypeInfo, documentFragmentCreator};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_DOCUMENT_FRAGMENT_H
