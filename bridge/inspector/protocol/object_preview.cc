/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "object_preview.h"

namespace kraken {
namespace debugger {

const char *ObjectPreview::TypeEnum::Object = "object";
const char *ObjectPreview::TypeEnum::Function = "function";
const char *ObjectPreview::TypeEnum::Undefined = "undefined";
const char *ObjectPreview::TypeEnum::String = "string";
const char *ObjectPreview::TypeEnum::Number = "number";
const char *ObjectPreview::TypeEnum::Boolean = "boolean";
const char *ObjectPreview::TypeEnum::Symbol = "symbol";
const char *ObjectPreview::TypeEnum::Bigint = "bigint";

const char *ObjectPreview::SubtypeEnum::Array = "array";
const char *ObjectPreview::SubtypeEnum::Null = "null";
const char *ObjectPreview::SubtypeEnum::Node = "node";
const char *ObjectPreview::SubtypeEnum::Regexp = "regexp";
const char *ObjectPreview::SubtypeEnum::Date = "date";
const char *ObjectPreview::SubtypeEnum::Map = "map";
const char *ObjectPreview::SubtypeEnum::Set = "set";
const char *ObjectPreview::SubtypeEnum::Weakmap = "weakmap";
const char *ObjectPreview::SubtypeEnum::Weakset = "weakset";
const char *ObjectPreview::SubtypeEnum::Iterator = "iterator";
const char *ObjectPreview::SubtypeEnum::Generator = "generator";
const char *ObjectPreview::SubtypeEnum::Error = "error";

std::unique_ptr<ObjectPreview> ObjectPreview::fromValue(rapidjson::Value *value,
                                                        kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<ObjectPreview> result(new ObjectPreview());
  errors->push();

  if (value->HasMember("type") && (*value)["type"].IsString()) {
    result->m_type = (*value)["type"].GetString();
  } else {
    errors->setName("type");
    errors->addError("type not found");
  }

  if (value->HasMember("subtype")) {
    errors->setName("subtype");
    if ((*value)["subtype"].IsString()) {
      result->m_subtype = (*value)["subtype"].GetString();
    } else {
      errors->addError("subtype not found");
    }
  }

  if (value->HasMember("description")) {
    errors->setName("description");
    if ((*value)["description"].IsString()) {
      result->m_description = (*value)["description"].GetString();
    } else {
      errors->addError("description not found");
    }
  }

  if (value->HasMember("overflow")) {
    errors->setName("overflow");
    if ((*value)["overflow"].IsBool()) {
      result->m_overflow = (*value)["overflow"].GetBool();
    } else {
      errors->addError("overflow should be bool");
    }
  }

  if (value->HasMember("properties") && (*value)["properties"].IsArray()) {
    auto prop_preview_arr = std::make_unique<std::vector<std::unique_ptr<PropertyPreview>>>();
    for (auto &v : (*value)["properties"].GetArray()) {
      if (v.IsObject()) {
        rapidjson::Value _property_preview = rapidjson::Value(v.GetObject());
        prop_preview_arr->push_back(PropertyPreview::fromValue(&_property_preview, errors));
      }
    }
    result->m_properties = std::move(prop_preview_arr);
  }

  if (value->HasMember("entries")) {
    errors->setName("entries");
    if ((*value)["entries"].IsArray()) {
      auto entry_preview_arr = std::make_unique<std::vector<std::unique_ptr<EntryPreview>>>();
      for (auto &v : (*value)["entries"].GetArray()) {
        if (v.IsObject()) {
          rapidjson::Value _entry_preview = rapidjson::Value(v.GetObject());
          entry_preview_arr->push_back(EntryPreview::fromValue(&_entry_preview, errors));
        }
      }
      result->m_entries = std::move(entry_preview_arr);
    } else {
      errors->addError("entries not found");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value ObjectPreview::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result(rapidjson::kObjectType);

  result.AddMember("type", m_type, allocator);
  if (m_subtype.isJust()) result.AddMember("subtype", m_subtype.fromJust(), allocator);
  if (m_description.isJust()) result.AddMember("description", m_description.fromJust(), allocator);
  result.AddMember("overflow", m_overflow, allocator);

  rapidjson::Value _properties = rapidjson::Value(rapidjson::kArrayType);
  _properties.SetArray();

  if (m_properties) {
    for (const auto &val : *m_properties.get()) {
      _properties.PushBack(val->toValue(allocator), allocator);
    }
    result.AddMember("properties", _properties, allocator);
  }

  if (m_entries.isJust()) {
    rapidjson::Value _entries = rapidjson::Value(rapidjson::kArrayType);
    _entries.SetArray();

    for (const auto &val : *m_entries.fromJust()) {
      _entries.PushBack(val->toValue(allocator), allocator);
    }
    result.AddMember("entries", _entries, allocator);
  }
  return result;
}
} // namespace debugger
} // namespace kraken
