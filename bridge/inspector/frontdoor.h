/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_FRONTDOOR_H
#define KRAKEN_DEBUGGER_FRONTDOOR_H

#include "inspector/protocol_handler.h"
#include "foundation/logging.h"
#include <JavaScriptCore/JSGlobalObject.h>
#include <map>
#include <memory>

namespace kraken {
namespace debugger {
class FrontDoor final {
public:
  static std::unique_ptr<kraken::debugger::FrontDoor>
  newInstance(JSC::JSGlobalObject *globalObject, std::shared_ptr<ProtocolHandler> handler, std::string ipAddress);

  ~FrontDoor() = default;
  void setup();
  void setup(int port);
  void notifyPageDiscovered(const std::string &url, const std::string &source);
  void terminate();
  FrontDoor(JSC::JSGlobalObject *globalObject, std::shared_ptr<ProtocolHandler> handler, std::string ipAddress)
    : m_ip_address(std::move(ipAddress)) {
//    m_server = std::make_unique<debugger::ChromeProtocolServer>(globalObject, handler, m_ip_address);
  }

private:
//  std::unique_ptr<Debugger::ChromeProtocolServer> m_server;
  std::string m_ip_address;

  int m_port{9222};

  using PageMap = std::map<std::string /*page url*/, std::string /*unique id*/>;
  PageMap m_page_map;
};

} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_FRONTDOOR_H
