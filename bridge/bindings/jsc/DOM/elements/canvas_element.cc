/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "canvas_element.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

JSCanvasElement *JSCanvasElement::instance(JSContext *context) {
  auto instanceMap = getInstanceMap();
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSCanvasElement(context);
  }
  return instanceMap[context];
}

std::unordered_map<JSContext *, JSCanvasElement *> & JSCanvasElement::getInstanceMap() {
  static std::unordered_map<JSContext *, JSCanvasElement *> instanceMap;
  return instanceMap;
}

JSCanvasElement::~JSCanvasElement() {
  auto instanceMap = getInstanceMap();
  instanceMap.erase(context);
}

JSCanvasElement::JSCanvasElement(JSContext *context) : JSElement(context) {}

JSObjectRef JSCanvasElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                 const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new CanvasElementInstance(this);
  return instance->object;
}

JSCanvasElement::CanvasElementInstance::CanvasElementInstance(JSCanvasElement *jsCanvasElement)
  : ElementInstance(jsCanvasElement, "canvas", false), nativeCanvasElement(new NativeCanvasElement(nativeElement)) {

  std::string tagName = "canvas";
  auto args = buildUICommandArgs(tagName);

  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UICommand::createElement, args, 1, nativeCanvasElement);
}

JSCanvasElement::CanvasElementInstance::~CanvasElementInstance() {
  delete nativeCanvasElement;
}

std::vector<JSStringRef> &JSCanvasElement::CanvasElementInstance::getCanvasElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("width"),
    JSStringCreateWithUTF8CString("height"),
    JSStringCreateWithUTF8CString("getContext"),
  };
  return propertyNames;
}

const std::unordered_map<std::string, JSCanvasElement::CanvasElementInstance::CanvasElementProperty> &
JSCanvasElement::CanvasElementInstance::getCanvasElementPropertyMap() {
  static std::unordered_map<std::string, CanvasElementProperty> propertyMap{
    {"width", CanvasElementProperty::kWidth},
    {"height", CanvasElementProperty::kHeight},
    {"getContext", CanvasElementProperty::kGetContext}};
  return propertyMap;
}

JSValueRef JSCanvasElement::CanvasElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getCanvasElementPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    switch (property) {
    case CanvasElementProperty::kWidth: {
      return JSValueMakeNumber(_hostClass->ctx, _width);
    }
    case CanvasElementProperty::kHeight:
      return JSValueMakeNumber(_hostClass->ctx, _height);
    case CanvasElementProperty::kGetContext:
      return m_getContext.function();
    }
  }

  return ElementInstance::getProperty(name, exception);
}

void JSCanvasElement::CanvasElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getCanvasElementPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    switch (property) {
    case CanvasElementProperty::kWidth: {
      _width = JSValueToNumber(_hostClass->ctx, value, exception);

      std::string widthString = std::to_string(_width) + "px";
      auto args = buildUICommandArgs(name, widthString);

      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setStyle, args, 2, nullptr);
      break;
    }
    case CanvasElementProperty::kHeight: {
      _height = JSValueToNumber(_hostClass->ctx, value, exception);

      std::string heightString = std::to_string(_height) + "px";
      auto args = buildUICommandArgs(name, heightString);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setStyle, args, 2, nullptr);
      break;
    }
    default:
      break;
    }
  } else {
    ElementInstance::setProperty(name, value, exception);
  }
}

void JSCanvasElement::CanvasElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getCanvasElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSValueRef JSCanvasElement::CanvasElementInstance::getContext(JSContextRef ctx, JSObjectRef function,
                                                              JSObjectRef thisObject, size_t argumentCount,
                                                              const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'getContext' on 'CanvasElement': 1 argument required, but only 0 present",
                    exception);
    return nullptr;
  }

  JSStringRef contextIdStringRef = JSValueToStringCopy(ctx, arguments[0], exception);

  NativeString contextId{};
  contextId.string = JSStringGetCharactersPtr(contextIdStringRef);
  contextId.length = JSStringGetLength(contextIdStringRef);

  getDartMethod()->flushUICommand();

  auto elementInstance = reinterpret_cast<JSCanvasElement::CanvasElementInstance *>(JSObjectGetPrivate(function));
  assert_m(elementInstance->nativeCanvasElement->getContext != nullptr, "Failed to call getContext(): dart method is nullptr");
  NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D =
    elementInstance->nativeCanvasElement->getContext(elementInstance->nativeCanvasElement, &contextId);
  auto canvasRenderContext2d = CanvasRenderingContext2D::instance(elementInstance->context);
  auto canvasRenderContext2dInstance = new CanvasRenderingContext2D::CanvasRenderingContext2DInstance(
    canvasRenderContext2d, nativeCanvasRenderingContext2D);
  return canvasRenderContext2dInstance->object;
}

