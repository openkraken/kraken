/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HISTORY_H
#define KRAKENBRIDGE_HISTORY_H

#include "bindings/jsc/host_object_internal.h"
#include "bindings/jsc/js_context_internal.h"
#include <array>
#include <stack>

namespace kraken::binding::jsc {

#define JSHistoryName "History"

class JSWindow;

class JSHistory : public HostObject {
public:
  JSHistory(JSContext *context) : HostObject(context, JSHistoryName) {}
  ~JSHistory() override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
private:
  std::stack<std::string> m_previous_stack;
  std::stack<std::string> m_next_stack;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_HISTORY_H
