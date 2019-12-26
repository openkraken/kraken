//
// Created by rowandjj on 2019/3/21.
//

#include "websocket_client.h"
#include "logging.h"

#include <websocketpp/client.hpp>
#include <websocketpp/common/memory.hpp>
#include <websocketpp/common/thread.hpp>
#include <websocketpp/config/asio_no_tls_client.hpp>

#include <iostream>
#include <map>
#include <vector>

using namespace kraken::foundation;
using client = websocketpp::client<websocketpp::config::asio_client>;

class connection_metadata {
public:
  typedef websocketpp::lib::shared_ptr<connection_metadata> ptr;

  connection_metadata(int id, websocketpp::connection_hdl hdl, std::string uri,
                      std::shared_ptr<WebSocketCallback> callback)
      : m_id(id), m_hdl(hdl), m_status("Connecting"), m_uri(uri),
        m_server("N/A"), m_callback(callback) {}

  void on_open(client *c, websocketpp::connection_hdl hdl) {
    if (strcmp(m_status.c_str(), "Destroyed") == 0) {
      KRAKEN_LOG(VERBOSE) << "[websocket] connection " << m_id
                          << " destroyed...";
      return;
    }
    m_status = "Open";

    client::connection_ptr con = c->get_con_from_hdl(hdl);
    m_server = con->get_response_header("Server");
    if (m_callback != nullptr) {
      m_callback->onOpen();
    }
  }

  void on_fail(client *c, websocketpp::connection_hdl hdl) {
    if (strcmp(m_status.c_str(), "Destroyed") == 0) {
      KRAKEN_LOG(VERBOSE) << "[websocket] connection " << m_id
                          << " destroyed...";
      return;
    }
    m_status = "Failed";

    client::connection_ptr con = c->get_con_from_hdl(hdl);
    m_server = con->get_response_header("Server");
    m_error_reason = con->get_ec().message();
    if (m_callback != nullptr) {
      m_callback->onError(m_error_reason);
    }
  }

  void on_close(client *c, websocketpp::connection_hdl hdl) {
    if (strcmp(m_status.c_str(), "Destroyed") == 0) {
      KRAKEN_LOG(VERBOSE) << "[websocket] connection " << m_id
                          << " destroyed...";
      return;
    }
    m_status = "Closed";
    client::connection_ptr con = c->get_con_from_hdl(hdl);
    std::stringstream s;
    s << "close code: " << con->get_remote_close_code() << " ("
      << websocketpp::close::status::get_string(con->get_remote_close_code())
      << "), close reason: " << con->get_remote_close_reason();
    m_error_reason = s.str();

    if (m_callback != nullptr) {
      m_callback->onClose(con->get_remote_close_code(),
                          con->get_remote_close_reason());
    }
  }

  void on_message(websocketpp::connection_hdl, client::message_ptr msg) {
    if (strcmp(m_status.c_str(), "Destroyed") == 0) {
      KRAKEN_LOG(VERBOSE) << "[websocket] connection " << m_id
                          << " destroyed...";
      return;
    }
    if (msg->get_opcode() == websocketpp::frame::opcode::text) {
      if (m_callback != nullptr) {
        m_callback->onMessage(msg->get_payload());
      }
#ifdef NDEBUG
      m_messages.push_back("<< " + msg->get_payload());
#endif
    } else {
#ifdef NDEBUG
      m_messages.push_back("<< " +
                           websocketpp::utility::to_hex(msg->get_payload()));
#endif
    }
  }

  websocketpp::connection_hdl get_hdl() const { return m_hdl; }

  int get_id() const { return m_id; }

  std::string get_status() const { return m_status; }

  void set_status(const std::string &status) { this->m_status = status; }

  void record_sent_message(std::string message) {
#ifdef NDEBUG
    m_messages.push_back(">> " + message);
#endif
  }

private:
  int m_id;
  websocketpp::connection_hdl m_hdl;
  std::string m_status;
  std::string m_uri;
  std::string m_server;
  std::string m_error_reason;
  std::shared_ptr<WebSocketCallback> m_callback;
#ifdef NDEBUG
  std::vector<std::string> m_messages;
#endif
};

class WebSocketClientImpl : public WebSocketClient {
public:
  WebSocketClientImpl() : m_next_id(0) {
    m_endpoint.clear_access_channels(websocketpp::log::alevel::none);
    m_endpoint.clear_error_channels(websocketpp::log::elevel::all);

    m_endpoint.init_asio();
    m_endpoint.start_perpetual();

    m_thread = websocketpp::lib::make_shared<websocketpp::lib::thread>(
        &client::run, &m_endpoint);
  }

  ~WebSocketClientImpl() {
    m_endpoint.stop_perpetual();
    this->_perform_destroy();
    m_thread->join();
  }

