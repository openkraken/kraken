/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "canvas_element.h"
#include "foundation/ui_command_callback_queue.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

std::unordered_map<JSContext *, JSCanvasElement *> JSCanvasElement::instanceMap{};

JSCanvasElement::~JSCanvasElement() {
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
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UICommand::createElement, args_01, nativeCanvasElement);
}

JSCanvasElement::CanvasElementInstance::~CanvasElementInstance() {
  ::foundation::UICommandCallbackQueue::instance()->registerCallback(
    [](void *ptr) { delete reinterpret_cast<NativeCanvasElement *>(ptr); }, nativeCanvasElement);
}

JSValueRef JSCanvasElement::CanvasElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getCanvasElementPropertyMap();
  auto prototypePropertyMap = getCanvasElementPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<JSCanvasElement>()->prototypeObject, nameStringHolder.getString(), exception);
  };

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case CanvasElementProperty::width: {
      return JSValueMakeNumber(_hostClass->ctx, _width);
    }
    case CanvasElementProperty::height:
      return JSValueMakeNumber(_hostClass->ctx, _height);
    }
  }

  return ElementInstance::getProperty(name, exception);
}

bool JSCanvasElement::CanvasElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = getCanvasElementPropertyMap();
  auto prototypePropertyMap = getCanvasElementPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) return false;

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case CanvasElementProperty::width: {
      _width = JSValueToNumber(_hostClass->ctx, value, exception);

      std::string widthString = std::to_string(_width) + "px";

      NativeString args_01{};
      NativeString args_02{};

      buildUICommandArgs(name, widthString, args_01, args_02);

      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    case CanvasElementProperty::height: {
      _height = JSValueToNumber(_hostClass->ctx, value, exception);

      std::string heightString = std::to_string(_height) + "px";

      NativeString args_01{};
      NativeString args_02{};

      buildUICommandArgs(name, heightString, args_01, args_02);
      foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
        ->registerCommand(eventTargetId, UICommand::setProperty, args_01, args_02, nullptr);
      break;
    }
    default:
      break;
    }
    return true;
  } else {
    return ElementInstance::setProperty(name, value, exception);
  }
}

void JSCanvasElement::CanvasElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  ElementInstance::getPropertyNames(accumulator);

  for (auto &property : getCanvasElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : getCanvasElementPrototypePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSValueRef JSCanvasElement::getContext(JSContextRef ctx, JSObjectRef function,
                                                              JSObjectRef thisObject, size_t argumentCount,
                                                              const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to execute 'getContext' on 'CanvasElement': 1 argument required, but only 0 present",
                    exception);
    return nullptr;
  }

  JSStringRef contextIdStringRef = JSValueToStringCopy(ctx, arguments[0], exception);

  NativeString contextId{};
  contextId.string = JSStringGetCharactersPtr(contextIdStringRef);
  contextId.length = JSStringGetLength(contextIdStringRef);

  getDartMethod()->flushUICommand();

  auto elementInstance = reinterpret_cast<JSCanvasElement::CanvasElementInstance *>(JSObjectGetPrivate(thisObject));
  assert_m(elementInstance->nativeCanvasElement->getContext != nullptr,
           "Failed to call getContext(): dart method is nullptr");
  NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D =
    elementInstance->nativeCanvasElement->getContext(elementInstance->nativeCanvasElement, &contextId);
  auto canvasRenderContext2d = CanvasRenderingContext2D::instance(elementInstance->context);
  auto canvasRenderContext2dInstance = new CanvasRenderingContext2D::CanvasRenderingContext2DInstance(
    canvasRenderContext2d, nativeCanvasRenderingContext2D);
  return canvasRenderContext2dInstance->object;
}

std::unordered_map<JSContext *, CanvasRenderingContext2D *> CanvasRenderingContext2D::instanceMap{};

CanvasRenderingContext2D::CanvasRenderingContext2D(JSContext *context)
  : HostClass(context, "CanvasRenderingContext2D") {}

CanvasRenderingContext2D::CanvasRenderingContext2DInstance::CanvasRenderingContext2DInstance(
  CanvasRenderingContext2D *canvasRenderContext2D, NativeCanvasRenderingContext2D *nativeCanvasRenderingContext2D)
  : Instance(canvasRenderContext2D), nativeCanvasRenderingContext2D(nativeCanvasRenderingContext2D) {}

CanvasRenderingContext2D::CanvasRenderingContext2DInstance::~CanvasRenderingContext2DInstance() {
  ::foundation::UICommandCallbackQueue::instance()->registerCallback(
    [](void *ptr) { delete reinterpret_cast<NativeCanvasRenderingContext2D *>(ptr); }, nativeCanvasRenderingContext2D);
}

