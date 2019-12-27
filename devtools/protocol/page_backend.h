//
// Created by rowandjj on 2019/4/23.
//

#ifndef KRAKEN_DEBUGGER_PAGE_BACKEND_H
#define KRAKEN_DEBUGGER_PAGE_BACKEND_H

#include "devtools/protocol/maybe.h"
#include "devtools/protocol/dispatch_response.h"
#include <string>

namespace kraken{
    namespace Debugger {
        class PageBackend {
        public:
            virtual ~PageBackend() { }

            virtual DispatchResponse disable() = 0;
            virtual DispatchResponse enable() = 0;

            virtual DispatchResponse reload(Maybe<bool> in_ignoreCache,
                                            Maybe<std::string> in_scriptToEvaluateOnLoad) = 0;
        };
    }
}

#endif //KRAKEN_DEBUGGER_PAGE_BACKEND_H
