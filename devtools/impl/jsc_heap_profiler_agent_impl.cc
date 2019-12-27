//
// Created by rowandjj on 2019-06-12.
//

#include "jsc_heap_profiler_agent_impl.h"
#include "foundation/logging.h"
#include "devtools/impl/jsc_log_agent_impl.h"
#include "foundation/time_point.h"

namespace kraken{
    namespace Debugger {
        JSCHeapProfilerAgentImpl::JSCHeapProfilerAgentImpl(
                kraken::Debugger::InspectorSessionImpl *session,
                kraken::Debugger::AgentContext &context):
                    m_session(session),
                    m_environment(context.environment)
                    {}

        DispatchResponse JSCHeapProfilerAgentImpl::collectGarbage() {
            auto& vm = m_environment->vm();
            JSC::JSLockHolder lock(vm);
            JSC::sanitizeStackForVM(&vm);
            vm.heap.collectAllGarbage();
            return DispatchResponse::OK();
        }

        DispatchResponse JSCHeapProfilerAgentImpl::enable() {
            if (m_enabled)
                return DispatchResponse::OK();
            m_enabled = true;
            m_environment->vm().heap.addObserver(this);
            return DispatchResponse::OK();
        }

        DispatchResponse JSCHeapProfilerAgentImpl::disable() {
            if (!m_enabled)
                return DispatchResponse::OK();
            m_enabled = false;
            m_environment->vm().heap.removeObserver(this);
            //TODO clearHeapSnapshots
            return DispatchResponse::OK();
        }

        // HeapObserver
        void JSCHeapProfilerAgentImpl::willGarbageCollect() {
            if (!m_enabled)
                return;
            m_gcStartTime = m_environment->executionStopwatch()->elapsedTime();
        }

        void JSCHeapProfilerAgentImpl::didGarbageCollect(JSC::CollectionScope) {
            if(m_gcStartTime == -1)
                return;

            double endTime = m_environment->executionStopwatch()->elapsedTime();

            WTF::StringBuilder builder;
            builder.append("last gc elapsed ");
            builder.append(WTF::String::number(endTime-m_gcStartTime));
            builder.append("ms");

            m_session->logAgent()->addMessageToConsole(
                    LogEntry::create()
                            .setLevel(LogEntry::LevelEnum::Verbose)
                            .setTimestamp(foundation::TimePoint::Now().ToEpochDelta().ToMilliseconds())
                            .setSource(LogEntry::SourceEnum::Javascript)
                            .setText(builder.toString().utf8().data())
                            .build()
            );
            m_gcStartTime = -1;
        }

    }
}
