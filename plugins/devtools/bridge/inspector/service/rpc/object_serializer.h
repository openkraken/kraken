/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_JSON_RPC_OBJECT_MAPPBER_H
#define KRAKEN_JSON_RPC_OBJECT_MAPPBER_H

#include <rapidjson/document.h>
#include <rapidjson/writer.h>

#include "inspector/service/rpc/protocol.h"

namespace kraken::debugger {

namespace {
JSONObject clone(rapidjson::Document *doc, JSONObject value) {
  return JSONObject(value, doc->GetAllocator());
}
} // namespace

inline Request serializeRequest(rapidjson::Document document) {
  uint64_t id = document.HasMember("id") ? document["id"].GetUint64() : -1;
  std::string method = document.HasMember("method") ? document["method"].GetString() : "null";
  JSONObject params =
    document.HasMember("params") ? document["params"].GetObject() : JSONObject(rapidjson::kObjectType);
  return {id, method, std::move(params)};
}

inline Response serializeResponse(rapidjson::Document document) {
  uint64_t id = document.HasMember("id") ? document["id"].GetUint64() : -1;
  if (document.HasMember("result")) {
  }
  JSONObject result =
    document.HasMember("result") ? document["result"].GetObject() : JSONObject(rapidjson::kObjectType);
  JSONObject error = document.HasMember("error") ? document["error"].GetObject() : JSONObject(rapidjson::kObjectType);
  return {id, std::move(result), std::move(error)};
}

inline std::string deserializeRequest(Request req) {
  rapidjson::Document doc;
  doc.SetObject();
  doc.AddMember("id", req.id, doc.GetAllocator());
  rapidjson::Value method;
  method.SetString(req.method.c_str(), doc.GetAllocator());
  doc.AddMember("method", method, doc.GetAllocator());
  doc.AddMember("params", clone(&doc, std::move(req.params)), doc.GetAllocator());

  rapidjson::StringBuffer buffer;
  rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
  doc.Accept(writer);
  return buffer.GetString();
}

inline std::string deserializeResponse(Response resp) {
  rapidjson::Document doc;
  doc.SetObject();
  doc.AddMember("id", resp.id, doc.GetAllocator());
  if (!resp.hasError) {
    doc.AddMember("result", clone(&doc, std::move(resp.result)), doc.GetAllocator());
  }

  if (resp.hasError) {
    doc.AddMember("error", clone(&doc, std::move(resp.error)), doc.GetAllocator());
  }

  rapidjson::StringBuffer buffer;
  rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
  doc.Accept(writer);
  return buffer.GetString();
}

inline std::string deserializeError(Error error) {
  rapidjson::Document doc;
  doc.SetObject();

  JSONObject content;
  content.SetObject();
  content.AddMember("code", error.code, doc.GetAllocator());
  rapidjson::Value method;
  method.SetString(error.message.c_str(), doc.GetAllocator());
  content.AddMember("message", method, doc.GetAllocator());
  content.AddMember("data", clone(&doc, std::move(error.data)), doc.GetAllocator());

  doc.AddMember("error", content, doc.GetAllocator());

  rapidjson::StringBuffer buffer;
  rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
  doc.Accept(writer);
  return buffer.GetString();
}

inline std::string deserializeEvent(Event event) {
  rapidjson::Document doc;
  doc.SetObject();

  if (!event.method.empty()) {
    rapidjson::Value method;
    method.SetString(event.method.c_str(), doc.GetAllocator());
    doc.AddMember("method", method, doc.GetAllocator());
  }
  doc.AddMember("params", clone(&doc, std::move(event.params)), doc.GetAllocator());

  rapidjson::StringBuffer buffer;
  rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
  doc.Accept(writer);
  return buffer.GetString();
}

} // namespace kraken
#endif // KRAKEN_JSON_RPC_OBJECT_MAPPBER_H
