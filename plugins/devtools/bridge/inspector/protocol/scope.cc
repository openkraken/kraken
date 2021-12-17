/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "scope.h"

namespace kraken {
namespace debugger {

const char *Scope::TypeEnum::Global = "global";
const char *Scope::TypeEnum::Local = "local";
const char *Scope::TypeEnum::With = "with";
const char *Scope::TypeEnum::Closure = "closure";
const char *Scope::TypeEnum::Catch = "catch";
const char *Scope::TypeEnum::Block = "block";
const char *Scope::TypeEnum::Script = "script";
const char *Scope::TypeEnum::Eval = "eval";
const char *Scope::TypeEnum::Module = "module";

std::unique_ptr<Scope> Scope::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<Scope> result(new Scope());
  errors->push();

  if (value->HasMember("type") && (*value)["type"].IsString()) {
    result->m_type = (*value)["type"].GetString();
  } else {
    errors->setName("type");
    errors->addError("type not found");
  }

  if (value->HasMember("object") && (*value)["object"].IsObject()) {
    rapidjson::Value obj = rapidjson::Value((*value)["object"].GetObject());
    result->m_object = RemoteObject::fromValue(&obj, errors);
  } else {
    errors->setName("object");
    errors->addError("object not found");
  }

  if (value->HasMember("name")) {
    errors->setName("name");
    if ((*value)["name"].IsString()) {
      result->m_name = (*value)["name"].GetString();
    } else {
      errors->addError("name shoud be string");
    }
  }

  if (value->HasMember("startLocation")) {
    errors->setName("startLocation");
    if ((*value)["startLocation"].IsObject()) {
      rapidjson::Value start_loc = rapidjson::Value((*value)["startLocation"].GetObject());
      result->m_startLocation = Location::fromValue(&start_loc, errors);
    } else {
      errors->addError("startLocation should be object");
    }
  }

  if (value->HasMember("endLocation")) {
    errors->setName("startLocation");
    if ((*value)["endLocation"].IsObject()) {
      rapidjson::Value end_loc = rapidjson::Value((*value)["endLocation"].GetObject());
      result->m_endLocation = Location::fromValue(&end_loc, errors);
    } else {
      errors->addError("endLocation should be object");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value Scope::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();

  result.AddMember("type", m_type, allocator);
  result.AddMember("object", m_object->toValue(allocator), allocator);

  if (m_name.isJust()) {
    result.AddMember("name", m_name.fromJust(), allocator);
  }
  if (m_startLocation.isJust()) {
    result.AddMember("startLocation", m_startLocation.fromJust()->toValue(allocator), allocator);
  }
  if (m_endLocation.isJust()) {
    result.AddMember("endLocation", m_endLocation.fromJust()->toValue(allocator), allocator);
  }
  return result;
}
} // namespace debugger
} // namespace kraken
