/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "jsc_heap_profiler_agent_impl.h"
#include "inspector/impl/jsc_log_agent_impl.h"

namespace kraken::debugger {
JSCHeapProfilerAgentImpl::JSCHeapProfilerAgentImpl(kraken::debugger::InspectorSession *session,
                                                   kraken::debugger::AgentContext &context)
  : m_session(session), m_environment(context.environment) {}

DispatchResponse JSCHeapProfilerAgentImpl::collectGarbage() {
  auto &vm = m_environment->vm();
  JSC::JSLockHolder lock(vm);
  JSC::sanitizeStackForVM(vm);
  vm.heap.collectSync();
  return DispatchResponse::OK();
}

DispatchResponse JSCHeapProfilerAgentImpl::enable() {
  if (m_enabled) return DispatchResponse::OK();
  m_enabled = true;
  m_environment->vm().heap.addObserver(this);
  return DispatchResponse::OK();
}

DispatchResponse JSCHeapProfilerAgentImpl::disable() {
  if (!m_enabled) return DispatchResponse::OK();
  m_enabled = false;
  m_environment->vm().heap.removeObserver(this);
  // TODO clearHeapSnapshots
  return DispatchResponse::OK();
}

// HeapObserver
void JSCHeapProfilerAgentImpl::willGarbageCollect() {
  if (!m_enabled) return;
  m_gcStartTime = m_environment->executionStopwatch()->elapsedTime().milliseconds();
}

void JSCHeapProfilerAgentImpl::didGarbageCollect(JSC::CollectionScope) {
  if (m_gcStartTime == -1) return;

  double endTime = m_environment->executionStopwatch()->elapsedTime().milliseconds();

  WTF::StringBuilder builder;
  builder.append("last gc elapsed ");
  auto &&string = WTF::String::number(endTime - m_gcStartTime);
  builder.append(string.characters8(), string.length());
  builder.append("ms");
  auto now = std::chrono::high_resolution_clock::now();
  m_session->logAgent()->addMessageToConsole(
    LogEntry::create()
      .setLevel(LogEntry::LevelEnum::Verbose)
      .setTimestamp(std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count())
      .setSource(LogEntry::SourceEnum::Javascript)
      .setText(builder.toString().utf8().data())
      .build());
  m_gcStartTime = -1;
}

} // namespace kraken::debugger