  int connect(const std::string &url,
              std::shared_ptr<WebSocketCallback> callback) override;

  void send(int token, const std::string &message) override;

  void close(int token, int code, const std::string &reason) override;

  connection_metadata::ptr get_metadata(int id) const {
    auto metadata_it = m_connection_list.find(id);
    if (metadata_it == m_connection_list.end()) {
      return connection_metadata::ptr();
    } else {
      return metadata_it->second;
    }
  }

private:
  using conn_list = std::map<int, connection_metadata::ptr>;
  using thread_ptr = websocketpp::lib::shared_ptr<websocketpp::lib::thread>;

  client m_endpoint;
  thread_ptr m_thread;
  conn_list m_connection_list;
  int m_next_id;

  void _perform_destroy();
};

std::unique_ptr<WebSocketClient> WebSocketClient::buildDefault() {
  return std::make_unique<WebSocketClientImpl>();
}

int WebSocketClientImpl::connect(const std::string &url,
                                 std::shared_ptr<WebSocketCallback> callback) {
  websocketpp::lib::error_code ec;
  client::connection_ptr con = m_endpoint.get_connection(url, ec);
  if (ec) {
    KRAKEN_LOG(ERROR) << "[websocket] Connect initialization error: "
                      << ec.message();
    if (callback != nullptr) {
      callback->onError(ec.message());
    }
    return -1;
  }
  int new_id = m_next_id++;
  auto metadata_ptr = websocketpp::lib::make_shared<connection_metadata>(
      new_id, con->get_handle(), url, callback);
  m_connection_list[new_id] = metadata_ptr;

  con->set_open_handler(
      websocketpp::lib::bind(&connection_metadata::on_open, metadata_ptr,
                             &m_endpoint, websocketpp::lib::placeholders::_1));
  con->set_fail_handler(
      websocketpp::lib::bind(&connection_metadata::on_fail, metadata_ptr,
                             &m_endpoint, websocketpp::lib::placeholders::_1));
  con->set_close_handler(
      websocketpp::lib::bind(&connection_metadata::on_close, metadata_ptr,
                             &m_endpoint, websocketpp::lib::placeholders::_1));
  con->set_message_handler(websocketpp::lib::bind(
      &connection_metadata::on_message, metadata_ptr,
      websocketpp::lib::placeholders::_1, websocketpp::lib::placeholders::_2));

  m_endpoint.connect(con);
  return new_id;
}

void WebSocketClientImpl::send(int token, const std::string &message) {
  websocketpp::lib::error_code ec;

  conn_list::iterator metadata_it = m_connection_list.find(token);
  if (metadata_it == m_connection_list.end()) {
    KRAKEN_LOG(VERBOSE) << "[websocket] No connection found with id " << token;
    return;
  }

  m_endpoint.send(metadata_it->second->get_hdl(), message,
                  websocketpp::frame::opcode::text, ec);
  if (ec) {
    KRAKEN_LOG(ERROR) << "[websocket] Error sending message: " << ec.message();
    return;
  }

  metadata_it->second->record_sent_message(message);
}

void WebSocketClientImpl::close(int token, int code,
                                const std::string &reason) {
  websocketpp::lib::error_code ec;

  bool invalid_code =
      websocketpp::close::status::invalid(static_cast<uint16_t>(code));
  if (invalid_code) {
    KRAKEN_LOG(VERBOSE)
        << "[websocket] close code invalid. reset to 1000 : token " << token;
    code = websocketpp::close::status::normal;
  }

  conn_list::iterator metadata_it = m_connection_list.find(token);
  if (metadata_it == m_connection_list.end()) {
    KRAKEN_LOG(VERBOSE) << "[websocket] No connection found with id " << token;
    return;
  }

  m_endpoint.close(metadata_it->second->get_hdl(), static_cast<uint16_t>(code),
                   reason, ec);
  if (ec) {
    KRAKEN_LOG(VERBOSE) << "[websocket] Error initiating close: "
                        << ec.message();
  }
}

void WebSocketClientImpl::_perform_destroy() {
  // 关闭所有活跃连接
  for (auto it = m_connection_list.begin(); it != m_connection_list.end();
       ++it) {
    if (it->second->get_status() != "Open") {
      // Only close open connections
      continue;
    }

    KRAKEN_LOG(VERBOSE) << "[websocket] Closing connection "
                        << it->second->get_id();
    it->second->set_status("Destroyed");
    websocketpp::lib::error_code ec;
    m_endpoint.close(it->second->get_hdl(),
                     websocketpp::close::status::going_away, "", ec);
    if (ec) {
      KRAKEN_LOG(VERBOSE) << "[websocket] Error closing connection "
                          << it->second->get_id() << ": " << ec.message();
    }
  }
}
