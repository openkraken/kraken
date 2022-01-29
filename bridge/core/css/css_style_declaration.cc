/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "css_style_declaration.h"
#include "event_target.h"

namespace kraken {

std::once_flag kinitCSSStyleDeclarationFlag;

void bindCSSStyleDeclaration(ExecutionContext* context) {
  auto style = CSSStyleDeclaration::instance(context);
  context->defineGlobalProperty("CSSStyleDeclaration", style->jsObject);
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

JSValue CSSStyleDeclaration::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }

  JSValue eventTargetValue = argv[0];

  auto eventTargetInstance = static_cast<EventTargetInstance*>(JS_GetOpaque(eventTargetValue, EventTarget::classId(eventTargetValue)));
  auto style = new StyleDeclaration(this, eventTargetInstance);
  return style->jsObject;
}

JSClassID CSSStyleDeclaration::kCSSStyleDeclarationClassId{0};

CSSStyleDeclaration::CSSStyleDeclaration(ExecutionContext* context) : HostClass(context, "CSSStyleDeclaration") {
  std::call_once(kinitCSSStyleDeclarationFlag, []() { JS_NewClassID(&kCSSStyleDeclarationClassId); });
}

IMPL_FUNCTION(CSSStyleDeclaration, setProperty)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2)
    return JS_ThrowTypeError(ctx, "Failed to execute 'setProperty' on 'CSSStyleDeclaration': 2 arguments required, but only %d present.", argc);
  auto* instance = static_cast<StyleDeclaration*>(JS_GetOpaque(this_val, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  JSValue propertyNameValue = argv[0];
  JSValue propertyValue = argv[1];

  const char* cPropertyName = JS_ToCString(ctx, propertyNameValue);
  std::string propertyName = std::string(cPropertyName);

  instance->setProperty(propertyName, propertyValue);

  JS_FreeCString(ctx, cPropertyName);

  return JS_UNDEFINED;
}

IMPL_FUNCTION(CSSStyleDeclaration, removeProperty)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1)
    return JS_ThrowTypeError(ctx, "Failed to execute 'removeProperty' on 'CSSStyleDeclaration': 1 arguments required, but only 0 present.");
  auto* instance = static_cast<StyleDeclaration*>(JS_GetOpaque(this_val, CSSStyleDeclaration::kCSSStyleDeclarationClassId));

  JSValue propertyNameValue = argv[0];

  const char* cPropertyName = JS_ToCString(ctx, propertyNameValue);
  std::string propertyName = std::string(cPropertyName);

  instance->removeProperty(propertyName);

  JS_FreeCString(ctx, cPropertyName);

  return JS_UNDEFINED;
}

