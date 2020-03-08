/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_FOUNDATION_WEBSOCKET_CLIENT_H
#define KRAKEN_FOUNDATION_WEBSOCKET_CLIENT_H

#include <memory>
#include <string>

namespace kraken {
namespace foundation {
class WebSocketCallback {
public:
  virtual ~WebSocketCallback() {}
  virtual void onOpen() = 0;
  virtual void onMessage(const std::string &message) = 0;
  virtual void onClose(int code, const std::string &reason) = 0;
  virtual void onError(const std::string &error) = 0;
};

class WebSocketClient {
public:
  virtual ~WebSocketClient() {}

  static std::unique_ptr<WebSocketClient> buildDefault();

  /**
   * @param url 地址
   * @param callback 回调
   * @return token
   * */
  virtual int connect(const std::string &url, std::shared_ptr<WebSocketCallback> callback) = 0;
  virtual void send(int token, const std::string &message) = 0;
  virtual void close(int token, int code, const std::string &reason) = 0;
};

} // namespace foundation
} // namespace kraken

#endif // KRAKEN_FOUNDATION_WEBSOCKET_CLIENT_H
