/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_QJS_BLOB_PROPERTY_BAG_H
#define KRAKENBRIDGE_QJS_BLOB_PROPERTY_BAG_H

#include "core/executing_context.h"

namespace kraken {

class BlobPropertyBag final {
 public:
  static BlobPropertyBag* create(ExecutingContext* context, JSValue value, ExceptionState* exceptionState);

  const std::string& type() const { return m_type; }

 private:
  void fillMemberFromQuickjsObject(ExecutingContext* context, JSValue value, ExceptionState* exceptionState);
  std::string m_type;
};

}

#endif  // KRAKENBRIDGE_QJS_BLOB_PROPERTY_BAG_H
