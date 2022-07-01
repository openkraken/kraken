/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_FILEAPI_BLOB_PROPERTY_BAG_H_
#define KRAKENBRIDGE_CORE_FILEAPI_BLOB_PROPERTY_BAG_H_

#include <quickjs/quickjs.h>
#include <memory>
#include "core/executing_context.h"

namespace kraken {

class BlobPropertyBag final {
 public:
  using ImplType = std::shared_ptr<BlobPropertyBag>;

  static std::shared_ptr<BlobPropertyBag> Create(JSContext* ctx, JSValue value, ExceptionState& exceptionState);

  const std::string& type() const { return m_type; }

 private:
  void FillMemberFromQuickjsObject(JSContext* ctx, JSValue value, ExceptionState& exceptionState);
  std::string m_type;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_FILEAPI_BLOB_PROPERTY_BAG_H_
