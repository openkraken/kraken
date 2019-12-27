//
// Created by rowandjj on 2019-06-11.
//

#ifndef KRAKEN_DEBUGGER_HEAP_PROFILER_BACKEND_H
#define KRAKEN_DEBUGGER_HEAP_PROFILER_BACKEND_H

#include "devtools/protocol/dispatch_response.h"

namespace kraken{
    namespace Debugger {
        class HeapProfilerBackend {
        public:
            virtual ~HeapProfilerBackend() { }

//            virtual DispatchResponse addInspectedHeapObject(const std::string& in_heapObjectId) = 0;
            virtual DispatchResponse collectGarbage() = 0;
            virtual DispatchResponse disable() = 0;
            virtual DispatchResponse enable() = 0;
//            virtual DispatchResponse getHeapObjectId(const std::string& in_objectId, std::string* out_heapSnapshotObjectId) = 0;
//            virtual DispatchResponse getObjectByHeapObjectId(const std::string& in_objectId, Maybe<std::string> in_objectGroup, std::unique_ptr<protocol::Runtime::RemoteObject>* out_result) = 0;
//            virtual DispatchResponse getSamplingProfile(std::unique_ptr<protocol::HeapProfiler::SamplingHeapProfile>* out_profile) = 0;
//            virtual DispatchResponse startSampling(Maybe<double> in_samplingInterval) = 0;
//            virtual DispatchResponse startTrackingHeapObjects(Maybe<bool> in_trackAllocations) = 0;
//            virtual DispatchResponse stopSampling(std::unique_ptr<protocol::HeapProfiler::SamplingHeapProfile>* out_profile) = 0;
//            virtual DispatchResponse stopTrackingHeapObjects(Maybe<bool> in_reportProgress) = 0;
//            virtual DispatchResponse takeHeapSnapshot(Maybe<bool> in_reportProgress) = 0;
        };
    }
}

#endif //KRAKEN_DEBUGGER_HEAP_PROFILER_BACKEND_H
