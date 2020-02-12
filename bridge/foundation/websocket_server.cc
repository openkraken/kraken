//
// Created by rowandjj on 2019/3/26.
//

#include "websocket_server.h"
#include <asio.hpp>
#include <websocketpp/config/asio_no_tls.hpp>
#include <websocketpp/server.hpp>

#include <websocketpp/common/memory.hpp>
#include <websocketpp/common/thread.hpp>

#include "count_down_latch.h"

#include "logging.h"
#include "thread_utils.h"

#include <iostream>
#include <map>
#include <memory>
#include <vector>

using namespace kraken::foundation;
using server = websocketpp::server<websocketpp::config::asio>;

class WebSocketSessionImpl : public WebSocketSession {
public:
  WebSocketSessionImpl(server *ser, websocketpp::connection_hdl hdl)
      : m_server(ser), m_hdl(hdl), m_status("Open"), m_latch(nullptr) {
    // set thread name
    SetCurrentThreadName("ws-session");
  }

  ~WebSocketSessionImpl() {
    KRAKEN_LOG(VERBOSE) << "websocket session destroyed";
  }

  void onMessage(const std::string &message) {
    if (this->m_message_callback) {
      m_message_callback(message);
    }
  }

  void onClose(int code, const std::string &reason) {
    m_status = "Closed";
    if (this->m_close_callback) {
      m_close_callback(code, reason);
    }

    if (this->m_latch) {
      this->m_latch->CountDown();
    }
  }

  void setOnMessageCallback(OnMessageCallback callback) override {
    this->m_message_callback = callback;
  }

  void setOnCloseCallback(OnCloseCallback callback) override {
    this->m_close_callback = callback;
  }

  void send(const std::string &message) override {
    if (m_server) {
      websocketpp::lib::error_code ec;
      m_server->send(m_hdl, message, websocketpp::frame::opcode::text, ec);
      if (ec) {
        KRAKEN_LOG(ERROR) << "send message to client error! " << ec.message();
      }
    }
  }

  void close(int code, const std::string &reason) override {
    if (m_server) {
      websocketpp::lib::error_code ec;

      bool invalid_code =
          websocketpp::close::status::invalid(static_cast<uint16_t>(code));
      if (invalid_code) {
        KRAKEN_LOG(VERBOSE)
            << "[websocket] Server close code invalid. reset to 1000";
        code = websocketpp::close::status::normal;
      }

      m_server->close(m_hdl, static_cast<uint16_t>(code), reason, ec);
      if (ec) {
        KRAKEN_LOG(VERBOSE)
            << "[websocket] Server Error initiating close: " << ec.message();
      }
    }
  }

  void setLatch(foundation::CountDownLatch *latch) { this->m_latch = latch; }

  websocketpp::connection_hdl get_hdl() const { return m_hdl; }

  std::string get_status() const { return m_status; }

private:
  OnMessageCallback m_message_callback;
  OnCloseCallback m_close_callback;
  server *m_server;
  websocketpp::connection_hdl m_hdl;
  std::string m_status;
  foundation::CountDownLatch *m_latch;
};

class WebSocketServerImpl : public WebSocketServer {
public:
  WebSocketServerImpl() : is_listening(false) {
    // Set logging settings
    m_endpoint.set_error_channels(websocketpp::log::elevel::all);
    m_endpoint.set_access_channels(websocketpp::log::alevel::none);

    // Initialize Asio
    m_endpoint.init_asio();

    m_endpoint.set_open_handler(websocketpp::lib::bind(
        &WebSocketServerImpl::_on_open, this, &m_endpoint,
        websocketpp::lib::placeholders::_1));

    m_endpoint.set_fail_handler(websocketpp::lib::bind(
        &WebSocketServerImpl::_on_fail, this, &m_endpoint,
        websocketpp::lib::placeholders::_1));
    m_endpoint.set_close_handler(websocketpp::lib::bind(
        &WebSocketServerImpl::_on_close, this, &m_endpoint,
        websocketpp::lib::placeholders::_1));
    m_endpoint.set_message_handler(
        websocketpp::lib::bind(&WebSocketServerImpl::_on_message, this,
                               websocketpp::lib::placeholders::_1,
                               websocketpp::lib::placeholders::_2));
  }

  ~WebSocketServerImpl() {
    KRAKEN_LOG(VERBOSE) << "[websocket] server destructed ...";
    this->stopListening();
    if (m_thread) {
      m_thread->join();
    }
  }

  bool listen(int port, ConnectionCallback connectionCallback) override;
  void stopListening() override;
  void stopListening(bool wait) override;

private:
  void _on_open(server *ser, websocketpp::connection_hdl hdl);
  void _on_fail(server *ser, websocketpp::connection_hdl hdl);
  void _on_close(server *ser, websocketpp::connection_hdl hdl);
  void _on_message(websocketpp::connection_hdl hdl, server::message_ptr msg);

private:
  using thread_ptr = websocketpp::lib::shared_ptr<websocketpp::lib::thread>;
  using session_list = std::map<websocketpp::connection_hdl,
                                std::shared_ptr<WebSocketSessionImpl>,
                                std::owner_less<websocketpp::connection_hdl>>;