JSValueRef CanvasRenderingContext2D::CanvasRenderingContext2DInstance::getProperty(std::string &name,
                                                                                   JSValueRef *exception) {
  auto propertyMap = getCanvasRenderingContext2DPropertyMap();
  auto prototypePropertyMap = getCanvasRenderingContext2DPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<CanvasRenderingContext2D>()->prototypeObject, nameStringHolder.getString(), exception);
  }

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case CanvasRenderingContext2DProperty::font: {
      return m_font.makeString();
    }
    case CanvasRenderingContext2DProperty::fillStyle: {
      return m_fillStyle.makeString();
    }
    case CanvasRenderingContext2DProperty::strokeStyle: {
      return m_strokeStyle.makeString();
    }
    }
  }

  return Instance::getProperty(name, exception);
}

bool CanvasRenderingContext2D::CanvasRenderingContext2DInstance::setProperty(std::string &name, JSValueRef value,
                                                                             JSValueRef *exception) {
  auto propertyMap = getCanvasRenderingContext2DPropertyMap();
  auto prototypePropertyMap = getCanvasRenderingContext2DPrototypePropertyMap();
  JSStringHolder nameStringHolder = JSStringHolder(context, name);

  if (prototypePropertyMap.count(name) > 0) {
    return JSObjectGetProperty(ctx, prototype<CanvasRenderingContext2D>()->prototypeObject, nameStringHolder.getString(), exception);
  }

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    getDartMethod()->flushUICommand();

    switch (property) {
    case CanvasRenderingContext2DProperty::font: {
      JSStringRef font = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_font.setString(font);

      NativeString nativeFont{};
      nativeFont.string = m_font.ptr();
      nativeFont.length = m_font.size();
      assert_m(nativeCanvasRenderingContext2D->setFont != nullptr,
               "Failed to execute setFont(): dart method is nullptr.");
      nativeCanvasRenderingContext2D->setFont(nativeCanvasRenderingContext2D, &nativeFont);
      break;
    }
    case CanvasRenderingContext2DProperty::fillStyle: {
      JSStringRef fillStyle = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_fillStyle.setString(fillStyle);

      NativeString nativeFillStyle{};
      nativeFillStyle.string = m_fillStyle.ptr();
      nativeFillStyle.length = m_fillStyle.size();
      assert_m(nativeCanvasRenderingContext2D->setFillStyle != nullptr,
               "Failed to execute setFillStyle(): dart method is nullptr.");
      nativeCanvasRenderingContext2D->setFillStyle(nativeCanvasRenderingContext2D, &nativeFillStyle);
      break;
    }
    case CanvasRenderingContext2DProperty::strokeStyle: {
      JSStringRef strokeStyle = JSValueToStringCopy(_hostClass->ctx, value, exception);
      m_strokeStyle.setString(strokeStyle);

      NativeString nativeStrokeStyle{};
      nativeStrokeStyle.string = m_strokeStyle.ptr();
      nativeStrokeStyle.length = m_strokeStyle.size();
      assert_m(nativeCanvasRenderingContext2D->setStrokeStyle != nullptr,
               "Failed to execute setStrokeStyle(): dart method is nullptr.");
      nativeCanvasRenderingContext2D->setStrokeStyle(nativeCanvasRenderingContext2D, &nativeStrokeStyle);
      break;
    }
    default:
      break;
    }
    return true;
  } else {
    return Instance::setProperty(name, value, exception);
  }
}

