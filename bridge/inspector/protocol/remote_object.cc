/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "remote_object.h"

namespace kraken {
namespace debugger {

const char *RemoteObject::TypeEnum::Object = "object";
const char *RemoteObject::TypeEnum::Function = "function";
const char *RemoteObject::TypeEnum::Undefined = "undefined";
const char *RemoteObject::TypeEnum::String = "string";
const char *RemoteObject::TypeEnum::Number = "number";
const char *RemoteObject::TypeEnum::Boolean = "boolean";
const char *RemoteObject::TypeEnum::Symbol = "symbol";
const char *RemoteObject::TypeEnum::Bigint = "bigint";

const char *RemoteObject::SubtypeEnum::Array = "array";
const char *RemoteObject::SubtypeEnum::Null = "null";
const char *RemoteObject::SubtypeEnum::Node = "node";
const char *RemoteObject::SubtypeEnum::Regexp = "regexp";
const char *RemoteObject::SubtypeEnum::Date = "date";
const char *RemoteObject::SubtypeEnum::Map = "map";
const char *RemoteObject::SubtypeEnum::Set = "set";
const char *RemoteObject::SubtypeEnum::Weakmap = "weakmap";
const char *RemoteObject::SubtypeEnum::Weakset = "weakset";
const char *RemoteObject::SubtypeEnum::Iterator = "iterator";
const char *RemoteObject::SubtypeEnum::Generator = "generator";
const char *RemoteObject::SubtypeEnum::Error = "error";
const char *RemoteObject::SubtypeEnum::Proxy = "proxy";
const char *RemoteObject::SubtypeEnum::Promise = "promise";
const char *RemoteObject::SubtypeEnum::Typedarray = "typedarray";
const char *RemoteObject::SubtypeEnum::Arraybuffer = "arraybuffer";
const char *RemoteObject::SubtypeEnum::Dataview = "dataview";

std::unique_ptr<RemoteObject> RemoteObject::fromValue(rapidjson::Value *value, kraken::debugger::ErrorSupport *errors) {
  if (!value || !value->IsObject()) {
    errors->addError("object expected");
    return nullptr;
  }

  std::unique_ptr<RemoteObject> result(new RemoteObject());
  errors->push();
  errors->setName("type");
  if (value->HasMember("type") && (*value)["type"].IsString()) {
    result->m_type = (*value)["type"].GetString();
  } else {
    errors->addError("type not found or not string");
  }

  if (value->HasMember("subtype")) {
    errors->setName("subtype");
    if ((*value)["subtype"].IsString()) {
      result->m_subtype = (*value)["subtype"].GetString();
    } else {
      errors->addError("subtype should be string");
    }
  }

  if (value->HasMember("className")) {
    errors->setName("className");
    if ((*value)["className"].IsString()) {
      result->m_className = (*value)["className"].GetString();
    } else {
      errors->addError("className should be string");
    }
  }

  if (value->HasMember("value")) {
    result->m_value = std::make_unique<rapidjson::Value>((*value)["value"], result->m_holder.GetAllocator());
  }

  if (value->HasMember("unserializableValue")) {
    errors->setName("unserializableValue");
    if ((*value)["unserializableValue"].IsString()) {
      result->m_unserializableValue = (*value)["unserializableValue"].GetString();
    } else {
      errors->addError("unserializableValue should be string");
    }
  }

  if (value->HasMember("description")) {
    errors->setName("description");
    if ((*value)["description"].IsString()) {
      result->m_description = (*value)["description"].GetString();
    } else {
      errors->addError("description should be string");
    }
  }

  if (value->HasMember("objectId")) {
    errors->setName("objectId");
    if ((*value)["objectId"].IsString()) {
      result->m_objectId = (*value)["objectId"].GetString();
    } else {
      errors->addError("objectId should be string");
    }
  }

  if (value->HasMember("preview")) {
    if ((*value)["preview"].IsObject()) {
      rapidjson::Value _preview = (*value)["preview"].GetObject();
      result->m_preview = ObjectPreview::fromValue(&_preview, errors);
    } else {
      errors->setName("preview");
      errors->addError("preview not found");
    }
  }

  errors->pop();
  if (errors->hasErrors()) return nullptr;
  return result;
}

rapidjson::Value RemoteObject::toValue(rapidjson::Document::AllocatorType &allocator) const {
  rapidjson::Value result = rapidjson::Value(rapidjson::kObjectType);
  result.SetObject();

  result.AddMember("type", m_type, allocator);

  if (m_subtype.isJust()) {
    result.AddMember("subtype", m_subtype.fromJust(), allocator);
  }
  if (m_className.isJust()) {
    result.AddMember("className", m_className.fromJust(), allocator);
  }
  if (m_value.isJust()) {
    result.AddMember("value", *m_value.fromJust(), allocator);
  }
  if (m_unserializableValue.isJust()) {
    result.AddMember("unserializableValue", m_unserializableValue.fromJust(), allocator);
  }
  if (m_description.isJust()) {
    result.AddMember("description", m_description.fromJust(), allocator);
  }
  if (m_objectId.isJust()) {
    result.AddMember("objectId", m_objectId.fromJust(), allocator);
  }
  if (m_preview.isJust()) {
    result.AddMember("preview", m_preview.fromJust()->toValue(allocator), allocator);
  }
  return result;
}
} // namespace debugger
} // namespace kraken
