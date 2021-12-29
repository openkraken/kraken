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
  static JSClassID kDocumentFragmentID;
  static JSClassID classId();

  DocumentFragment() = delete;
  explicit DocumentFragment(ExecutionContext* context);

  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  OBJECT_INSTANCE(DocumentFragment);
};

class DocumentFragmentInstance : public NodeInstance {
 public:
  DocumentFragmentInstance() = delete;
  DocumentFragmentInstance(DocumentFragment* fragment);
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_DOCUMENT_FRAGMENT_H
