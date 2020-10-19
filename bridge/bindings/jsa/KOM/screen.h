/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_SCREEN_H
#define KRAKEN_SCREEN_H

#include "jsa.h"
#include <memory>

namespace kraken {
namespace binding {
namespace jsa {

using namespace alibaba::jsa;

class JSScreen : public HostObject, public std::enable_shared_from_this<JSScreen> {
public:
  void bind(std::unique_ptr<JSContext> &context);
  void unbind(std::unique_ptr<JSContext> &context);

  virtual Value get(JSContext &context, const PropNameID &name) override;
  virtual void set(JSContext &context, const PropNameID &name, const Value &value) override;
  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

private:
  std::shared_ptr<JSScreen> sharedSelf() {
    return shared_from_this();
  }
};

}
} // namespace binding
} // namespace kraken

#endif /* KRAKEN_SCREEN_H */
