/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_JS_BINDINGS_WINDOW_H_
#define KRAKEN_JS_BINDINGS_WINDOW_H_
#include "jsa.h"

#include <memory>

namespace kraken {
namespace binding {
class JSWindow : public alibaba::jsa::HostObject,
                 public std::enable_shared_from_this<JSWindow> {
public:
  JSWindow(){};
  ~JSWindow() = default;

  virtual void bind(alibaba::jsa::JSContext *context);
  // alibaba::jsa::HostObject
  virtual alibaba::jsa::Value
  get(alibaba::jsa::JSContext &, const alibaba::jsa::PropNameID &name) override;
  void invokeOnloadCallback(alibaba::jsa::JSContext *context);

private:
  std::shared_ptr<JSWindow> sharedSelf() { return shared_from_this(); }

  alibaba::jsa::Value bindOnload(alibaba::jsa::JSContext &context,
                                 const alibaba::jsa::Value &thisVal,
                                 const alibaba::jsa::Value *args, size_t count);
};
} // namespace binding
} // namespace kraken

#endif
