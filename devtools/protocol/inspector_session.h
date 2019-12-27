//
// Created by rowandjj on 2019/4/2.
//

#ifndef KRAKEN_DEBUGGER_INSPECTOR_SESSION_H
#define KRAKEN_DEBUGGER_INSPECTOR_SESSION_H

#include <string>
#include <vector>

#include "devtools/protocol/domain.h"
#include "devtools/service/rpc/protocol.h"

namespace kraken{
    namespace Debugger {

        class InspectorSession {
        public:
            virtual ~InspectorSession() = default;

            // Dispatching protocol messages.
            //判断domain
            static bool canDispatchMethod(const std::string& method);

            virtual void dispatchProtocolMessage(jsonRpc::Request message) = 0;

            virtual std::vector<std::unique_ptr<Domain>> supportedDomains() = 0;

        };
    }
}

#endif //KRAKEN_DEBUGGER_INSPECTOR_SESSION_H