IMPL_FUNCTION(CSSStyleDeclaration, getPropertyValue)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1)
    return JS_ThrowTypeError(ctx, "Failed to execute 'getPropertyValue' on 'CSSStyleDeclaration': 1 arguments required, but only 0 present.");
  auto* instance = static_cast<StyleDeclaration*>(JS_GetOpaque(this_val, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  JSValue propertyNameValue = argv[0];
  const char* cPropertyName = JS_ToCString(ctx, propertyNameValue);
  std::string propertyName = std::string(cPropertyName);

  JSValue returnValue = instance->getPropertyValue(propertyName);
  JS_FreeCString(ctx, cPropertyName);
  return returnValue;
}

StyleDeclaration::StyleDeclaration(CSSStyleDeclaration* cssStyleDeclaration, EventTargetInstance* ownerEventTarget)
    : Instance(cssStyleDeclaration, "CSSStyleDeclaration", &m_exoticMethods, CSSStyleDeclaration::kCSSStyleDeclarationClassId, finalize), ownerEventTarget(ownerEventTarget) {
  JS_DupValue(m_ctx, ownerEventTarget->jsObject);
}

StyleDeclaration::~StyleDeclaration() {}

bool StyleDeclaration::setProperty(std::string& name, JSValue value) {
  name = parseJavaScriptCSSPropertyName(name);

  m_properties[name] = jsValueToStdString(m_ctx, value);

  if (ownerEventTarget != nullptr) {
    std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
    std::unique_ptr<NativeString> args_02 = jsValueToNativeString(m_ctx, value);
    m_context->uiCommandBuffer()->addCommand(ownerEventTarget->eventTargetId(), UICommand::setStyle, *args_01, *args_02, nullptr);
  }

  return true;
}

void StyleDeclaration::removeProperty(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (m_properties.count(name) == 0) {
    return;
  }

  m_properties.erase(name);

  if (ownerEventTarget != nullptr) {
    std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
    std::unique_ptr<NativeString> args_02 = jsValueToNativeString(m_ctx, JS_NULL);
    m_context->uiCommandBuffer()->addCommand(ownerEventTarget->eventTargetId(), UICommand::setStyle, *args_01, *args_02, nullptr);
  }
}

JSValue StyleDeclaration::getPropertyValue(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (m_properties.count(name) > 0) {
    return JS_NewString(m_ctx, m_properties[name].c_str());
  }

  return JS_NewString(m_ctx, "");
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

void StyleDeclaration::setCssText(std::string& cssText) {
  parseRules(
      cssText,
      [](void* p, std::string& key, std::string& value) {
        auto* style = static_cast<StyleDeclaration*>(p);
        style->setProperty(key, value);
      },
      this);
}

// TODO: add support for annotation CSS styleSheets.
std::string StyleDeclaration::toString() {
  if (m_properties.empty())
    return "";

  std::string s;

  for (auto& item : m_properties) {
    s += item.first + ": " + item.second + ";";
  }

  s += "\"";
  return s;
}

void StyleDeclaration::copyWith(StyleDeclaration* style) {
  for (auto& item : style->m_properties) {
    m_properties[item.first] = item.second;
  }
}

bool StyleDeclaration::hasObjectProperty(JSContext* ctx, JSValue obj, JSAtom atom) {
  auto* style = static_cast<StyleDeclaration*>(JS_GetOpaque(obj, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  const char* cname = JS_AtomToCString(ctx, atom);
  std::string name = std::string(cname);
  bool match = style->m_properties.count(name) >= 0;
  JS_FreeCString(ctx, cname);
  return match;
}

// Property Accessors
int StyleDeclaration::setObjectProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  auto* style = static_cast<StyleDeclaration*>(JS_GetOpaque(receiver, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  const char* cname = JS_AtomToCString(ctx, atom);
  std::string name = std::string(cname);
  bool success = style->setProperty(name, value);
  JS_FreeCString(ctx, cname);
  return success;
}

JSValue StyleDeclaration::getObjectProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  auto* styleInstance = static_cast<EventTargetInstance*>(JS_GetOpaque(obj, JSValueGetClassId(obj)));
  JSValue prototype = JS_GetPrototype(ctx, styleInstance->jsObject);
  if (JS_HasProperty(ctx, prototype, atom)) {
    JSValue ret = JS_GetPropertyInternal(ctx, prototype, atom, styleInstance->jsObject, 0);
    JS_FreeValue(ctx, prototype);
    return ret;
  }
  JS_FreeValue(ctx, prototype);

  auto* style = static_cast<StyleDeclaration*>(JS_GetOpaque(receiver, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  const char* cname = JS_AtomToCString(ctx, atom);
  std::string name = std::string(cname);
  JSValue result = style->getPropertyValue(name);
  JS_FreeCString(ctx, cname);
  return result;
}

JSClassExoticMethods StyleDeclaration::m_exoticMethods{
    nullptr, nullptr, nullptr, nullptr, nullptr, getObjectProperty, setObjectProperty,
};

void StyleDeclaration::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  Instance::trace(rt, val, mark_func);
  // We should tel gc style relies on element
  JS_MarkValue(rt, ownerEventTarget->jsObject, mark_func);
}

}  // namespace kraken
