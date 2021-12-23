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

JSValue CSSStyleDeclaration::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Illegal constructor");
  }

  JSValue eventTargetValue = argv[0];

  auto eventTargetInstance = static_cast<EventTargetInstance*>(JS_GetOpaque(eventTargetValue, EventTarget::classId(eventTargetValue)));
  auto style = new StyleDeclarationInstance(this, eventTargetInstance);
  return style->jsObject;
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

  const char* cPropertyName = JS_ToCString(ctx, propertyNameValue);
  std::string propertyName = std::string(cPropertyName);

  instance->internalSetProperty(propertyName, propertyValue);

  JS_FreeCString(ctx, cPropertyName);

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

StyleDeclarationInstance::StyleDeclarationInstance(CSSStyleDeclaration* cssStyleDeclaration, EventTargetInstance* ownerEventTarget)
    : Instance(cssStyleDeclaration, "CSSStyleDeclaration", &m_exoticMethods, CSSStyleDeclaration::kCSSStyleDeclarationClassId, finalize), ownerEventTarget(ownerEventTarget) {
  JS_DupValue(m_ctx, ownerEventTarget->jsObject);
}
StyleDeclarationInstance::~StyleDeclarationInstance() {}

bool StyleDeclarationInstance::internalSetProperty(std::string& name, JSValue value) {
  name = parseJavaScriptCSSPropertyName(name);

  properties[name] = jsValueToStdString(m_ctx, value);

  if (ownerEventTarget != nullptr) {
    std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
    std::unique_ptr<NativeString> args_02 = jsValueToNativeString(m_ctx, value);
    foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(ownerEventTarget->eventTargetId(), UICommand::setStyle, *args_01, *args_02, nullptr);
  }

  return true;
}

void StyleDeclarationInstance::internalRemoveProperty(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (properties.count(name) == 0) {
    return;
  }

  properties.erase(name);

  if (ownerEventTarget != nullptr) {
    std::unique_ptr<NativeString> args_01 = stringToNativeString(name);
    std::unique_ptr<NativeString> args_02 = jsValueToNativeString(m_ctx, JS_NULL);
    foundation::UICommandBuffer::instance(m_context->getContextId())->addCommand(ownerEventTarget->eventTargetId(), UICommand::setStyle, *args_01, *args_02, nullptr);
  }
}

JSValue StyleDeclarationInstance::internalGetPropertyValue(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (properties.count(name) > 0) {
    return JS_NewString(m_ctx, properties[name].c_str());
  }

  return JS_NewString(m_ctx, "");
}

// TODO: add support for annotation CSS styleSheets.
std::string StyleDeclarationInstance::toString() {
  if (properties.empty())
    return "";

  std::string s;

  for (auto& attr : properties) {
    s += attr.first + ": " + attr.second + ";";
  }

  s += "\"";
  return s;
}

void StyleDeclarationInstance::copyWith(StyleDeclarationInstance* instance) {
  for (auto& attr : instance->properties) {
    properties[attr.first] = attr.second;
  }
}

int StyleDeclarationInstance::hasProperty(QjsContext* ctx, JSValue obj, JSAtom atom) {
  auto* style = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(obj, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  const char* cname = JS_AtomToCString(ctx, atom);
  std::string name = std::string(cname);
  bool match = style->properties.count(name) >= 0;
  JS_FreeCString(ctx, cname);
  return match;
}

int StyleDeclarationInstance::setProperty(QjsContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  auto* style = static_cast<StyleDeclarationInstance*>(JS_GetOpaque(receiver, CSSStyleDeclaration::kCSSStyleDeclarationClassId));
  const char* cname = JS_AtomToCString(ctx, atom);
  std::string name = std::string(cname);
  bool success = style->internalSetProperty(name, value);
  JS_FreeCString(ctx, cname);
  return success;
}

JSValue StyleDeclarationInstance::getProperty(QjsContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  auto* styleInstance = static_cast<EventTargetInstance*>(JS_GetOpaque(obj, JSValueGetClassId(obj)));
  JSValue prototype = JS_GetPrototype(ctx, styleInstance->jsObject);
  if (JS_HasProperty(ctx, prototype, atom)) {
    JSValue ret = JS_GetPropertyInternal(ctx, prototype, atom, styleInstance->jsObject, 0);
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

void StyleDeclarationInstance::gcMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  Instance::gcMark(rt, val, mark_func);
  // We should tel gc style relies on element
  JS_MarkValue(rt, ownerEventTarget->jsObject, mark_func);
}

}  // namespace kraken::binding::qjs
