/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "paused_notification.h"

namespace kraken {
namespace debugger {

const char *PausedNotification::ReasonEnum::XHR = "XHR";
const char *PausedNotification::ReasonEnum::DOM = "DOM";
const char *PausedNotification::ReasonEnum::EventListener = "EventListener";
const char *PausedNotification::ReasonEnum::Exception = "exception";
const char *PausedNotification::ReasonEnum::Assert = "assert";
const char *PausedNotification::ReasonEnum::DebugCommand = "debugCommand";
const char *PausedNotification::ReasonEnum::PromiseRejection = "promiseRejection";
const char *PausedNotification::ReasonEnum::OOM = "OOM";
const char *PausedNotification::ReasonEnum::Other = "other";
const char *PausedNotification::ReasonEnum::Ambiguous = "ambiguous";

std::unique_ptr<PausedNotification> PausedNotification::fromValue(rapidjson::Value *value,
                                                                  kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<PausedNotification> result(new PausedNotification());
  errors->push();

  if (value->HasMember("callFrames") && (*value)["callFrames"].IsArray()) {
    auto arr = std::make_unique<std::vector<std::unique_ptr<CallFrame>>>();
    for (auto &v : (*value)["callFrames"].GetArray()) {
      if (v.IsObject()) {
        rapidjson::Value _scope = rapidjson::Value(v.GetObject());
        arr->push_back(CallFrame::fromValue(&_scope, errors));
      }
    }
    result->m_callFrames = std::move(arr);
  } else {
    errors->setName("callFrames");
    errors->addError("callFrames not found");
  }

  if (value->HasMember("reason") && (*value)["reason"].IsString()) {
    result->m_reason = (*value)["reason"].GetString();
  } else {
    errors->setName("reason");
    errors->addError("reason not found");
  }

  if (value->HasMember("data")) {
    result->m_data = std::make_unique<rapidjson::Value>((*value)["data"], result->m_holder.GetAllocator());
  }

  if (value->HasMember("hitBreakpoints")) {
    errors->setName("hitBreakpoints");
    if ((*value)["hitBreakpoints"].IsArray()) {
      auto arr = std::make_unique<std::vector<std::string>>();
      for (auto &v : (*value)["hitBreakpoints"].GetArray()) {
        if (v.IsString()) {
          arr->push_back(v.GetString());
        }
      }
      result->m_hitBreakpoints = std::move(arr);
    } else {
      errors->addError("hitBreakpoints should be object");
    }
  }

  if (value->HasMember("asyncStackTrace")) {
    errors->setName("asyncStackTrace");
    if ((*value)["asyncStackTrace"].IsObject()) {
      rapidjson::Value _async_stack_trace = rapidjson::Value((*value)["asyncStackTrace"].GetObject());
      result->m_asyncStackTrace = StackTrace::fromValue(&_async_stack_trace, errors);
    } else {
      errors->addError("asyncStackTrace should be object");
    }
  }

  if (value->HasMember("asyncStackTraceId")) {
    errors->setName("asyncStackTraceId");
    if ((*value)["asyncStackTraceId"].IsObject()) {
      rapidjson::Value _async_stack_trace_id = rapidjson::Value((*value)["asyncStackTraceId"].GetObject());
      result->m_asyncStackTraceId = StackTraceId::fromValue(&_async_stack_trace_id, errors);
    } else {
      errors->addError("asyncStackTraceId should be object");
    }
  }

  if (value->HasMember("asyncCallStackTraceId")) {
    errors->setName("asyncCallStackTraceId");
    if ((*value)["asyncCallStackTraceId"].IsObject()) {
      rapidjson::Value _asyncCallStackTraceId = rapidjson::Value((*value)["asyncCallStackTraceId"].GetObject());
      result->m_asyncCallStackTraceId = StackTraceId::fromValue(&_asyncCallStackTraceId, errors);
    } else {
      errors->addError("asyncCallStackTraceId should be object");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value PausedNotification::toValue(rapidjson::Document::AllocatorType &allocator) const {

  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();

  rapidjson::Value arr = rapidjson::Value(rapidjson::kArrayType);
  arr.SetArray();

  for (const auto &val : *m_callFrames.get()) {
    arr.PushBack(val->toValue(allocator), allocator);
  }
  result.AddMember("callFrames", arr, allocator);

  result.AddMember("reason", m_reason, allocator);
  if (m_data.isJust()) {
    result.AddMember("data", *m_data.fromJust(), allocator);
  }
  if (m_hitBreakpoints.isJust()) {
    rapidjson::Value hit_points = rapidjson::Value(rapidjson::kArrayType);
    hit_points.SetArray();
    for (const auto &val : *m_hitBreakpoints.fromJust()) {
      hit_points.PushBack(rapidjson::Value().SetString(val.c_str(), allocator), allocator);
    }
    result.AddMember("hitBreakpoints", hit_points, allocator);
  }
  if (m_asyncStackTrace.isJust()) {
    result.AddMember("asyncStackTrace", m_asyncStackTrace.fromJust()->toValue(allocator), allocator);
  }
  if (m_asyncStackTraceId.isJust()) {
    result.AddMember("asyncStackTraceId", m_asyncStackTraceId.fromJust()->toValue(allocator), allocator);
  }
  if (m_asyncCallStackTraceId.isJust()) {
    result.AddMember("asyncCallStackTraceId", m_asyncCallStackTraceId.fromJust()->toValue(allocator), allocator);
  }
  return result;
}
} // namespace debugger
} // namespace kraken
