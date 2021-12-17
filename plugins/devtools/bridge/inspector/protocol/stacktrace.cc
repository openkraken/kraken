/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "stacktrace.h"

namespace kraken::debugger {
std::unique_ptr<StackTrace> StackTrace::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<StackTrace> result(new StackTrace());

  errors->push();

  if (value->HasMember("description")) {
    errors->setName("description");
    if ((*value)["description"].IsString()) {
      result->m_description = (*value)["description"].GetString();
    } else {
      errors->addError("description should be string");
    }
  }

  if (value->HasMember("callFrames") && (*value)["callFrames"].IsArray()) {
    auto arr = std::make_unique<std::vector<std::unique_ptr<CallFrame>>>();
    for (auto &v : (*value)["callFrames"].GetArray()) {
      if (v.IsObject()) {
        rapidjson::Value _callFrames = rapidjson::Value(v.GetObject());
        arr->push_back(CallFrame::fromValue(&_callFrames, errors));
      }
    }
    result->m_callFrames = std::move(arr);
  } else {
    errors->setName("callFrames");
    errors->addError("callFrames not found");
  }

  if (value->HasMember("parent")) {
    errors->setName("parent");
    if ((*value)["parent"].IsObject()) {
      rapidjson::Value _parent = rapidjson::Value((*value)["parent"].GetObject());
      result->m_parent = StackTrace::fromValue(&_parent, errors);
    } else {
      errors->addError("parent should be object");
    }
  }

  if (value->HasMember("parentId")) {
    errors->setName("parentId");
    if ((*value)["parentId"].IsObject()) {
      rapidjson::Value _parent_id = rapidjson::Value((*value)["parentId"].GetObject());
      result->m_parentId = StackTraceId::fromValue(&_parent_id, errors);
    } else {
      errors->addError("parentId should be object");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value StackTrace::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();

  if (m_description.isJust()) {
    result.AddMember("description", m_description.fromJust(), allocator);
  }
  rapidjson::Value arr = rapidjson::Value(rapidjson::kArrayType);
  arr.SetArray();

  for (const auto &val : *m_callFrames.get()) {
    arr.PushBack(val->toValue(allocator), allocator);
  }
  result.AddMember("callFrames", arr, allocator);

  if (m_parent.isJust()) {
    result.AddMember("parent", m_parent.fromJust()->toValue(allocator), allocator);
  }
  if (m_parentId.isJust()) {
    result.AddMember("parentId", m_parentId.fromJust()->toValue(allocator), allocator);
  }
  return result;
}
} // namespace kraken
