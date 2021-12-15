/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "image_element.h"
#include "bindings/qjs/qjs_patch.h"
#include "page.h"

namespace kraken::binding::qjs {

ImageElement::ImageElement(ExecutionContext* context) : Element(context) {
  JS_SetPrototype(m_ctx, m_prototypeObject, Element::instance(m_context)->prototype());
}

void bindImageElement(std::unique_ptr<ExecutionContext>& context) {
  auto* constructor = ImageElement::instance(context.get());
  context->defineGlobalProperty("HTMLImageElement", constructor->jsObject);
  context->defineGlobalProperty("Image", JS_DupValue(context->ctx(), constructor->jsObject));
}

JSValue ImageElement::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  auto instance = new ImageElementInstance(this);
  return instance->jsObject;
}
IMPL_PROPERTY_GETTER(ImageElement, width)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("width");
}
IMPL_PROPERTY_SETTER(ImageElement, width)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string key = "width";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, argv[0]);
  foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
  return JS_NULL;
}
IMPL_PROPERTY_GETTER(ImageElement, height)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("height");
}
IMPL_PROPERTY_SETTER(ImageElement, height)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string key = "height";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, argv[0]);
  foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
  return JS_NULL;
}
IMPL_PROPERTY_GETTER(ImageElement, naturalWidth)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("naturalWidth");
}
IMPL_PROPERTY_GETTER(ImageElement, naturalHeight)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("naturalHeight");
}
IMPL_PROPERTY_GETTER(ImageElement, src)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("src");
}
IMPL_PROPERTY_SETTER(ImageElement, src)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string key = "src";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, argv[0]);
  foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
  return JS_NULL;
}
IMPL_PROPERTY_GETTER(ImageElement, loading)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("loading");
}
IMPL_PROPERTY_SETTER(ImageElement, loading)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string key = "loading";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, argv[0]);
  foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
  return JS_NULL;
}

ImageElementInstance::ImageElementInstance(ImageElement* element) : ElementInstance(element, "img", true) {
  // Protect image instance util load or error event triggered.
  refer();
}

bool ImageElementInstance::dispatchEvent(EventInstance* event) {
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t*>(event->nativeEvent->type->string), event->nativeEvent->type->length);
  std::string eventType = toUTF8(u16EventType);
  bool result = EventTargetInstance::dispatchEvent(event);

  // Free image instance after load or error event triggered.
  if ((eventType == "load" || eventType == "error") && !freed) {
    freed = true;
    unrefer();
  }

  return result;
}

}  // namespace kraken::binding::qjs
