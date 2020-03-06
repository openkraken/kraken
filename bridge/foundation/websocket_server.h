//
// Created by rowandjj on 2019/3/26.
//
// usage:
//        auto _server = WebSocket::WebSocketServer::buildDefault();
//        _server->listen(8000, [](std::shared_ptr<WebSocket::WebSocketSession>
//        session) {
//            session->setOnMessageCallback([](const std::string &message) {
//            });
//            session->send("hello world!");
//            session->close(8000,"");
//        });

#ifndef KRAKEN_FOUNDATION_WEBSOCKET_SERVER_H
#define KRAKEN_FOUNDATION_WEBSOCKET_SERVER_H

#include <functional>
#include <memory>
#include <string>

namespace kraken {
namespace foundation {
using OnMessageCallback = std::function<void(const std::string &message)>;
using OnCloseCallback = std::function<void(int code, const std::string &reason)>;
using OnErrorCallback = std::function<void(const std::string &error)>;

class WebSocketSession {
public:
  WebSocketSession() = default;
  virtual ~WebSocketSession() {}

  virtual void setOnMessageCallback(OnMessageCallback callback) = 0;
  virtual void setOnCloseCallback(OnCloseCallback callback) = 0;
  virtual void send(const std::string &message) = 0;
  virtual void close(int code, const std::string &reason) = 0;
};

using ConnectionCallback = std::function<void(std::shared_ptr<WebSocketSession>)>;

class WebSocketServer {
public:
  virtual ~WebSocketServer() {}

  static std::unique_ptr<WebSocketServer> buildDefault();
  /*listen on port. can not listen multiple times.*/
  virtual bool listen(int port, ConnectionCallback connectionCallback /*sub thread*/) = 0;
  virtual void stopListening() = 0;

  /**
   * @param wait 是否阻塞等待所有session关闭再停止监听端口
   * */
  virtual void stopListening(bool wait) = 0;
};
} // namespace foundation
} // namespace kraken

#endif // KRAKEN_FOUNDATION_WEBSOCKET_SERVER_H
