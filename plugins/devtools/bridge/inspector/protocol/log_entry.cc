/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "log_entry.h"

namespace kraken::debugger {
const char *LogEntry::SourceEnum::Xml = "xml";
const char *LogEntry::SourceEnum::Javascript = "javascript";
const char *LogEntry::SourceEnum::Network = "network";
const char *LogEntry::SourceEnum::Storage = "storage";
const char *LogEntry::SourceEnum::Appcache = "appcache";
const char *LogEntry::SourceEnum::Rendering = "rendering";
const char *LogEntry::SourceEnum::Security = "security";
const char *LogEntry::SourceEnum::Deprecation = "deprecation";
const char *LogEntry::SourceEnum::Worker = "worker";
const char *LogEntry::SourceEnum::Violation = "violation";
const char *LogEntry::SourceEnum::Intervention = "intervention";
const char *LogEntry::SourceEnum::Recommendation = "recommendation";
const char *LogEntry::SourceEnum::Other = "other";

const char *LogEntry::LevelEnum::Verbose = "verbose";
const char *LogEntry::LevelEnum::Info = "info";
const char *LogEntry::LevelEnum::Warning = "warning";
const char *LogEntry::LevelEnum::Error = "error";

std::unique_ptr<LogEntry> LogEntry::fromValue(rapidjson::Value *value, ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<LogEntry> result(new LogEntry());
  errors->push();

  if (value->HasMember("source") && (*value)["source"].IsString()) {
    result->m_source = (*value)["source"].GetString();
  } else {
    errors->setName("source");
    errors->addError("source not found");
  }

  if (value->HasMember("level") && (*value)["level"].IsString()) {
    result->m_level = (*value)["level"].GetString();
  } else {
    errors->setName("level");
    errors->addError("level not found");
  }

  if (value->HasMember("text") && (*value)["text"].IsString()) {
    result->m_text = (*value)["text"].GetString();
  } else {
    errors->setName("text");
    errors->addError("text not found");
  }

  if (value->HasMember("timestamp") && (*value)["timestamp"].IsDouble()) {
    result->m_timestamp = (*value)["timestamp"].GetDouble();
  } else {
    errors->setName("timestamp");
    errors->addError("timestamp not found");
  }

  if (value->HasMember("url")) {
    errors->setName("url");
    if ((*value)["url"].IsString()) {
      result->m_url = (*value)["url"].GetString();
    } else {
      errors->addError("url should be string");
    }
  }

  if (value->HasMember("lineNumber")) {
    errors->setName("lineNumber");
    if ((*value)["lineNumber"].IsInt()) {
      result->m_lineNumber = (*value)["lineNumber"].GetInt();
    } else {
      errors->addError("lineNumber should be int");
    }
  }

  if (value->HasMember("stackTrace")) {
    errors->setName("stackTrace");
    if ((*value)["stackTrace"].IsObject()) {
      rapidjson::Value _stack_trace = (*value)["stackTrace"].GetObject();
      result->m_stackTrace = StackTrace::fromValue(&_stack_trace, errors);
    } else {
      errors->addError("stackTrace should be object");
    }
  }

  if (value->HasMember("networkRequestId")) {
    errors->setName("networkRequestId");
    if ((*value)["networkRequestId"].IsString()) {
      result->m_networkRequestId = (*value)["networkRequestId"].GetString();
    } else {
      errors->addError("networkRequestId should be string");
    }
  }

  if (value->HasMember("workerId")) {
    errors->setName("workerId");
    if ((*value)["workerId"].IsString()) {
      result->m_workerId = (*value)["workerId"].GetString();
    } else {
      errors->addError("workerId should be string");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value LogEntry::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);

  result.AddMember("source", m_source, allocator);
  result.AddMember("level", m_level, allocator);
  result.AddMember("text", m_text, allocator);
  result.AddMember("timestamp", m_timestamp, allocator);
  if (m_url.isJust()) result.AddMember("url", m_url.fromJust(), allocator);
  if (m_lineNumber.isJust()) result.AddMember("lineNumber", m_lineNumber.fromJust(), allocator);
  if (m_stackTrace.isJust()) result.AddMember("stackTrace", m_stackTrace.fromJust()->toValue(allocator), allocator);
  if (m_networkRequestId.isJust()) result.AddMember("networkRequestId", m_networkRequestId.fromJust(), allocator);
  if (m_workerId.isJust()) result.AddMember("workerId", m_workerId.fromJust(), allocator);
  return result;
}
} // namespace kraken::debugger
