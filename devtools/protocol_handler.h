//
// Created by rowandjj on 2019/4/23.
//

#ifndef KRAKEN_DEBUGGER_PROTOCOL_HANDLER_H
#define KRAKEN_DEBUGGER_PROTOCOL_HANDLER_H

namespace kraken{
    namespace Debugger {
        class ProtocolHandler {
        public:
            virtual ~ProtocolHandler(){}

            virtual void handlePageReload() = 0;
        };
    }
}

#endif //KRAKEN_DEBUGGER_PROTOCOL_HANDLER_H
