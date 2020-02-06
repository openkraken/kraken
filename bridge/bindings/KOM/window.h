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
using namespace alibaba::jsa;

class JSWindow : public HostObject,
                 public std::enable_shared_from_this<JSWindow> {
public:
  JSWindow(){
    location_ = std::make_shared<kraken::binding::JSLocation>();
  };

  ~JSWindow() {
    _onLoadCallback = nullptr;
    _onPlatformBrightnessChanged = nullptr;
    location_ = nullptr;
  };

  void bind(std::unique_ptr<JSContext> &context);
  void unbind(std::unique_ptr<JSContext> &context);
  Value get(JSContext &, const PropNameID &name) override;
  void set(JSContext &, const PropNameID &name, const Value &value) override;

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

  void invokeOnloadCallback(std::unique_ptr<JSContext> &context);
  void invokeOnPlatformBrightnessChangedCallback(std::unique_ptr<JSContext> &context);

private:
  std::shared_ptr<JSWindow> sharedSelf() { return shared_from_this(); }
  Value _onLoadCallback;
  Value _onPlatformBrightnessChanged;
  int _devicePixelRatio = 1;
  std::shared_ptr<kraken::binding::JSLocation> location_;
};
} // namespace binding
} // namespace kraken

#endif
