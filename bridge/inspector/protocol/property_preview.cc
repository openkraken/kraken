/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "property_preview.h"
#include "inspector/protocol/object_preview.h"

namespace kraken {
namespace debugger {

const char *PropertyPreview::TypeEnum::Object = "object";
const char *PropertyPreview::TypeEnum::Function = "function";
const char *PropertyPreview::TypeEnum::Undefined = "undefined";
const char *PropertyPreview::TypeEnum::String = "string";
const char *PropertyPreview::TypeEnum::Number = "number";
const char *PropertyPreview::TypeEnum::Boolean = "boolean";
const char *PropertyPreview::TypeEnum::Symbol = "symbol";
const char *PropertyPreview::TypeEnum::Accessor = "accessor";
const char *PropertyPreview::TypeEnum::Bigint = "bigint";

const char *PropertyPreview::SubtypeEnum::Array = "array";
const char *PropertyPreview::SubtypeEnum::Null = "null";
const char *PropertyPreview::SubtypeEnum::Node = "node";
const char *PropertyPreview::SubtypeEnum::Regexp = "regexp";
const char *PropertyPreview::SubtypeEnum::Date = "date";
const char *PropertyPreview::SubtypeEnum::Map = "map";
const char *PropertyPreview::SubtypeEnum::Set = "set";
const char *PropertyPreview::SubtypeEnum::Weakmap = "weakmap";
const char *PropertyPreview::SubtypeEnum::Weakset = "weakset";
const char *PropertyPreview::SubtypeEnum::Iterator = "iterator";
const char *PropertyPreview::SubtypeEnum::Generator = "generator";
const char *PropertyPreview::SubtypeEnum::Error = "error";

std::unique_ptr<PropertyPreview> PropertyPreview::fromValue(rapidjson::Value *value,
                                                            kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<PropertyPreview> result(new PropertyPreview());
  errors->push();

  if (value->HasMember("name") && (*value)["name"].IsString()) {
    result->m_name = (*value)["name"].GetString();
  } else {
    errors->setName("name");
    errors->addError("name not found");
  }

  if (value->HasMember("type") && (*value)["type"].IsString()) {
    result->m_type = (*value)["type"].GetString();
  } else {
    errors->setName("type");
    errors->addError("type not found");
  }

  if (value->HasMember("value")) {
    errors->setName("value");
    if ((*value)["value"].IsString()) {
      result->m_value = (*value)["value"].GetString();
    } else {
      errors->addError("value should be string");
    }
  }

  if (value->HasMember("valuePreview")) {
    errors->setName("valuePreview");
    if ((*value)["valuePreview"].IsObject()) {
      rapidjson::Value _preview = (*value)["valuePreview"].GetObject();
      result->m_valuePreview = ObjectPreview::fromValue(&_preview, errors);
    } else {
      errors->addError("valuePreview should be object");
    }
  }

  if (value->HasMember("subtype")) {
    errors->setName("subtype");
    if ((*value)["subtype"].IsString()) {
      result->m_subtype = (*value)["subtype"].GetString();
    } else {
      errors->addError("subtype should be string");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value PropertyPreview::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);
  result.AddMember("name", m_name, allocator);
  result.AddMember("type", m_type, allocator);
  if (m_value.isJust()) result.AddMember("value", m_value.fromJust(), allocator);
  if (m_valuePreview.isJust())
    result.AddMember("valuePreview", m_valuePreview.fromJust()->toValue(allocator), allocator);
  if (m_subtype.isJust()) result.AddMember("subtype", m_subtype.fromJust(), allocator);
  return result;
}
} // namespace debugger
} // namespace kraken
