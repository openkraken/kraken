/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_parsed_notification.h"

namespace kraken {
namespace debugger {
std::unique_ptr<ScriptParsedNotification> ScriptParsedNotification::fromValue(rapidjson::Value *value,
                                                                              kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<ScriptParsedNotification> result(new ScriptParsedNotification());
  errors->push();

  if (value->HasMember("scriptId") && (*value)["scriptId"].IsString()) {
    result->m_scriptId = (*value)["scriptId"].GetString();
  } else {
    errors->setName("scriptId");
    errors->addError("scriptId not found");
  }

  if (value->HasMember("url") && (*value)["url"].IsString()) {
    result->m_url = (*value)["url"].GetString();
  } else {
    errors->setName("url");
    errors->addError("url not found");
  }

  if (value->HasMember("startLine") && (*value)["startLine"].IsInt()) {
    result->m_startLine = (*value)["startLine"].GetInt();
  } else {
    errors->setName("startLine");
    errors->addError("startLine not found");
  }

  if (value->HasMember("startColumn") && (*value)["startColumn"].IsInt()) {
    result->m_startColumn = (*value)["startColumn"].GetInt();
  } else {
    errors->setName("startColumn");
    errors->addError("startColumn not found");
  }

  if (value->HasMember("endLine") && (*value)["endLine"].IsInt()) {
    result->m_endLine = (*value)["endLine"].GetInt();
  } else {
    errors->setName("endLine");
    errors->addError("endLine not found");
  }

  if (value->HasMember("endColumn") && (*value)["endColumn"].IsInt()) {
    result->m_endColumn = (*value)["endColumn"].GetInt();
  } else {
    errors->setName("endColumn");
    errors->addError("endColumn not found");
  }

  if (value->HasMember("executionContextId") && (*value)["executionContextId"].IsInt()) {
    result->m_executionContextId = (*value)["executionContextId"].GetInt();
  } else {
    errors->setName("executionContextId");
    errors->addError("executionContextId not found");
  }

  if (value->HasMember("hash") && (*value)["hash"].IsString()) {
    result->m_hash = (*value)["hash"].GetString();
  } else {
    errors->setName("hash");
    errors->addError("hash not found");
  }

  if (value->HasMember("executionContextAuxData")) {
    result->m_executionContextAuxData =
      std::make_unique<rapidjson::Value>((*value)["executionContextAuxData"], result->m_holder.GetAllocator());
  }

  if (value->HasMember("isLiveEdit")) {
    errors->setName("isLiveEdit");
    if ((*value)["isLiveEdit"].IsBool()) {
      result->m_isLiveEdit = (*value)["isLiveEdit"].GetBool();
    } else {
      errors->addError("isLiveEdit should be bool");
    }
  }

  if (value->HasMember("sourceMapURL")) {
    errors->setName("sourceMapURL");
    if ((*value)["sourceMapURL"].IsString()) {
      result->m_sourceMapURL = (*value)["sourceMapURL"].GetString();
    } else {
      errors->addError("sourceMapURL should be string");
    }
  }

  if (value->HasMember("hasSourceURL")) {
    errors->setName("hasSourceURL");
    if ((*value)["hasSourceURL"].IsBool()) {
      result->m_hasSourceURL = (*value)["hasSourceURL"].GetBool();
    } else {
      errors->addError("hasSourceURL should be boolean");
    }
  }

  if (value->HasMember("isModule")) {
    errors->setName("isModule");
    if ((*value)["isModule"].IsBool()) {
      result->m_isModule = (*value)["isModule"].GetBool();
    } else {
      errors->addError("isModule should be boolean");
    }
  }

  if (value->HasMember("length")) {
    errors->setName("length");
    if ((*value)["length"].IsInt()) {
      result->m_length = (*value)["length"].GetInt();
    } else {
      errors->addError("length should be int");
    }
  }

  if (value->HasMember("stackTrace")) {
    errors->setName("stackTrace");
    if ((*value)["stackTrace"].IsObject()) {
      rapidjson::Value _stack = (*value)["stackTrace"].GetObject();
      result->m_stackTrace = StackTrace::fromValue(&_stack, errors);
    } else {
      errors->addError("stackTrace should be object");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value ScriptParsedNotification::toValue(rapidjson::Document::AllocatorType &allocator) const {

  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();

  result.AddMember("scriptId", m_scriptId, allocator);
  result.AddMember("url", m_url, allocator);
  result.AddMember("startLine", m_startLine, allocator);
  result.AddMember("startColumn", m_startColumn, allocator);
  result.AddMember("endLine", m_endLine, allocator);
  result.AddMember("endColumn", m_endColumn, allocator);
  result.AddMember("executionContextId", m_executionContextId, allocator);
  result.AddMember("hash", m_hash, allocator);
  if (m_executionContextAuxData.isJust())
    result.AddMember("executionContextAuxData", *m_executionContextAuxData.fromJust(), allocator);
  if (m_isLiveEdit.isJust()) result.AddMember("isLiveEdit", m_isLiveEdit.fromJust(), allocator);
  if (m_sourceMapURL.isJust()) result.AddMember("sourceMapURL", m_sourceMapURL.fromJust(), allocator);
  if (m_hasSourceURL.isJust()) result.AddMember("hasSourceURL", m_hasSourceURL.fromJust(), allocator);
  if (m_isModule.isJust()) result.AddMember("isModule", m_isModule.fromJust(), allocator);
  if (m_length.isJust()) result.AddMember("length", m_length.fromJust(), allocator);
  if (m_stackTrace.isJust()) {
    result.AddMember("stackTrace", m_stackTrace.fromJust()->toValue(allocator), allocator);
  }
  return result;
}
} // namespace debugger
} // namespace kraken
