//
// Created by rowandjj on 2019-06-12.
//

#include "devtools/protocol/heap_profiler_backend.h"
#include "devtools/inspector_session_impl.h"

namespace kraken{

    namespace Debugger {
    class JSCHeapProfilerAgentImpl: public HeapProfilerBackend, public JSC::HeapObserver  {
        public:
            JSCHeapProfilerAgentImpl(InspectorSessionImpl* session,
                                     Debugger::AgentContext& context);

            DispatchResponse collectGarbage() override;
            DispatchResponse disable() override;
            DispatchResponse enable() override;

            void willGarbageCollect() override;
            void didGarbageCollect(JSC::CollectionScope) override;

        private:
            InspectorSessionImpl* m_session;
            bool m_enabled { false };
            double m_gcStartTime { -1 };
            Inspector::InspectorEnvironment* m_environment;
        };
    }
}
