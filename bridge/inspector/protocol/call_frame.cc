/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "call_frame.h"

namespace kraken {
namespace debugger {
std::unique_ptr<CallFrame> CallFrame::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<CallFrame> result(new CallFrame());
  errors->push();

  if (value->HasMember("callFrameId") && (*value)["callFrameId"].IsString()) {
    result->m_callFrameId = (*value)["callFrameId"].GetString();
  } else {
    errors->setName("callFrameId");
    errors->addError("callFrameId not found");
  }

  if (value->HasMember("functionName") && (*value)["functionName"].IsString()) {
    result->m_functionName = (*value)["functionName"].GetString();
  } else {
    errors->setName("functionName");
    errors->addError("functionName not found");
  }

  if (value->HasMember("functionLocation") && (*value)["functionLocation"].IsObject()) {
    errors->setName("functionLocation");
    rapidjson::Value fl = rapidjson::Value((*value)["functionLocation"].GetObject());
    result->m_functionLocation = Location::fromValue(&fl, errors);
  }

  if (value->HasMember("location") && (*value)["location"].IsObject()) {
    rapidjson::Value lo = rapidjson::Value((*value)["location"].GetObject());
    result->m_location = Location::fromValue(&lo, errors);
  } else {
    errors->setName("location");
    errors->addError("location not found");
  }

  if (value->HasMember("url") && (*value)["url"].IsString()) {
    result->m_url = (*value)["url"].GetString();
  } else {
    errors->setName("url");
    errors->addError("url not found");
  }

  if (value->HasMember("scopeChain") && (*value)["scopeChain"].IsArray()) {
    auto arr = std::make_unique<std::vector<std::unique_ptr<Scope>>>();
    for (auto &v : (*value)["scopeChain"].GetArray()) {
      if (v.IsObject()) {
        rapidjson::Value _scope = rapidjson::Value(v.GetObject());
        arr->push_back(Scope::fromValue(&_scope, errors));
      }
    }
    result->m_scopeChain = std::move(arr);
  } else {
    errors->setName("scopeChain");
    errors->addError("scopeChain not found");
  }

  if (value->HasMember("this") && (*value)["this"].IsObject()) {
    rapidjson::Value _this = rapidjson::Value((*value)["this"].GetObject());
    result->m_this = RemoteObject::fromValue(&_this, errors);
  } else {
    errors->setName("this");
    errors->addError("this not found");
  }

  if (value->HasMember("returnValue")) {
    errors->setName("returnValue");
    if ((*value)["returnValue"].IsObject()) {
      rapidjson::Value _retV = rapidjson::Value((*value)["returnValue"].GetObject());
      result->m_returnValue = RemoteObject::fromValue(&_retV, errors);
    } else {
      errors->addError("returnValue should be object");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value CallFrame::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();
  result.AddMember("callFrameId", m_callFrameId, allocator);
  result.AddMember("functionName", m_functionName, allocator);

  if (m_functionLocation.isJust()) {
    result.AddMember("functionLocation", m_functionLocation.fromJust()->toValue(allocator), allocator);
  }
  result.AddMember("location", m_location->toValue(allocator), allocator);
  result.AddMember("url", m_url, allocator);

  rapidjson::Value arr = rapidjson::Value(rapidjson::kArrayType);
  arr.SetArray();

  for (const auto &val : *m_scopeChain.get()) {
    arr.PushBack(val->toValue(allocator), allocator);
  }
  result.AddMember("scopeChain", arr, allocator);
  result.AddMember("this", m_this->toValue(allocator), allocator);

  if (m_returnValue.isJust()) {
    result.AddMember("returnValue", m_returnValue.fromJust()->toValue(allocator), allocator);
  }
  return result;
}
} // namespace debugger
} // namespace kraken
