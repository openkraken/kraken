//
// Created by rowandjj on 2019/4/24.
//

#include "log_frontend.h"
#include "devtools/protocol/entry_added_notification.h"

namespace kraken{
    namespace Debugger {

        void LogFrontend::entryAdded(std::unique_ptr<kraken::Debugger::LogEntry> entry) {
            if (!m_frontendChannel)
                return;
            std::unique_ptr<EntryAddedNotification> messageData = EntryAddedNotification::create()
                    .setEntry(std::move(entry))
                    .build();
            rapidjson::Document doc;
            m_frontendChannel->sendProtocolNotification({"Log.entryAdded",messageData->toValue(doc.GetAllocator())});
        }
    }
}