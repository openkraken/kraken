/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "style_declaration.h"
#include "event_target.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

std::once_flag kinitCSSStyleDeclarationFlag;

void bindCSSStyleDeclaration(std::unique_ptr<JSContext>& context) {
  auto style = CSSStyleDeclaration::instance(context.get());
  context->defineGlobalProperty("CSSStyleDeclaration", style->classObject);
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

void parseRules(std::string& source, ParseRuleCallback callback, void* context) {
  uint32_t idx = 0;
  uint32_t start = idx;
  uint32_t end = source.length();
  bool is_in_annotation = false;
  bool is_in_search_key = false;

  std::string key;
  std::string value;

  while (idx <= end) {
    char c = source[idx];

    if (c == ' ') {
      start++;
    } else if (c == '/' && source[idx + 1] == '*') {
      is_in_annotation = true;
    } else if (c == '*' && source[idx + 1] == '/') {
      is_in_annotation = false;
    } else if (c == ':' && !is_in_annotation && !is_in_search_key) {
      key = source.substr(start, idx - start);
      start = idx + 1;
      is_in_search_key = true;
    } else if ((c == ';' || idx == end) && !is_in_annotation) {
      value = source.substr(start, idx - start);
      start = idx + 1;
      callback(context, key, value);
      key = "";
      is_in_search_key = false;
    }

    idx++;
  }
}

JSValue CSSStyleDeclaration::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }

  JSValue eventTargetValue = argv[0];

  auto eventTargetInstance = static_cast<EventTargetInstance*>(JS_GetOpaque(eventTargetValue, EventTarget::classId(eventTargetValue)));
  auto style = new StyleDeclarationInstance(this, eventTargetInstance);
  return style->instanceObject;
}

JSClassID CSSStyleDeclaration::kCSSStyleDeclarationClassId{0};

CSSStyleDeclaration::CSSStyleDeclaration(JSContext* context) : HostClass(context, "CSSStyleDeclaration") {
  std::call_once(kinitCSSStyleDeclarationFlag, []() { JS_NewClassID(&kCSSStyleDeclarationClassId); });
}

JSValue CSSStyleDeclaration::setProperty(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2)
    return JS_ThrowTypeError(ctx, "Failed to execute 'setProperty' on 'CSSStyleDeclaration': 2 arguments required, but only %d present.", argc);
  auto* instance = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(this_val, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  JSValue propertyNameValue = argv[0];
  JSValue propertyValue = argv[1];

  std::string propertyName = jsValueToStdString(ctx, propertyNameValue);
  std::string value = jsValueToStdString(ctx, propertyValue);

  instance->internalSetProperty(propertyName, value);

  return JS_UNDEFINED;
}

JSValue CSSStyleDeclaration::removeProperty(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1)
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeProperty' on 'CSSStyleDeclaration': 1 arguments required, but only 0 present.");
  auto* instance = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(this_val, CSSStyleDeclaration::kCSSStyleDeclarationClassId));

  JSValue propertyNameValue = argv[0];

  const char* cPropertyName = JS_ToCString(ctx, propertyNameValue);
  std::string propertyName = std::string(cPropertyName);

  instance->internalRemoveProperty(propertyName);

  JS_FreeCString(ctx, cPropertyName);

  return JS_UNDEFINED;
}

JSValue CSSStyleDeclaration::getPropertyValue(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1)
    return JS_ThrowTypeError(ctx, "Failed to execute 'getPropertyValue' on 'CSSStyleDeclaration': 1 arguments required, but only 0 present.");
  auto* instance = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(this_val, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  JSValue propertyNameValue = argv[0];
  const char* cPropertyName = JS_ToCString(ctx, propertyNameValue);
  std::string propertyName = std::string(cPropertyName);

  JSValue returnValue = instance->internalGetPropertyValue(propertyName);
  JS_FreeCString(ctx, cPropertyName);
  return returnValue;
}

StyleDeclarationInstance::~StyleDeclarationInstance() {}

bool StyleDeclarationInstance::internalSetProperty(std::string& name, std::string& value) {
  name = parseJavaScriptCSSPropertyName(name);

  m_styleRules[name] = value;

  NativeString* args_01 = stringToNativeString(name);
  NativeString* args_02 = stringToNativeString(value);

  foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(m_ownerEventTarget->eventTargetId, UICommand::setStyle, *args_01, *args_02, nullptr);

  return true;
}

void StyleDeclarationInstance::internalSetStyleRules(std::string& rules) {
  parseRules(
      rules,
      [](void* p, std::string& key, std::string& value) {
        auto* style = static_cast<StyleDeclarationInstance*>(p);
        style->internalSetProperty(key, value);
      },
      this);
}

void StyleDeclarationInstance::internalRemoveProperty(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (m_styleRules.count(name) == 0) {
    return;
  }

  m_styleRules.erase(name);

  NativeString* args_01 = stringToNativeString(name);
  NativeString* args_02 = jsValueToNativeString(m_ctx, JS_NULL);

  foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(m_ownerEventTarget->eventTargetId, UICommand::setStyle, *args_01, *args_02, nullptr);
}

JSValue StyleDeclarationInstance::internalGetPropertyValue(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (m_styleRules.count(name) > 0) {
    return JS_NewString(m_ctx, m_styleRules[name].c_str());
  }

  return JS_NewString(m_ctx, "");
}

// TODO: add support for annotation CSS styleSheets.
std::string StyleDeclarationInstance::toString() {
  if (m_styleRules.empty())
    return "";

  std::string s;

  for (auto& attr : m_styleRules) {
    s += attr.first + ": " + attr.second + ";";
  }
  return s;
}

void StyleDeclarationInstance::copyWith(StyleDeclarationInstance* instance) {
  for (auto& attr : instance->m_styleRules) {
    m_styleRules[attr.first] = attr.second;
  }
}

int StyleDeclarationInstance::hasProperty(QjsContext* ctx, JSValue obj, JSAtom atom) {
  auto* style = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(obj, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  const char* cname = JS_AtomToCString(ctx, atom);
  std::string name = std::string(cname);
  bool match = style->m_styleRules.count(name) >= 0;
  JS_FreeCString(ctx, cname);
  return match;
}

int StyleDeclarationInstance::setProperty(QjsContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  auto* style = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(receiver, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  std::string name = jsAtomToStdString(ctx, atom);
  std::string v = jsValueToStdString(ctx, value);
  bool success = style->internalSetProperty(name, v);
  return success;
}

JSValue StyleDeclarationInstance::getProperty(QjsContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  auto* styleInstance = static_cast<EventTargetInstance*>(JS_GetOpaque(obj, JSValueGetClassId(obj)));
  JSValue prototype = JS_GetPrototype(ctx, styleInstance->instanceObject);
  if (JS_HasProperty(ctx, prototype, atom)) {
    JSValue ret = JS_GetPropertyInternal(ctx, prototype, atom, styleInstance->instanceObject, 0);
    JS_FreeValue(ctx, prototype);
    return ret;
  }
  JS_FreeValue(ctx, prototype);

  auto* style = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(receiver, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  const char* cname = JS_AtomToCString(ctx, atom);
  std::string name = std::string(cname);
  JSValue result = style->internalGetPropertyValue(name);
  JS_FreeCString(ctx, cname);
  return result;
}

JSClassExoticMethods StyleDeclarationInstance::m_exoticMethods{
    nullptr, nullptr, nullptr, nullptr, nullptr, getProperty, setProperty,
};

}  // namespace kraken::binding::qjs
