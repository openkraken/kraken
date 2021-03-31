/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "inspector/frontdoor.h"

namespace kraken {
namespace debugger {

std::unique_ptr<kraken::debugger::FrontDoor> FrontDoor::newInstance(JSC::JSGlobalObject *globalObject,
                                                                    std::shared_ptr<ProtocolHandler> handler,
                                                                    std::string ipAddress) {
  return std::make_unique<FrontDoor>(globalObject, handler, std::move(ipAddress));
}

void FrontDoor::setup() {
  setup(m_port /*+ rand() % 999*/);
}

void FrontDoor::setup(int port) {
  this->m_port = port;
//  if (m_server) {
//    if (m_server->start(port)) {
//      KRAKEN_LOG(VERBOSE) << "[debugger] 调试服务已开启 >>>> " << m_ip_address << ":" << port;
//    } else {
//      KRAKEN_LOG(VERBOSE) << "[debugger] 调试服务开启失败 >>>> " << m_ip_address << ":" << port;
//    }
//  }
}

void FrontDoor::notifyPageDiscovered(const std::string &url, const std::string &source) {
  std::string pageId = "random_id";
  m_page_map[url] = pageId; // TODO uuid
  KRAKEN_LOG(VERBOSE) << "---------------------------------------------------------------------------------------------"
                         "-------------------";
  KRAKEN_LOG(VERBOSE) << "[debugger] 发现可调试页面(" << url << ")";
  KRAKEN_LOG(VERBOSE) << "[debugger] 请在Chrome上打开此地址调试: "
                      << "chrome-devtools://devtools/bundled/inspector.html?ws=" << m_ip_address << ":" << m_port;
  //                             << "/devtools/page/"
  //                             << pageId;
  KRAKEN_LOG(VERBOSE) << "---------------------------------------------------------------------------------------------"
                         "-------------------";
}

void FrontDoor::terminate() {
//  if (m_server) {
//    m_server->stop();
//  }
  m_page_map.clear();
}
} // namespace debugger
} // namespace kraken
