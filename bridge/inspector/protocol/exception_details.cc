/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "exception_details.h"

namespace kraken {
namespace debugger {
std::unique_ptr<ExceptionDetails> ExceptionDetails::fromValue(rapidjson::Value *value,
                                                              kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<ExceptionDetails> result(new ExceptionDetails());
  errors->push();

  if (value->HasMember("exceptionId") && (*value)["exceptionId"].IsInt()) {
    result->m_exceptionId = (*value)["exceptionId"].GetInt();
  } else {
    errors->setName("exceptionId");
    errors->addError("exceptionId not found");
  }

  if (value->HasMember("text") && (*value)["text"].IsString()) {
    result->m_text = (*value)["text"].GetString();
  } else {
    errors->setName("text");
    errors->addError("text not found");
  }

  if (value->HasMember("lineNumber") && (*value)["lineNumber"].IsInt()) {
    result->m_lineNumber = (*value)["lineNumber"].GetInt();
  } else {
    errors->setName("lineNumber");
    errors->addError("lineNumber not found");
  }

  if (value->HasMember("columnNumber") && (*value)["columnNumber"].IsInt()) {
    result->m_columnNumber = (*value)["columnNumber"].GetInt();
  } else {
    errors->setName("columnNumber");
    errors->addError("columnNumber not found");
  }

  if (value->HasMember("scriptId")) {
    errors->setName("scriptId");
    if ((*value)["scriptId"].IsString()) {
      result->m_scriptId = (*value)["scriptId"].GetString();
    } else {
      errors->addError("scriptId should be string");
    }
  }

  if (value->HasMember("url")) {
    errors->setName("url");
    if ((*value)["url"].IsString()) {
      result->m_url = (*value)["url"].GetString();
    } else {
      errors->addError("url should be string");
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

  if (value->HasMember("exception")) {
    errors->setName("exception");
    if ((*value)["exception"].IsObject()) {
      rapidjson::Value _exception = (*value)["exception"].GetObject();
      result->m_exception = RemoteObject::fromValue(&_exception, errors);
    } else {
      errors->addError("exception should be object");
    }
  }

  if (value->HasMember("executionContextId")) {
    errors->setName("executionContextId");
    if ((*value)["executionContextId"].IsInt()) {
      result->m_executionContextId = (*value)["executionContextId"].GetInt();
    } else {
      errors->addError("executionContextId should be object");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value ExceptionDetails::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();

  result.AddMember("exceptionId", m_exceptionId, allocator);
  result.AddMember("text", m_text, allocator);
  result.AddMember("lineNumber", m_lineNumber, allocator);
  result.AddMember("columnNumber", m_columnNumber, allocator);
  if (m_scriptId.isJust()) result.AddMember("scriptId", m_scriptId.fromJust(), allocator);
  if (m_url.isJust()) result.AddMember("url", m_url.fromJust(), allocator);
  if (m_stackTrace.isJust()) result.AddMember("stackTrace", m_stackTrace.fromJust()->toValue(allocator), allocator);
  if (m_exception.isJust()) result.AddMember("exception", m_exception.fromJust()->toValue(allocator), allocator);
  if (m_executionContextId.isJust()) result.AddMember("executionContextId", m_executionContextId.fromJust(), allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