JSValueRef CanvasRenderingContext2D::arc(JSContextRef ctx, JSObjectRef function,
                                                                                JSObjectRef thisObject,
                                                                                size_t argumentCount,
                                                                                const JSValueRef *arguments,
                                                                                JSValueRef *exception) {
  if (argumentCount != 5 || argumentCount != 6) {
    throwJSError(ctx,
                    ("Failed to execute 'arc' on 'CanvasRenderingContext2D':  5 or 6 arguments required, but only " +
                     std::to_string(argumentCount) + " present.")
                      .c_str(),
                    exception);
    return nullptr;
  }

  double x = JSValueToNumber(ctx, arguments[0], exception);
  double y = JSValueToNumber(ctx, arguments[1], exception);
  double radius = JSValueToNumber(ctx, arguments[2], exception);
  double startAngle = JSValueToNumber(ctx, arguments[3], exception);
  double endAngle = JSValueToNumber(ctx, arguments[4], exception);
  // An optional Boolean. If true, draws the arc counter-clockwise between the start and end angles.
  // The default is false (clockwise).
  // 0 will become false, and 1 for true
  double counterclockwise = false;
  if (argumentCount == 6) {
    counterclockwise = JSValueToBoolean(ctx, arguments[5]);
  }

  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->arc != nullptr,
           "Failed to execute arc(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->arc(instance->nativeCanvasRenderingContext2D, x, y, radius, startAngle, endAngle, counterclockwise ? 1 : 0);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::arcTo(JSContextRef ctx, JSObjectRef function,
                                                                                JSObjectRef thisObject,
                                                                                size_t argumentCount,
                                                                                const JSValueRef *arguments,
                                                                                JSValueRef *exception) {
  if (argumentCount != 5) {
    throwJSError(ctx,
                    ("Failed to execute 'arcTo' on 'CanvasRenderingContext2D':  5 arguments required, but only " +
                     std::to_string(argumentCount) + " present.")
                      .c_str(),
                    exception);
    return nullptr;
  }

  double x1 = JSValueToNumber(ctx, arguments[0], exception);
  double y1 = JSValueToNumber(ctx, arguments[1], exception);
  double x2 = JSValueToNumber(ctx, arguments[2], exception);
  double y2 = JSValueToNumber(ctx, arguments[3], exception);
  double radius = JSValueToNumber(ctx, arguments[4], exception);

  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->arcTo != nullptr,
           "Failed to execute arcTo(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->arcTo(instance->nativeCanvasRenderingContext2D, x1, y1, x2, y2, radius);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::translate(JSContextRef ctx, JSObjectRef function,
                                                                                JSObjectRef thisObject,
                                                                                size_t argumentCount,
                                                                                const JSValueRef *arguments,
                                                                                JSValueRef *exception) {
  if (argumentCount != 2) {
    throwJSError(ctx,
                    ("Failed to execute 'translate' on 'CanvasRenderingContext2D':  2 arguments required, but only " +
                     std::to_string(argumentCount) + " present.")
                      .c_str(),
                    exception);
    return nullptr;
  }

  double x = JSValueToNumber(ctx, arguments[0], exception);
  double y = JSValueToNumber(ctx, arguments[1], exception);

  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->translate != nullptr,
           "Failed to execute translate(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->translate(instance->nativeCanvasRenderingContext2D, x, y);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::fillRect(JSContextRef ctx, JSObjectRef function,
                                                                                JSObjectRef thisObject,
                                                                                size_t argumentCount,
                                                                                const JSValueRef *arguments,
                                                                                JSValueRef *exception) {
  if (argumentCount != 4) {
    throwJSError(ctx,
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
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->fillRect != nullptr,
           "Failed to execute fillRect(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->fillRect(instance->nativeCanvasRenderingContext2D, x, y, width, height);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::clearRect(JSContextRef ctx, JSObjectRef function,
                                                                                 JSObjectRef thisObject,
                                                                                 size_t argumentCount,
                                                                                 const JSValueRef *arguments,
                                                                                 JSValueRef *exception) {
  if (argumentCount != 4) {
    throwJSError(ctx,
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
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->clearRect != nullptr,
           "Failed to execute clearRect(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->clearRect(instance->nativeCanvasRenderingContext2D, x, y, width, height);

  return nullptr;
}

JSValueRef CanvasRenderingContext2D::strokeRect(
  JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef *arguments,
  JSValueRef *exception) {
  if (argumentCount != 4) {
    throwJSError(ctx,
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
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->strokeRect != nullptr,
           "Failed to execute strokeRect(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->strokeRect(instance->nativeCanvasRenderingContext2D, x, y, width, height);

  return nullptr;
}

JSValueRef CanvasRenderingContext2D::fillText(JSContextRef ctx, JSObjectRef function,
                                                                                JSObjectRef thisObject,
                                                                                size_t argumentCount,
                                                                                const JSValueRef *arguments,
                                                                                JSValueRef *exception) {
  if (argumentCount < 3) {
    throwJSError(ctx,
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
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->fillText != nullptr,
           "Failed to execute fillText(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->fillText(instance->nativeCanvasRenderingContext2D, &text, x, y, maxWidth);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::strokeText(
  JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef *arguments,
  JSValueRef *exception) {
  if (argumentCount < 3) {
    throwJSError(ctx,
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
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->strokeText != nullptr,
           "Failed to execute strokeText(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->strokeText(instance->nativeCanvasRenderingContext2D, &text, x, y, maxWidth);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::save(JSContextRef ctx, JSObjectRef function,
                                                                            JSObjectRef thisObject,
                                                                            size_t argumentCount,
                                                                            const JSValueRef *arguments,
                                                                            JSValueRef *exception) {
  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->save != nullptr,
           "Failed to execute save(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->save(instance->nativeCanvasRenderingContext2D);
  return nullptr;
}

JSValueRef CanvasRenderingContext2D::restore(JSContextRef ctx, JSObjectRef function,
                                                                               JSObjectRef thisObject,
                                                                               size_t argumentCount,
                                                                               const JSValueRef *arguments,
                                                                               JSValueRef *exception) {
  auto instance =
    reinterpret_cast<CanvasRenderingContext2D::CanvasRenderingContext2DInstance *>(JSObjectGetPrivate(thisObject));

  getDartMethod()->flushUICommand();
  assert_m(instance->nativeCanvasRenderingContext2D->restore != nullptr,
           "Failed to execute restore(): dart method is nullptr.");
  instance->nativeCanvasRenderingContext2D->restore(instance->nativeCanvasRenderingContext2D);
  return nullptr;
}

void CanvasRenderingContext2D::CanvasRenderingContext2DInstance::getPropertyNames(
  JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getCanvasRenderingContext2DPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : getCanvasRenderingContext2DPrototypePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

} // namespace kraken::binding::jsc
