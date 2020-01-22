/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_LOCATION_H
#define KRAKENBRIDGE_LOCATION_H

#include "jsa.h"

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

class JSWindow;

class JSLocation : public HostObject,
                   public std::enable_shared_from_this<JSLocation> {
public:
  JSLocation(){};
  ~JSLocation(){};

  void bind(JSContext *context, Object& window);
  void unbind(JSContext *context, Object &window);

  Value get(JSContext &, const PropNameID &name) override;
  void set(JSContext &, const PropNameID &name, const Value &value) override;
  void updateLocation(
    std::string _origin,
    std::string _protocol,
    std::string _host,
    std::string _hostname,
    std::string _port,
    std::string _pathname,
    std::string _search,
    std::string _hash
  );

private:
  std::shared_ptr<JSLocation> sharedSelf() { return shared_from_this(); }
  Value reload(JSContext &context, const Value &thisVal, const Value *args,
               size_t count);
};

}
}

#endif // KRAKENBRIDGE_LOCATION_H
