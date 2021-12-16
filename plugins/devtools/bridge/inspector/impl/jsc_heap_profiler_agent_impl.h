/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_JSC_HEAP_PROFILER_AGENT_IMPL_H
#define KRAKEN_DEBUGGER_JSC_HEAP_PROFILER_AGENT_IMPL_H

#include "inspector/inspector_session.h"
#include "inspector/protocol/heap_profiler_backend.h"

#include <JavaScriptCore/InspectorEnvironment.h>

namespace kraken::debugger {
class JSCHeapProfilerAgentImpl : public HeapProfilerBackend, public JSC::HeapObserver {
public:
  JSCHeapProfilerAgentImpl(InspectorSession *session, debugger::AgentContext &context);

  DispatchResponse collectGarbage() override;
  DispatchResponse disable() override;
  DispatchResponse enable() override;

  void willGarbageCollect() override;
  void didGarbageCollect(JSC::CollectionScope) override;

private:
  InspectorSession *m_session;
  bool m_enabled{false};
  double m_gcStartTime{-1};
  Inspector::InspectorEnvironment *m_environment;
};
} // namespace kraken

#endif
