/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_FRAGMENT_H
#define KRAKENBRIDGE_DOCUMENT_FRAGMENT_H

#include "node.h"

namespace kraken::binding::qjs {

void bindDocumentFragment(ExecutionContext* context);

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
