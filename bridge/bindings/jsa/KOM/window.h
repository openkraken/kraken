/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_JS_BINDINGS_WINDOW_H_
#define KRAKEN_JS_BINDINGS_WINDOW_H_
#include "jsa.h"
#include "location.h"

#include <memory>

namespace kraken {
namespace binding {
namespace jsa {
using namespace alibaba::jsa;

class JSWindow : public HostObject, public std::enable_shared_from_this<JSWindow> {
public:
  JSWindow() {
    location_ = std::make_shared<kraken::binding::jsa::JSLocation>();
  };

  ~JSWindow() {
    location_ = nullptr;
  };

  void bind(std::unique_ptr<JSContext> &context);
  void unbind(std::unique_ptr<JSContext> &context);
  Value get(JSContext &, const PropNameID &name) override;
  void set(JSContext &, const PropNameID &name, const Value &value) override;

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

private:
  std::shared_ptr<JSWindow> sharedSelf() {
    return shared_from_this();
  }
  std::shared_ptr<kraken::binding::jsa::JSLocation> location_;
};
} // namespace jsa
} // namespace binding
} // namespace kraken

#endif
