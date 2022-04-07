/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "node.h"
#include "bindings/qjs/qjs_engine_patch.h"
#include "comment.h"
#include "document.h"
#include "document_fragment.h"
#include "element.h"
#include "text_node.h"

namespace kraken {

Node* Node::Create(ExecutingContext* context, ExceptionState& exception_state) {
  exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Illegal constructor");
}

}  // namespace kraken
