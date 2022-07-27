/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_DOCUMENT_FRAGMENT_H
#define BRIDGE_DOCUMENT_FRAGMENT_H

#include "node.h"

namespace webf::binding::qjs {

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

}  // namespace webf::binding::qjs

#endif  // BRIDGE_DOCUMENT_FRAGMENT_H