CanvasRenderingContext2D *CanvasRenderingContext2D::instance(JSContext *context) {
  static std::unordered_map<JSContext *, CanvasRenderingContext2D *> instanceMap{};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new CanvasRenderingContext2D(context);
  }
  return instanceMap[context];
}

CanvasRenderingContext2D::CanvasRenderingContext2D(JSContext *context)
  : HostClass(context, "CanvasRenderingContext2D") {}

CanvasRenderingContext2D::CanvasRenderingContext2DInstance::CanvasRenderingContext2DInstance(
  CanvasRenderingContext2D *canvasRenderContext2D, NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D)
  : Instance(canvasRenderContext2D), nativeCanvasRenderingContext2D(nativeCanvasRenderingContext2D) {}

CanvasRenderingContext2D::CanvasRenderingContext2DInstance::~CanvasRenderingContext2DInstance() {
  delete nativeCanvasRenderingContext2D;
}

std::vector<JSStringRef> &
CanvasRenderingContext2D::CanvasRenderingContext2DInstance::getCanvasRenderingContext2DPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("font"),        JSStringCreateWithUTF8CString("fillStyle"),
    JSStringCreateWithUTF8CString("strokeStyle"), JSStringCreateWithUTF8CString("fillRect"),
    JSStringCreateWithUTF8CString("clearRect"),   JSStringCreateWithUTF8CString("fillText"),
    JSStringCreateWithUTF8CString("strokeText"),  JSStringCreateWithUTF8CString("save"),
    JSStringCreateWithUTF8CString("restore"),
  };
  return propertyNames;
}

const std::unordered_map<std::string,
                         CanvasRenderingContext2D::CanvasRenderingContext2DInstance::CanvasRenderingContext2DProperty> &
CanvasRenderingContext2D::CanvasRenderingContext2DInstance::getCanvasRenderingContext2DPropertyMap() {
  static const std::unordered_map<std::string, CanvasRenderingContext2DProperty> propertyMap{
    {"font", CanvasRenderingContext2DProperty::kFont},
    {"fillStyle", CanvasRenderingContext2DProperty::kFillStyle},
    {"strokeStyle", CanvasRenderingContext2DProperty::kStrokeStyle},
    {"fillRect", CanvasRenderingContext2DProperty::kFillRect},
    {"clearRect", CanvasRenderingContext2DProperty::kClearRect},
    {"strokeRect", CanvasRenderingContext2DProperty::kStrokeRect},
    {"fillText", CanvasRenderingContext2DProperty::kFillText},
    {"strokeText", CanvasRenderingContext2DProperty::kStrokeText},
    {"save", CanvasRenderingContext2DProperty::kSave},
    {"restore", CanvasRenderingContext2DProperty::kReStore},
  };
  return propertyMap;
}

JSValueRef CanvasRenderingContext2D::CanvasRenderingContext2DInstance::getProperty(std::string &name,
                                                                                   JSValueRef *exception) {
  auto propertyMap = getCanvasRenderingContext2DPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];
    switch (property) {
    case CanvasRenderingContext2DProperty::kFont: {
      return m_font.makeString();
    }
    case CanvasRenderingContext2DProperty::kFillStyle: {
      return m_fillStyle.makeString();
    }
    case CanvasRenderingContext2DProperty::kStrokeStyle: {
      return m_strokeStyle.makeString();
    }
    case CanvasRenderingContext2DProperty::kFillRect: {
      return m_fillRect.function();
    }
    case CanvasRenderingContext2DProperty::kClearRect: {
      return m_clearRect.function();
    }
    case CanvasRenderingContext2DProperty::kStrokeRect: {
      return m_strokeRect.function();
    }
    case CanvasRenderingContext2DProperty::kFillText: {
      return m_fillText.function();
    }
    case CanvasRenderingContext2DProperty::kStrokeText: {
      return m_strokeText.function();
    }
    case CanvasRenderingContext2DProperty::kSave: {
      return m_save.function();
    }
    case CanvasRenderingContext2DProperty::kReStore: {
      return m_restore.function();
    }
    }
  }

  return Instance::getProperty(name, exception);
}

