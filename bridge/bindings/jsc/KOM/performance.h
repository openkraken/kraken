/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bindings/jsc/host_object.h"
#include "bindings/jsc/js_context.h"
#include <unordered_map>
#include <vector>

namespace kraken::binding::jsc {

#define JSPerformanceName "Performance"

void bindPerformance(std::unique_ptr<JSContext> &context);

class JSPerformance : public HostObject {
public:
  enum class PerformanceProperty { kNow, kTimeOrigin, ktoJSON };

  static std::unordered_map<std::string, PerformanceProperty> &getPerformancePropertyMap();
  static std::vector<JSStringRef> &getPerformancePropertyNames();

  static JSValueRef now(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef timeOrigin(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef toJSON(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                               size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  JSPerformance(JSContext *context) : HostObject(context, JSPerformanceName) {}

  ~JSPerformance() override;
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:

  JSObjectRef _now {nullptr};
  JSObjectRef _timeOrigin {nullptr};
  JSObjectRef _toJSON {nullptr};

  double internalNow();
};

} // namespace kraken::binding::jsc
