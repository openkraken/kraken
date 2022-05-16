/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "css_style_declaration.h"
#include <vector>
#include "core/dom/element.h"
#include "core/executing_context.h"

namespace kraken {

template <typename CharacterType>
inline bool isASCIILower(CharacterType character) {
  return character >= 'a' && character <= 'z';
}

template <typename CharacterType>
inline CharacterType toASCIIUpper(CharacterType character) {
  return character & ~(isASCIILower(character) << 5);
}

static std::string parseJavaScriptCSSPropertyName(std::string& propertyName) {
  static std::unordered_map<std::string, std::string> propertyCache{};

  if (propertyCache.count(propertyName) > 0) {
    return propertyCache[propertyName];
  }

  std::vector<char> buffer(propertyName.size() + 1);

  size_t hyphen = 0;
  for (size_t i = 0; i < propertyName.size(); ++i) {
    char c = propertyName[i + hyphen];
    if (!c)
      break;
    if (c == '-') {
      hyphen++;
      buffer[i] = toASCIIUpper(propertyName[i + hyphen]);
    } else {
      buffer[i] = c;
    }
  }

  buffer.emplace_back('\0');

  std::string result = std::string(buffer.data());

  propertyCache[propertyName] = result;
  return result;
}

CSSStyleDeclaration* CSSStyleDeclaration::Create(ExecutingContext* context, ExceptionState& exception_state) {
  exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Illegal constructor.");
  return nullptr;
}

CSSStyleDeclaration::CSSStyleDeclaration(ExecutingContext* context, int64_t owner_element_target_id)
    : ScriptWrappable(context->ctx()), owner_element_target_id_(owner_element_target_id) {}

AtomicString CSSStyleDeclaration::item(const AtomicString& key, ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString();
  return InternalGetPropertyValue(propertyName);
}

bool CSSStyleDeclaration::SetItem(const AtomicString& key, const AtomicString& value, ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString();
  return InternalSetProperty(propertyName, value);
}

int64_t CSSStyleDeclaration::length() const {
  return properties_.size();
}

AtomicString CSSStyleDeclaration::getPropertyValue(const AtomicString& key, ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString();
  return InternalGetPropertyValue(propertyName);
}

void CSSStyleDeclaration::setProperty(const AtomicString& key,
                                      const AtomicString& value,
                                      ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString();
  InternalSetProperty(propertyName, value);
}

AtomicString CSSStyleDeclaration::removeProperty(const AtomicString& key, ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString();
  return InternalRemoveProperty(propertyName);
}

void CSSStyleDeclaration::CopyWith(CSSStyleDeclaration* inline_style) {
  for (auto& attr : inline_style->properties_) {
    properties_[attr.first] = attr.second;
  }
}

std::string CSSStyleDeclaration::ToString() const {
  if (properties_.empty())
    return "";

  std::string s;

  for (auto& attr : properties_) {
    s += attr.first + ": " + attr.second.ToStdString() + ";";
  }

  s += "\"";
  return s;
}

AtomicString CSSStyleDeclaration::InternalGetPropertyValue(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (LIKELY(properties_.count(name) > 0)) {
    return properties_[name];
  }

  return AtomicString::Empty(ctx());
}

bool CSSStyleDeclaration::InternalSetProperty(std::string& name, const AtomicString& value) {
  name = parseJavaScriptCSSPropertyName(name);

  properties_[name] = value;

  std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
  std::unique_ptr<NativeString> args_02 = value.ToNativeString();
  GetExecutingContext()->uiCommandBuffer()->addCommand(owner_element_target_id_, UICommand::kSetStyle,
                                                       args_01.release(), args_02.release(), nullptr);

  return true;
}

AtomicString CSSStyleDeclaration::InternalRemoveProperty(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (UNLIKELY(properties_.count(name) == 0)) {
    return AtomicString::Empty(ctx());
  }

  AtomicString return_value = properties_[name];
  properties_.erase(name);

  std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx(), JS_NULL);
  GetExecutingContext()->uiCommandBuffer()->addCommand(owner_element_target_id_, UICommand::kSetStyle,
                                                       args_01.release(), args_02.release(), nullptr);

  return return_value;
}

}  // namespace kraken