void CanvasRenderingContext2D::CanvasRenderingContext2DInstance::setProperty(std::string &name, JSValueRef value,
                                                                             JSValueRef *exception) {
  auto propertyMap = getCanvasRenderingContext2DPropertyMap();
  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    getDartMethod()->flushUICommand();

    switch (property) {
    case CanvasRenderingContext2DProperty::kFont: {
      JSStringRef font = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_font.setString(font);

      NativeString nativeFont{};
      nativeFont.string = m_font.ptr();
      nativeFont.length = m_font.size();
      assert_m(nativeCanvasRenderingContext2D->setFont != nullptr, "Failed to execute setFont(): dart method is nullptr.");
      nativeCanvasRenderingContext2D->setFont(nativeCanvasRenderingContext2D, &nativeFont);
      break;
    }
    case CanvasRenderingContext2DProperty::kFillStyle: {
      JSStringRef fillStyle = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_fillStyle.setString(fillStyle);

      NativeString nativeFillStyle{};
      nativeFillStyle.string = m_fillStyle.ptr();
      nativeFillStyle.length = m_fillStyle.size();
      assert_m(nativeCanvasRenderingContext2D->setFillStyle != nullptr, "Failed to execute setFillStyle(): dart method is nullptr.");
      nativeCanvasRenderingContext2D->setFillStyle(nativeCanvasRenderingContext2D, &nativeFillStyle);
      break;
    }
    case CanvasRenderingContext2DProperty::kStrokeStyle: {
      JSStringRef strokeStyle = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_strokeStyle.setString(strokeStyle);

      NativeString nativeStrokeStyle{};
      nativeStrokeStyle.string = m_strokeStyle.ptr();
      nativeStrokeStyle.length = m_strokeStyle.size();
      assert_m(nativeCanvasRenderingContext2D->setStrokeStyle != nullptr, "Failed to execute setStrokeStyle(): dart method is nullptr.");
      nativeCanvasRenderingContext2D->setStrokeStyle(nativeCanvasRenderingContext2D, &nativeStrokeStyle);
      break;
    }
    default:
      break;
    }
  } else {
    Instance::setProperty(name, value, exception);
  }
}

JSValueRef CanvasRenderingContext2D::CanvasRenderingContext2DInstance::fillRect(JSContextRef ctx, JSObjectRef function,
                                                                                JSObjectRef thisObject,
                                                                                size_t argumentCount,
                                                                                const JSValueRef *arguments,
                                                                                JSValueRef *exception) {
  if (argumentCount != 4) {
    JSC_THROW_ERROR(ctx,
                    ("Failed to execute 'fillRect' on 'CanvasRenderingContext2D': 4 arguments required, but only " +
                     std::to_string(argumentCount) + " present.")
                      .c_str(),
                    exception);
    return nullptr;
  }

  double x = JSValueToNumber(ctx, arguments[0], exception);
  double y = JSValueToNumber(ctx, arguments[1], exception);
  double width = JSValueToNumber(ctx, arguments[2], exception);
  double height = JSValueToNumber(ctx, arguments[3], exception);

  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->fillRect != nullptr, "Failed to execute fillRect(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->fillRect(instance->nativeCanvasRenderingContext2D, x, y, width, height);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::CanvasRenderingContext2DInstance::clearRect(JSContextRef ctx, JSObjectRef function,
                                                                                 JSObjectRef thisObject,
                                                                                 size_t argumentCount,
                                                                                 const JSValueRef *arguments,
                                                                                 JSValueRef *exception) {
  if (argumentCount != 4) {
    JSC_THROW_ERROR(ctx,
                    ("Failed to execute 'clearRect' on 'CanvasRenderingContext2D': 4 arguments required, but only " +
                     std::to_string(argumentCount) + " present.")
                      .c_str(),
                    exception);
    return nullptr;
  }

  double x = JSValueToNumber(ctx, arguments[0], exception);
  double y = JSValueToNumber(ctx, arguments[1], exception);
  double width = JSValueToNumber(ctx, arguments[2], exception);
  double height = JSValueToNumber(ctx, arguments[3], exception);

  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->clearRect != nullptr, "Failed to execute clearRect(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->clearRect(instance->nativeCanvasRenderingContext2D, x, y, width, height);

  return nullptr;
}