  server m_endpoint;
  thread_ptr m_thread;
  session_list m_session_list;
  ConnectionCallback m_connection_callback;
  bool is_listening;
};

std::unique_ptr<WebSocketServer> WebSocketServer::buildDefault() {
  return std::make_unique<WebSocketServerImpl>();
}

void WebSocketServerImpl::_on_open(server *ser,
                                   websocketpp::connection_hdl hdl) {
  // new connection comes
  std::shared_ptr<WebSocketSessionImpl> session =
      std::make_shared<WebSocketSessionImpl>(ser, hdl);
  m_session_list[hdl] = session;
  KRAKEN_LOG(VERBOSE) << "[websocket] New Connection Comes...";
  // report
  if (m_connection_callback) {
    m_connection_callback(session);
  }
}

void WebSocketServerImpl::_on_fail(server *ser,
                                   websocketpp::connection_hdl hdl) {
  auto con = ser->get_con_from_hdl(hdl);
  auto reason = con->get_ec().message();
  KRAKEN_LOG(VERBOSE) << "[websocket] connection establish failed because of "
                      << reason;
}

void WebSocketServerImpl::_on_close(server *ser,
                                    websocketpp::connection_hdl hdl) {
  session_list::iterator session_it = m_session_list.find(hdl);
  if (session_it == m_session_list.end()) {
    KRAKEN_LOG(VERBOSE) << "[websocket] No connection found with specific id";
    return;
  }
  server::connection_ptr con = ser->get_con_from_hdl(hdl);
  session_it->second->onClose(con->get_remote_close_code(),
                              con->get_remote_close_reason());

  // remote session
  auto size = m_session_list.erase(hdl);
  if (size == 1) {
    KRAKEN_LOG(VERBOSE) << "[websocket] WebSocket Connection closed success";
  } else {
    KRAKEN_LOG(VERBOSE) << "[websocket] WebSocket Connection closed failed";
  }
}

void WebSocketServerImpl::_on_message(websocketpp::connection_hdl hdl,
                                      server::message_ptr msg) {
  session_list::iterator session_it = m_session_list.find(hdl);
  if (session_it == m_session_list.end()) {
    KRAKEN_LOG(VERBOSE) << "[websocket] No connection found with specific id";
    return;
  }
  session_it->second->onMessage(msg->get_payload());
}

bool WebSocketServerImpl::listen(int port,
                                 ConnectionCallback connectionCallback) {
  if (this->is_listening) {
    KRAKEN_LOG(ERROR) << "[websocket] server already in listening, create a "
                         "new server to listen on other port...";
    return false;
  }
  websocketpp::lib::error_code ec;

  // https://docs.websocketpp.org/faq.html
  // (How do I fix the "address is in use" error when trying to restart my
  // server?)
  m_endpoint.set_reuse_addr(true);

  m_endpoint.listen(static_cast<uint16_t>(port), ec);
  this->m_connection_callback = connectionCallback;
  if (ec) {
    KRAKEN_LOG(ERROR) << "[websocket] Connect listen on port: " << port
                      << " failed because of " << ec.message();
    return false;
  }
  m_endpoint.start_accept(ec);
  if (ec) {
    KRAKEN_LOG(ERROR) << "[websocket] Connect listen on port: " << port
                      << " failed because of " << ec.message();
    return false;
  }
  KRAKEN_LOG(VERBOSE) << "[websocket] begin listening on port: " << port;
  m_thread = websocketpp::lib::make_shared<websocketpp::lib::thread>(
      &server::run, &m_endpoint);
  this->is_listening = true;
  return true;
}

void WebSocketServerImpl::stopListening() { this->stopListening(false); }

void WebSocketServerImpl::stopListening(bool wait) {
  if (!this->is_listening) {
    return;
  }
  KRAKEN_LOG(VERBOSE) << "[websocket] server stop listening...";

  std::unique_ptr<foundation::CountDownLatch> _latch = nullptr;
  if (wait && m_session_list.size() > 0) {
    _latch =
        std::make_unique<foundation::CountDownLatch>(m_session_list.size());
  }

  for (auto it = m_session_list.begin(); it != m_session_list.end(); ++it) {
    if (it->second->get_status() != "Open") {
      // Only close open connections
      continue;
    }

    if (wait && _latch) {
      it->second->setLatch(_latch.get());
    }

    websocketpp::lib::error_code ec;
    m_endpoint.close(it->second->get_hdl(),
                     websocketpp::close::status::going_away, "going away", ec);
    if (ec) {
      KRAKEN_LOG(VERBOSE) << "[websocket] Server Error closing connection "
                          << ": " << ec.message();
      if (wait && _latch) {
        _latch->CountDown();
      }
    }
  }

  if (wait && _latch) {
    _latch->Wait();
  }

  this->is_listening = false;
  websocketpp::lib::error_code ec;
  m_endpoint.stop_listening(ec);
  if (ec) {
    KRAKEN_LOG(ERROR) << "[websocket] Server stop listening failed because of "
                      << ec.message();
  }

  // 尽量不要使用stop()。refer:
  // https://github.com/zaphoyd/websocketpp/issues/704
  //    m_endpoint.stop();
}