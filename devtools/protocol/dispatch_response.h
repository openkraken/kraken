//
// Created by rowandjj on 2019/4/2.
//

#ifndef KRAKEN_DEBUGGER_DISPATCH_RESPONSE_H
#define KRAKEN_DEBUGGER_DISPATCH_RESPONSE_H

#include <string>
#include "devtools/service/rpc/protocol.h"

namespace kraken{
    namespace Debugger {

        class DispatchResponse {
        public:
            enum Status {
                kSuccess = 0,
                kError = 1,
                kFallThrough = 2,
            };

            Status status() const { return m_status; }
            const std::string& errorMessage() const { return m_errorMessage; }
            jsonRpc::ErrorCode errorCode() const { return m_errorCode; }
            bool isSuccess() const { return m_status == kSuccess; }

            static DispatchResponse OK();
            static DispatchResponse Error(const std::string&);
            static DispatchResponse InternalError();
            static DispatchResponse InvalidParams(const std::string&);
            static DispatchResponse FallThrough();

        private:
            Status m_status;
            std::string m_errorMessage;
            jsonRpc::ErrorCode m_errorCode;
        };
    }
}

#endif //KRAKEN_DEBUGGER_DISPATCH_RESPONSE_H