JSValueRef CanvasRenderingContext2D::CanvasRenderingContext2DInstance::strokeRect(
  JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef *arguments,
  JSValueRef *exception) {
  if (argumentCount != 4) {
    JSC_THROW_ERROR(ctx,
                    ("Failed to execute 'strokeRect' on 'CanvasRenderingContext2D': 4 arguments required, but only " +
                     std::to_string(argumentCount) + " present.")
                      .c_str(),
                    exception);
    return nullptr;
  }

  double x = JSValueToNumber(ctx, arguments[0], exception);
  double y = JSValueToNumber(ctx, arguments[1], exception);
  double width = JSValueToNumber(ctx, arguments[2], exception);
  double height = JSValueToNumber(ctx, arguments[3], exception);

  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->strokeRect != nullptr, "Failed to execute strokeRect(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->strokeRect(instance->nativeCanvasRenderingContext2D, x, y, width, height);

  return nullptr;
}

JSValueRef CanvasRenderingContext2D::CanvasRenderingContext2DInstance::fillText(JSContextRef ctx, JSObjectRef function,
                                                                                JSObjectRef thisObject,
                                                                                size_t argumentCount,
                                                                                const JSValueRef *arguments,
                                                                                JSValueRef *exception) {
  if (argumentCount < 3) {
    JSC_THROW_ERROR(ctx,
                    ("Failed to execute 'fillText' on 'CanvasRenderingContext2D': 3 arguments required, but only " +
                     std::to_string(argumentCount) + " present.")
                      .c_str(),
                    exception);
    return nullptr;
  }

  JSStringRef textStringRef = JSValueToStringCopy(ctx, arguments[0], exception);

  NativeString text{};
  text.string = JSStringGetCharactersPtr(textStringRef);
  text.length = JSStringGetLength(textStringRef);

  double x = JSValueToNumber(ctx, arguments[1], exception);
  double y = JSValueToNumber(ctx, arguments[2], exception);
  double maxWidth = NAN;

  if (argumentCount == 4) {
    maxWidth = JSValueToNumber(ctx, arguments[3], exception);
  }

  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->fillText != nullptr, "Failed to execute fillText(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->fillText(instance->nativeCanvasRenderingContext2D, &text, x, y, maxWidth);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::CanvasRenderingContext2DInstance::strokeText(
  JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef *arguments,
  JSValueRef *exception) {
  if (argumentCount < 3) {
    JSC_THROW_ERROR(ctx,
                    ("Failed to execute 'strokeText' on 'CanvasRenderingContext2D': 3 arguments required, but only " +
                     std::to_string(argumentCount) + " present.")
                      .c_str(),
                    exception);
    return nullptr;
  }

  JSStringRef textStringRef = JSValueToStringCopy(ctx, arguments[0], exception);

  NativeString text{};
  text.string = JSStringGetCharactersPtr(textStringRef);
  text.length = JSStringGetLength(textStringRef);

  double x = JSValueToNumber(ctx, arguments[1], exception);
  double y = JSValueToNumber(ctx, arguments[2], exception);
  double maxWidth = NAN; // optional value

  if (argumentCount == 4) {
    maxWidth = JSValueToNumber(ctx, arguments[3], exception);
  }

  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->strokeText != nullptr, "Failed to execute strokeText(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->strokeText(instance->nativeCanvasRenderingContext2D, &text, x, y, maxWidth);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::CanvasRenderingContext2DInstance::save(JSContextRef ctx, JSObjectRef function,
                                                                            JSObjectRef thisObject,
                                                                            size_t argumentCount,
                                                                            const JSValueRef *arguments,
                                                                            JSValueRef *exception) {
  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->save != nullptr, "Failed to execute save(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->save(instance->nativeCanvasRenderingContext2D);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::CanvasRenderingContext2DInstance::restore(JSContextRef ctx, JSObjectRef function,
                                                                               JSObjectRef thisObject,
                                                                               size_t argumentCount,
                                                                               const JSValueRef *arguments,
                                                                               JSValueRef *exception) {
  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(function));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->restore != nullptr, "Failed to execute restore(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->restore(instance->nativeCanvasRenderingContext2D);
  return nullptr;
}

void CanvasRenderingContext2D::CanvasRenderingContext2DInstance::getPropertyNames(
  JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getCanvasRenderingContext2DPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
