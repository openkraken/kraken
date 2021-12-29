/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
// JSON-RPC 2.0 Protocol
// https://www.jsonrpc.org/specification
//

#ifndef KRAKEN_JSON_RPC_PROTOCOL_H
#define KRAKEN_JSON_RPC_PROTOCOL_H

#include <string>
#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include "kraken_foundation.h"

namespace kraken::debugger {

typedef rapidjson::Value JSONObject;

enum ErrorCode {
  kParseError = -32700,
  kInvalidRequest = -32600,
  kMethodNotFound = -32601,
  kInvalidParams = -32602,
  kInternalError = -32603,
  kServerError = -32000,
};

struct Message {};

struct Request : Message {
public:
  uint64_t id;
  std::string method;
  JSONObject params;

  Request() {}

  Request(uint64_t id, std::string method, JSONObject params)
    : id(id), method(std::move(method)), params(std::move(params)) {}

  Request(Request &&req) : id(req.id), method(std::move(req.method)), params(std::move(req.params)) {}

  Request &operator=(Request &&req) {
    id = req.id;
    method = std::move(req.method);
    params = std::move(req.params);
    return *this;
  }

private:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(Request);
};

struct Response : Message {
public:
  uint64_t id;
  JSONObject result;
  JSONObject error;
  bool hasError;

  Response() {}

  Response(uint64_t id, JSONObject result, JSONObject error, bool hasError = false)
    : id(id), result(std::move(result)), error(std::move(error)), hasError(hasError) {}

  Response(Response &&resp)
    : id(resp.id), result(std::move(resp.result)), error(std::move(resp.error)), hasError(resp.hasError) {}

  Response &operator=(Response &&resp) {
    id = resp.id;
    result = std::move(resp.result);
    error = std::move(resp.error);
    hasError = resp.hasError;
    return *this;
  }

private:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(Response);
};

struct Error : Message {
public:
  ErrorCode code;
  std::string message;
  JSONObject data;

  Error() {}

  Error(ErrorCode code, std::string message, JSONObject data)
    : code(code), message(std::move(message)), data(std::move(data)) {}

  Error(Error &&err) : code(err.code), message(std::move(err.message)), data(std::move(err.data)) {}

  Error &operator=(Error &&err) {
    code = err.code;
    message = std::move(err.message);
    data = std::move(err.data);
    return *this;
  }

private:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(Error);
};

struct Event : Message {
public:
  std::string method;
  JSONObject params;

  Event() {}

  Event(std::string method, JSONObject params) : method(std::move(method)), params(std::move(params)) {}

  Event(Event &&event) : method(std::move(event.method)), params(std::move(event.params)) {}

  Event &operator=(Event &&event) {
    method = std::move(event.method);
    params = std::move(event.params);
    return *this;
  }

private:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(Event);
};
} // namespace kraken

#endif // KRAKEN_JSON_RPC_PROTOCOL_H
