/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "image_element.h"
#include "bindings/qjs/qjs_patch.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {

ImageElement::ImageElement(JSContext* context) : Element(context) {
  JS_SetPrototype(m_ctx, m_prototypeObject, Element::instance(m_context)->prototype());
}

void bindImageElement(std::unique_ptr<JSContext>& context) {
  auto* constructor = ImageElement::instance(context.get());
  context->defineGlobalProperty("HTMLImageElement", constructor->classObject);
  context->defineGlobalProperty("Image", JS_DupValue(context->ctx(), constructor->classObject));
}

JSValue ImageElement::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  auto instance = new ImageElementInstance(this);
  return instance->instanceObject;
}
PROP_GETTER(ImageElementInstance, width)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("width");
}
PROP_SETTER(ImageElementInstance, width)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string key = "width";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, argv[0]);
  foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
  return JS_NULL;
}
PROP_GETTER(ImageElementInstance, height)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("height");
}
PROP_SETTER(ImageElementInstance, height)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string key = "height";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, argv[0]);
  foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
  return JS_NULL;
}
PROP_GETTER(ImageElementInstance, naturalWidth)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("naturalWidth");
}
PROP_SETTER(ImageElementInstance, naturalWidth)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}
PROP_GETTER(ImageElementInstance, naturalHeight)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("naturalHeight");
}
PROP_SETTER(ImageElementInstance, naturalHeight)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}
PROP_GETTER(ImageElementInstance, src)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("src");
}
PROP_SETTER(ImageElementInstance, src)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  std::string key = "src";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, argv[0]);
  foundation::UICommandBuffer::instance(element->m_context->getContextId())->addCommand(element->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
  return JS_NULL;
}
PROP_GETTER(ImageElementInstance, loading)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  getDartMethod()->flushUICommand();
  auto* element = static_cast<ImageElementInstance*>(JS_GetOpaque(this_val, Element::classId()));
  return element->getNativeProperty("loading");
}
PROP_SETTER(ImageElementInstance, loading)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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
