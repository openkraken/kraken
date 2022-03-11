/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_MEMBER_INSTALLER_H
#define KRAKENBRIDGE_MEMBER_INSTALLER_H

#include <quickjs/quickjs.h>
#include <initializer_list>

namespace kraken {

class ExecutingContext;

// Flags for object properties.
enum JSPropFlag { normal = JS_PROP_NORMAL, writable = JS_PROP_WRITABLE, enumerable = JS_PROP_ENUMERABLE, configurable = JS_PROP_CONFIGURABLE };

// Combine multiple prop flags.
int combinePropFlags(JSPropFlag a, JSPropFlag b);
int combinePropFlags(JSPropFlag a, JSPropFlag b, JSPropFlag c);

// A set of utility functions to define attributes members as ES properties.
class MemberInstaller {
 public:
  struct AttributeConfig {
    AttributeConfig& operator=(const AttributeConfig&) = delete;
    const char* name;
    JSCFunction* getter{nullptr};
    JSCFunction* setter{nullptr};
    JSValue value{JS_NULL};
    int flag{JS_PROP_C_W_E};  // Flags for object properties.
  };

  struct FunctionConfig {
    FunctionConfig& operator=(const FunctionConfig&) = delete;
    const char* name;
    JSCFunction* function;
    size_t length;
    int flag{JS_PROP_C_W_E};  // Flags for object properties.
  };

  static void InstallAttributes(ExecutingContext* context, JSValue root, std::initializer_list<AttributeConfig> config);
  static void InstallFunctions(ExecutingContext* context, JSValue root, std::initializer_list<FunctionConfig> config);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_MEMBER_INSTALLER_H
