/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H
#include "jsa.h"

namespace kraken {
namespace binding {
namespace jsa {
using namespace alibaba::jsa;

class JSDocument : public HostObject, public std::enable_shared_from_this<JSDocument> {
public:
  ~JSDocument() override;
  Value get(JSContext &, const PropNameID &name) override;
  void set(JSContext &, const PropNameID &name, const Value &value) override;

  static Value createElement(JSContext &context, const Value &thisVal, const Value *args, size_t count);

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;
};

void bindDocument(std::unique_ptr<JSContext> &context);

}
} // namespace binding
} // namespace kraken

#endif // KRAKENBRIDGE_DOCUMENT_H
