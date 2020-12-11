/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "bindings/jsc/DOM/elements/anchor_element.h"
#include "bindings/jsc/DOM/elements/animation_player_element.h"
#include "bindings/jsc/DOM/elements/audio_element.h"
#include "bindings/jsc/DOM/elements/canvas_element.h"
#include "bindings/jsc/DOM/elements/iframe_element.h"
#include "bindings/jsc/DOM/elements/image_element.h"
#include "bindings/jsc/DOM/elements/input_element.h"
#include "bindings/jsc/DOM/elements/object_element.h"
#include "bindings/jsc/DOM/elements/video_element.h"
#include "bridge_jsc.h"
#include "dart_methods.h"
#include "event_target.h"
#include "foundation/ui_command_queue.h"
#include "text_node.h"

namespace kraken::binding::jsc {
using namespace foundation;

void bindElement(std::unique_ptr<JSContext> &context) {
  auto element = JSElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Element", element->classObject);
}

std::vector<JSStringRef> &JSElementAttributes::getAttributePropertyNames() {
  static std::vector<JSStringRef> propertyMaps{JSStringCreateWithUTF8CString("length")};
  return propertyMaps;
}
const std::unordered_map<std::string, JSElementAttributes::AttributeProperty> &
JSElementAttributes::getAttributePropertyMap() {
  static std::unordered_map<std::string, AttributeProperty> propertyMap{{"length", AttributeProperty::kLength}};
  return propertyMap;
}

JSValueRef JSElementAttributes::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getAttributePropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case AttributeProperty::kLength:
      return JSValueMakeNumber(ctx, m_attributes.size());
    }
  } else if (hasAttribute(name)) {
    return JSValueMakeString(ctx, getAttribute(name));
  }
  return nullptr;
}
void JSElementAttributes::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {}
void JSElementAttributes::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getAttributePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : m_attributes) {
    JSPropertyNameAccumulatorAddName(accumulator, property.second);
  }
}
JSElementAttributes::~JSElementAttributes() {}

JSStringRef JSElementAttributes::getAttribute(std::string &name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    int64_t index = std::stoi(name);
    return v_attributes[index];
  }

  return m_attributes[name];
}

void JSElementAttributes::setAttribute(std::string &name, JSStringRef value) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    int64_t index = std::stoi(name);

    if (v_attributes[index] != nullptr) {
      JSStringRelease(v_attributes[index]);
    }

    v_attributes[index] = value;
  } else {
    v_attributes.emplace_back(value);
  }

  if (m_attributes.count(name) > 0) {
    JSStringRelease(m_attributes[name]);
  }

  m_attributes[name] = value;
}

bool JSElementAttributes::hasAttribute(std::string &name) {
  bool numberIndex = isNumberIndex(name);

  if (numberIndex) {
    size_t index = std::stoi(name);
    return v_attributes[index] != nullptr;
  }

  return m_attributes.count(name) > 0;
}

void JSElementAttributes::removeAttribute(std::string &name) {
  JSStringRef value = m_attributes[name];

  auto index = std::find(v_attributes.begin(), v_attributes.end(), value);
  v_attributes.erase(index);

  m_attributes.erase(name);
}

JSElement::JSElement(JSContext *context) : JSNode(context, "Element") {}

std::unordered_map<JSContext *, JSElement *> & JSElement::getInstanceMap() {
  static std::unordered_map<JSContext *, JSElement *> instanceMap;
  return instanceMap;
}

JSElement *JSElement::instance(JSContext *context) {
  auto instanceMap = getInstanceMap();
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSElement(context);
  }
  return instanceMap[context];
}

JSElement::~JSElement() {
  auto instanceMap = getInstanceMap();
  instanceMap.erase(context);
}

JSObjectRef JSElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                           const JSValueRef *arguments, JSValueRef *exception) {
  JSStringRef tagNameStrRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string tagName = JSStringToStdString(tagNameStrRef);
  auto instance = new ElementInstance(this, tagName.c_str(), true);
  return instance->object;
}

ElementInstance::ElementInstance(JSElement *element, const char *tagName, bool sendUICommand)
  : NodeInstance(element, NodeType::ELEMENT_NODE), nativeElement(new NativeElement(nativeNode)) {

  m_tagName.setString(JSStringCreateWithUTF8CString(tagName));

  if (sendUICommand) {
    std::string t = std::string(tagName);
    auto args = buildUICommandArgs(t);
    ::foundation::UICommandTaskMessageQueue::instance(element->context->getContextId())
      ->registerCommand(eventTargetId, UICommand::createElement, args, 1, nativeElement);
  }
}

ElementInstance::ElementInstance(JSElement *element, JSStringRef tagNameStringRef, double targetId)
  : NodeInstance(element, NodeType::ELEMENT_NODE, targetId), nativeElement(new NativeElement(nativeNode)) {
  m_tagName.setString(tagNameStringRef);

  NativeString tagName{};
  tagName.string = m_tagName.ptr();
  tagName.length = m_tagName.size();

  const int32_t argsLength = 1;
  auto **args = new NativeString *[argsLength];
  args[0] = tagName.clone();

  // No needs to send create element for BODY element.
  if (targetId == BODY_TARGET_ID) {
    assert_m(getDartMethod()->initBody != nullptr, "Failed to execute initBody(): dart method is nullptr.");
    getDartMethod()->initBody(element->contextId, nativeElement);
  } else {
    ::foundation::UICommandTaskMessageQueue::instance(element->context->getContextId())
      ->registerCommand(targetId, UICommand::createElement, args, argsLength, nativeElement);
  }
}

ElementInstance::~ElementInstance() {
  if (style != nullptr && context->isValid()) JSValueUnprotect(_hostClass->ctx, style->object);
  delete nativeElement;
}

JSValueRef JSElement::getBoundingClientRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                            size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto elementInstance = reinterpret_cast<ElementInstance *>(JSObjectGetPrivate(thisObject));
  getDartMethod()->flushUICommand();
  assert_m(elementInstance->nativeElement->getBoundingClientRect != nullptr,
           "Failed to execute getBoundingClientRect(): dart method is nullptr.");
  NativeBoundingClientRect *nativeBoundingClientRect =
    elementInstance->nativeElement->getBoundingClientRect(elementInstance->nativeElement);
  auto boundingClientRect = new BoundingClientRect(elementInstance->context, nativeBoundingClientRect);
  return boundingClientRect->jsObject;
}

const std::unordered_map<std::string, JSElement::ElementProperty> &JSElement::getElementPropertyMap() {
  static const std::unordered_map<std::string, ElementProperty> propertyHandler = {
    {"style", ElementProperty::kStyle},
    {"nodeName", ElementProperty::kNodeName},
    {"tagName", ElementProperty::kTagName},
    {"offsetLeft", ElementProperty::kOffsetLeft},
    {"offsetTop", ElementProperty::kOffsetTop},
    {"offsetWidth", ElementProperty::kOffsetWidth},
    {"offsetHeight", ElementProperty::kOffsetHeight},
    {"clientWidth", ElementProperty::kClientWidth},
    {"clientHeight", ElementProperty::kClientHeight},
    {"clientTop", ElementProperty::kClientTop},
    {"clientLeft", ElementProperty::kClientLeft},
    {"scrollTop", ElementProperty::kScrollTop},
    {"scrollLeft", ElementProperty::kScrollLeft},
    {"scrollHeight", ElementProperty::kScrollHeight},
    {"scrollWidth", ElementProperty::kScrollWidth},
    {"getBoundingClientRect", ElementProperty::kGetBoundingClientRect},
    {"click", ElementProperty::kClick},
    {"scroll", ElementProperty::kScroll},
    {"scrollBy", ElementProperty::kScrollBy},
    {"toBlob", ElementProperty::kToBlob},
    {"getAttribute", ElementProperty::kGetAttribute},
    {"setAttribute", ElementProperty::kSetAttribute},
    {"removeAttribute", ElementProperty::kRemoveAttribute},
    {"children", ElementProperty::kChildren},
    {"attributes", ElementProperty::kAttributes},
    {"scrollTo", ElementProperty::kScrollTo},
    {"hasAttribute", ElementProperty::kHasAttribute}};
  return propertyHandler;
}

JSValueRef ElementInstance::getStringValueProperty(std::string &name) {
  JSStringRef stringRef = JSStringCreateWithUTF8CString(name.c_str());
  NativeString* nativeString = stringRefToNativeString(stringRef);
  NativeString* returnedString = nativeElement->getStringValueProperty(nativeElement, nativeString);
  JSStringRef returnedStringRef = JSStringCreateWithCharacters(returnedString->string, returnedString->length);
  JSStringRelease(stringRef);
  return JSValueMakeString(_hostClass->ctx, returnedStringRef);
}

JSValueRef ElementInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSElement::getElementPropertyMap();

  if (propertyMap.count(name) == 0) {
    return JSNode::NodeInstance::getProperty(name, exception);
  }

  JSElement::ElementProperty property = propertyMap[name];

  switch (property) {
  case JSElement::ElementProperty::kStyle: {
    if (style == nullptr) {
      style = new CSSStyleDeclaration::StyleDeclarationInstance(CSSStyleDeclaration::instance(context), this);
      JSValueProtect(_hostClass->ctx, style->object);
    }

    return style->object;
  }
  case JSElement::ElementProperty::kNodeName:
  case JSElement::ElementProperty::kTagName: {
    return JSValueMakeString(_hostClass->ctx, JSStringCreateWithUTF8CString(tagName().c_str()));
  }
  case JSElement::ElementProperty::kOffsetLeft: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getOffsetLeft != nullptr, "Failed to execute getOffsetLeft(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetLeft(nativeElement));
  }
  case JSElement::ElementProperty::kOffsetTop: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getOffsetTop != nullptr, "Failed to execute getOffsetTop(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetTop(nativeElement));
  }
  case JSElement::ElementProperty::kOffsetWidth: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getOffsetWidth != nullptr, "Failed to execute getOffsetWidth(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetWidth(nativeElement));
  }
  case JSElement::ElementProperty::kOffsetHeight: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getOffsetHeight != nullptr, "Failed to execute getOffsetHeight(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getOffsetHeight(nativeElement));
  }
  case JSElement::ElementProperty::kClientWidth: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getClientWidth != nullptr, "Failed to execute getClientWidth(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientWidth(nativeElement));
  }
  case JSElement::ElementProperty::kClientHeight: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getClientHeight != nullptr, "Failed to execute getClientHeight(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientHeight(nativeElement));
  }
  case JSElement::ElementProperty::kClientTop: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getClientTop != nullptr, "Failed to execute getClientTop(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientTop(nativeElement));
  }
  case JSElement::ElementProperty::kClientLeft: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getClientLeft != nullptr, "Failed to execute getClientLeft(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getClientLeft(nativeElement));
  }
  case JSElement::ElementProperty::kScrollTop: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getScrollTop != nullptr, "Failed to execute getScrollTop(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollTop(nativeElement));
  }
  case JSElement::ElementProperty::kScrollLeft: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getScrollLeft != nullptr, "Failed to execute getScrollLeft(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollLeft(nativeElement));
  }
  case JSElement::ElementProperty::kScrollHeight: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getScrollHeight != nullptr, "Failed to execute getScrollHeight(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollHeight(nativeElement));
  }
  case JSElement::ElementProperty::kScrollWidth: {
    getDartMethod()->flushUICommand();
    assert_m(nativeElement->getScrollWidth != nullptr, "Failed to execute getScrollWidth(): dart method is nullptr.");
    return JSValueMakeNumber(_hostClass->ctx, nativeElement->getScrollWidth(nativeElement));
  }
  case JSElement::ElementProperty::kGetBoundingClientRect: {
    return prototype<JSElement>()->m_getBoundingClientRect.function();
  }
  case JSElement::ElementProperty::kClick: {
    return prototype<JSElement>()->m_click.function();
  }
  case JSElement::ElementProperty::kScrollTo:
  case JSElement::ElementProperty::kScroll: {
    return prototype<JSElement>()->m_scroll.function();
  }
  case JSElement::ElementProperty::kScrollBy: {
    return prototype<JSElement>()->m_scrollBy.function();
  }
  case JSElement::ElementProperty::kToBlob: {
    return prototype<JSElement>()->m_toBlob.function();
  }
  case JSElement::ElementProperty::kGetAttribute: {
    return prototype<JSElement>()->m_getAttribute.function();
  }
  case JSElement::ElementProperty::kSetAttribute: {
    return prototype<JSElement>()->m_setAttribute.function();
  }
  case JSElement::ElementProperty::kRemoveAttribute: {
    return prototype<JSElement>()->m_removeAttribute.function();
  }
  case JSElement::ElementProperty::kHasAttribute:
    return prototype<JSElement>()->m_hasAttribute.function();
  case JSElement::ElementProperty::kChildren: {
    JSValueRef arguments[childNodes.size()];

    size_t elementCount = 0;
    for (int i = 0; i < childNodes.size(); i++) {
      if (childNodes[i]->nodeType == NodeType::ELEMENT_NODE) {
        arguments[i] = childNodes[i]->object;
        elementCount++;
      }
    }

    return JSObjectMakeArray(_hostClass->ctx, elementCount, arguments, nullptr);
  }
  case JSElement::ElementProperty::kAttributes: {
    return (*m_attributes)->jsObject;
  }
  }

  return nullptr;
}

void ElementInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto propertyMap = JSElement::getElementPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case JSElement::ElementProperty::kScrollTop: {
      getDartMethod()->flushUICommand();
      assert_m(nativeElement->setScrollTop != nullptr, "Failed to execute setScrollTop(): dart method is nullptr.");
      nativeElement->setScrollTop(nativeElement, JSValueToNumber(_hostClass->ctx, value, exception));
      break;
    }
    case JSElement::ElementProperty::kScrollLeft: {
      getDartMethod()->flushUICommand();
      assert_m(nativeElement->setScrollLeft != nullptr, "Failed to execute setScrollLeft(): dart method is nullptr.");
      nativeElement->setScrollLeft(nativeElement, JSValueToNumber(_hostClass->ctx, value, exception));
      break;
    }
    default:
      break;
    }
  } else {
    NodeInstance::setProperty(name, value, exception);
  }
}

void ElementInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  NodeInstance::getPropertyNames(accumulator);

  for (auto &property : JSElement::getElementPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::string ElementInstance::internalGetTextContent() {
  std::string buffer;

  for (auto &node : childNodes) {
    std::string nodeText = node->internalGetTextContent();
    buffer += nodeText;
  }

  return buffer;
}

std::vector<JSStringRef> &JSElement::getElementPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("style"),        JSStringCreateWithUTF8CString("getAttribute"),
    JSStringCreateWithUTF8CString("setAttribute"), JSStringCreateWithUTF8CString("removeAttribute"),
    JSStringCreateWithUTF8CString("nodeName"),     JSStringCreateWithUTF8CString("offsetLeft"),
    JSStringCreateWithUTF8CString("offsetTop"),    JSStringCreateWithUTF8CString("offsetWidth"),
    JSStringCreateWithUTF8CString("offsetHeight"), JSStringCreateWithUTF8CString("clientWidth"),
    JSStringCreateWithUTF8CString("clientHeight"), JSStringCreateWithUTF8CString("clientTop"),
    JSStringCreateWithUTF8CString("clientLeft"),   JSStringCreateWithUTF8CString("scrollTop"),
    JSStringCreateWithUTF8CString("scrollLeft"),   JSStringCreateWithUTF8CString("scrollWidth"),
    JSStringCreateWithUTF8CString("scrollHeight"), JSStringCreateWithUTF8CString("getBoundingClientRect"),
    JSStringCreateWithUTF8CString("click"),        JSStringCreateWithUTF8CString("scroll"),
    JSStringCreateWithUTF8CString("scrollBy"),     JSStringCreateWithUTF8CString("toBlob"),
    JSStringCreateWithUTF8CString("children"),     JSStringCreateWithUTF8CString("tagName"),
    JSStringCreateWithUTF8CString("attributes"),   JSStringCreateWithUTF8CString("scrollTo"),
    JSStringCreateWithUTF8CString("hasAttribute")};
  return propertyNames;
}

JSValueRef JSElement::setAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount != 2) {
    JSC_THROW_ERROR(ctx,
                    ("Failed to execute 'setAttribute' on 'Element': 2 arguments required, but only " +
                     std::to_string(argumentCount) + " present")
                      .c_str(),
                    exception);
    return nullptr;
  }

  const JSValueRef nameValueRef = arguments[0];
  const JSValueRef attributeValueRef = arguments[1];

  if (!JSValueIsString(ctx, nameValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.", exception);
    return nullptr;
  }

  JSStringRef nameStringRef = JSValueToStringCopy(ctx, nameValueRef, exception);
  JSStringRef valueStringRef = JSValueToStringCopy(ctx, attributeValueRef, exception);
  std::string &&name = JSStringToStdString(nameStringRef);
  std::transform(name.begin(), name.end(), name.begin(), ::tolower);

  getDartMethod()->flushUICommand();

  auto elementInstance = reinterpret_cast<ElementInstance *>(JSObjectGetPrivate(thisObject));

  JSStringRetain(valueStringRef);

  std::string valueString = JSStringToStdString(valueStringRef);

  auto attributes = *elementInstance->m_attributes;

  if (attributes->hasAttribute(name)) {
    JSStringRef oldValueRef = attributes->getAttribute(name);
    std::string oldValue = JSStringToStdString(oldValueRef);
    JSStringRelease(oldValueRef);
    attributes->setAttribute(name, valueStringRef);
    elementInstance->_didModifyAttribute(name, oldValue, valueString);
  } else {
    attributes->setAttribute(name, valueStringRef);
    std::string empty;
    elementInstance->_didModifyAttribute(name, empty, valueString);
  }

  auto args = buildUICommandArgs(name, valueString);

  ::foundation::UICommandTaskMessageQueue::instance(elementInstance->_hostClass->contextId)
    ->registerCommand(elementInstance->eventTargetId, UICommand::setProperty, args, 2, nullptr);

  return nullptr;
}

JSValueRef JSElement::getAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'getAttribute' on 'Element': 1 argument required, but only 0 present",
                    exception);
    return nullptr;
  }

  const JSValueRef nameValueRef = arguments[0];

  if (!JSValueIsString(ctx, nameValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.", exception);
    return nullptr;
  }

  JSStringRef nameStringRef = JSValueToStringCopy(ctx, nameValueRef, exception);
  std::string &&name = JSStringToStdString(nameStringRef);
  auto elementInstance = reinterpret_cast<ElementInstance *>(JSObjectGetPrivate(thisObject));
  auto attributes = *elementInstance->m_attributes;

  if (attributes->hasAttribute(name)) {
    return JSValueMakeString(ctx, attributes->getAttribute(name));
  }

  return nullptr;
}

JSValueRef JSElement::hasAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'hasAttribute' on 'Element': 1 argument required, but only 0 present",
                    exception);
    return nullptr;
  }

  const JSValueRef nameValueRef = arguments[0];

  if (!JSValueIsString(ctx, nameValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'setAttribute' on 'Element': name attribute is not valid.", exception);
    return nullptr;
  }

  JSStringRef nameStringRef = JSValueToStringCopy(ctx, nameValueRef, exception);
  std::string &&name = JSStringToStdString(nameStringRef);
  auto elementInstance = reinterpret_cast<ElementInstance *>(JSObjectGetPrivate(thisObject));
  auto attributes = *elementInstance->m_attributes;

  return JSValueMakeBoolean(ctx, attributes->hasAttribute(name));
}

JSValueRef JSElement::removeAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                      size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'removeAttribute' on 'Element': 1 argument required, but only 0 present",
                    exception);
    return nullptr;
  }

  const JSValueRef nameValueRef = arguments[0];

  if (!JSValueIsString(ctx, nameValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'removeAttribute' on 'Element': name attribute is not valid.", exception);
    return nullptr;
  }

  JSStringRef nameStringRef = JSValueToStringCopy(ctx, nameValueRef, exception);
  std::string &&name = JSStringToStdString(nameStringRef);
  auto element = reinterpret_cast<ElementInstance *>(JSObjectGetPrivate(thisObject));
  auto attributes = *element->m_attributes;

  if (attributes->hasAttribute(name)) {
    JSStringRef idRef = attributes->getAttribute(name);
    std::string id = JSStringToStdString(idRef);
    std::string empty;

    (*element->m_attributes)->removeAttribute(name);
    element->_didModifyAttribute(name, id, empty);

    auto args = buildUICommandArgs(name);
    ::foundation::UICommandTaskMessageQueue::instance(element->_hostClass->contextId)
      ->registerCommand(element->eventTargetId, UICommand::removeProperty, args, 1, nullptr);
  }

  return nullptr;
}

struct ToBlobPromiseContext {
  ToBlobPromiseContext() = delete;
  ToBlobPromiseContext(JSBridge *bridge, JSContext *context, double id, double devicePixelRatio)
    : id(id), devicePixelRatio(devicePixelRatio), bridge(bridge), context(context){};
  double id;
  double devicePixelRatio;
  JSBridge *bridge;
  JSContext *context;
};

JSValueRef JSElement::toBlob(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef &devicePixelRatioValueRef = arguments[0];

  if (!JSValueIsNumber(ctx, devicePixelRatioValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: parameter 2 (devicePixelRatio) is not an number.", exception);
    return nullptr;
  }

  if (getDartMethod()->toBlob == nullptr) {
    JSC_THROW_ERROR(ctx, "Failed to export blob: dart method (toBlob) is not registered.", exception);
    return nullptr;
  }

  auto elementInstance = reinterpret_cast<ElementInstance *>(JSObjectGetPrivate(thisObject));
  auto context = elementInstance->context;
  getDartMethod()->flushUICommand();

  double devicePixelRatio = JSValueToNumber(ctx, devicePixelRatioValueRef, exception);
  auto bridge = static_cast<JSBridge *>(context->getOwner());

  auto toBlobPromiseContext =
    new ToBlobPromiseContext(bridge, context, elementInstance->eventTargetId, devicePixelRatio);

  auto promiseCallback = [](JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception) -> JSValueRef {
    const JSValueRef resolveValueRef = arguments[0];
    const JSValueRef rejectValueRef = arguments[1];

    auto toBlobPromiseContext = reinterpret_cast<ToBlobPromiseContext *>(JSObjectGetPrivate(function));
    auto callbackContext = std::make_unique<foundation::BridgeCallback::Context>(
      *toBlobPromiseContext->context, resolveValueRef, rejectValueRef, exception);

    auto handleTransientToBlobCallback = [](void *ptr, int32_t contextId, const char *error, uint8_t *bytes,
                                            int32_t length) {
      auto callbackContext = static_cast<BridgeCallback::Context *>(ptr);
      JSContext &_context = callbackContext->_context;
      JSContextRef ctx = callbackContext->_context.context();

      JSValueRef resolveValueRef = callbackContext->_callback;
      JSValueRef rejectValueRef = callbackContext->_secondaryCallback;

      if (!checkContext(contextId, &_context)) return;
      if (error != nullptr) {
        JSStringRef errorStringRef = JSStringCreateWithUTF8CString(error);
        const JSValueRef arguments[] = {JSValueMakeString(ctx, errorStringRef)};
        JSObjectRef rejectObjectRef = JSValueToObject(ctx, rejectValueRef, nullptr);
        JSObjectCallAsFunction(ctx, rejectObjectRef, callbackContext->_context.global(), 1, arguments, nullptr);
      } else {
        std::vector<uint8_t> vec(bytes, bytes + length);
        JSObjectRef resolveObjectRef = JSValueToObject(ctx, resolveValueRef, nullptr);
        JSBlob *Blob = JSBlob::instance(&callbackContext->_context);
        auto blob = new JSBlob::BlobInstance(Blob, std::move(vec));
        const JSValueRef arguments[] = {blob->object};

        JSObjectCallAsFunction(ctx, resolveObjectRef, callbackContext->_context.global(), 1, arguments, nullptr);
      }
    };

    toBlobPromiseContext->bridge->bridgeCallback->registerCallback<void>(
      std::move(callbackContext), [toBlobPromiseContext, handleTransientToBlobCallback](
                                    BridgeCallback::Context *callbackContext, int32_t contextId) {
        getDartMethod()->toBlob(callbackContext, contextId, handleTransientToBlobCallback, toBlobPromiseContext->id,
                                toBlobPromiseContext->devicePixelRatio);
      });

    delete toBlobPromiseContext;

    return nullptr;
  };

  return JSObjectMakePromise(context, toBlobPromiseContext, promiseCallback, exception);
}

JSValueRef JSElement::click(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef *arguments, JSValueRef *exception) {
  auto elementInstance = reinterpret_cast<ElementInstance *>(JSObjectGetPrivate(thisObject));
  getDartMethod()->flushUICommand();
  assert_m(elementInstance->nativeElement->click != nullptr, "Failed to execute click(): dart method is nullptr.");
  elementInstance->nativeElement->click(elementInstance->nativeElement);

  return nullptr;
}

JSValueRef JSElement::scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef xValueRef = arguments[0];
  const JSValueRef yValueRef = arguments[1];

  double x = 0.0;
  double y = 0.0;

  if (argumentCount > 0 && JSValueIsNumber(ctx, xValueRef)) {
    x = JSValueToNumber(ctx, xValueRef, exception);
  }

  if (argumentCount > 1 && JSValueIsNumber(ctx, yValueRef)) {
    y = JSValueToNumber(ctx, yValueRef, exception);
  }

  auto elementInstance = reinterpret_cast<ElementInstance *>(JSObjectGetPrivate(thisObject));
  getDartMethod()->flushUICommand();
  assert_m(elementInstance->nativeElement->scroll != nullptr, "Failed to execute scroll(): dart method is nullptr.");
  elementInstance->nativeElement->scroll(elementInstance->nativeElement, x, y);

  return nullptr;
}

JSValueRef JSElement::scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  const JSValueRef xValueRef = arguments[0];
  const JSValueRef yValueRef = arguments[1];

  double x = 0.0;
  double y = 0.0;

  if (argumentCount > 0 && JSValueIsNumber(ctx, xValueRef)) {
    x = JSValueToNumber(ctx, xValueRef, exception);
  }

  if (argumentCount > 1 && JSValueIsNumber(ctx, yValueRef)) {
    y = JSValueToNumber(ctx, yValueRef, exception);
  }

  auto elementInstance = reinterpret_cast<ElementInstance *>(JSObjectGetPrivate(thisObject));
  getDartMethod()->flushUICommand();
  assert_m(elementInstance->nativeElement->scrollBy != nullptr,
           "Failed to execute scrollBy(): dart method is nullptr.");
  elementInstance->nativeElement->scrollBy(elementInstance->nativeElement, x, y);

  return nullptr;
}

ElementInstance *JSElement::buildElementInstance(JSContext *context, std::string &name) {
  static std::unordered_map<std::string, ElementTagName> m_elementMaps{
    {"a", ElementTagName::kAnchor},      {"animation-player", ElementTagName::kAnimationPlayer},
    {"audio", ElementTagName::kAudio},   {"video", ElementTagName::kVideo},
    {"canvas", ElementTagName::kCanvas}, {"div", ElementTagName::kDiv},
    {"span", ElementTagName::kSpan},     {"strong", ElementTagName::kStrong},
    {"pre", ElementTagName::kPre},       {"p", ElementTagName::kParagraph},
    {"iframe", ElementTagName::kIframe}, {"object", ElementTagName::kObject},
    {"img", ElementTagName::kImage},     {"input", ElementTagName::kInput}};

  ElementTagName tagName;
  if (m_elementMaps.count(name) > 0) {
    tagName = m_elementMaps[name];
  } else {
    tagName = ElementTagName::kDiv;
  }

  switch (tagName) {
  case ElementTagName::kImage:
    return new JSImageElement::ImageElementInstance(JSImageElement::instance(context));
  case ElementTagName::kAnchor:
    return new JSAnchorElement::AnchorElementInstance(JSAnchorElement::instance(context));
  case ElementTagName::kCanvas:
    return new JSCanvasElement::CanvasElementInstance(JSCanvasElement::instance(context));
  case ElementTagName::kInput:
    return new JSInputElement::InputElementInstance(JSInputElement::instance(context));
  case ElementTagName::kAudio:
    return new JSAudioElement::AudioElementInstance(JSAudioElement::instance(context));
  case ElementTagName::kVideo:
    return new JSVideoElement::VideoElementInstance(JSVideoElement::instance(context));
  case ElementTagName::kIframe:
    return new JSIframeElement::IframeElementInstance(JSIframeElement::instance(context));
  case ElementTagName::kObject:
    return new JSObjectElement::ObjectElementInstance(JSObjectElement::instance(context));
  case ElementTagName::kAnimationPlayer:
    return new JSAnimationPlayerElement::AnimationPlayerElementInstance(JSAnimationPlayerElement::instance(context));
  case ElementTagName::kSpan:
  case ElementTagName::kDiv:
  case ElementTagName::kStrong:
  case ElementTagName::kPre:
  case ElementTagName::kParagraph:
  default:
    return new ElementInstance(JSElement::instance(context), name.c_str(), true);
  }
  return nullptr;
}

JSValueRef JSElement::prototypeGetProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getElementPropertyMap();
  if (propertyMap.count(name) == 0) return JSNode::prototypeGetProperty(name, exception);
  auto property = propertyMap[name];

  switch (property) {
  case ElementProperty::kGetBoundingClientRect:
    return m_getBoundingClientRect.function();
  case ElementProperty::kClick:
    return m_click.function();
  case ElementProperty::kScrollTo:
  case ElementProperty::kScroll:
    return m_scroll.function();
  case ElementProperty::kScrollBy:
    return m_scrollBy.function();
  case ElementProperty::kToBlob:
    return m_toBlob.function();
  case ElementProperty::kGetAttribute:
    return m_getAttribute.function();
  case ElementProperty::kSetAttribute:
    return m_setAttribute.function();
  case ElementProperty::kHasAttribute:
    return m_hasAttribute.function();
  case ElementProperty::kRemoveAttribute:
    return m_removeAttribute.function();
  default:
    break;
  }
  return nullptr;
}

void ElementInstance::_notifyNodeRemoved(JSNode::NodeInstance *insertionNode) {
  if (insertionNode->isConnected()) {
    traverseNode(this, [](JSNode::NodeInstance *node) {
      auto Element = JSElement::instance(node->context);
      if (node->_hostClass == Element) {
        auto element = reinterpret_cast<ElementInstance *>(node);
        element->_notifyChildRemoved();
      }

      return false;
    });
  }
}
void ElementInstance::_notifyChildRemoved() {
  auto attributes = *m_attributes;
  std::string idString = "id";
  if (attributes->hasAttribute(idString)) {
    JSStringRef idRef = attributes->getAttribute(idString);
    std::string id = JSStringToStdString(idRef);
    document->removeElementById(id, this);
  }
}
void ElementInstance::_notifyNodeInsert(JSNode::NodeInstance *insertNode) {
  if (insertNode->isConnected()) {
    traverseNode(this, [](JSNode::NodeInstance *node) {
      auto Element = JSElement::instance(node->context);
      if (node->_hostClass == Element) {
        auto element = reinterpret_cast<ElementInstance *>(node);
        element->_notifyChildInsert();
      }

      return false;
    });
  }
}
void ElementInstance::_notifyChildInsert() {
  std::string idKey = "id";
  auto attributes = *m_attributes;
  if (attributes->hasAttribute(idKey)) {
    JSStringRef idRef = attributes->getAttribute(idKey);
    std::string id = JSStringToStdString(idRef);
    document->addElementById(id, this);
  }
}
void ElementInstance::_didModifyAttribute(std::string &name, std::string &oldId, std::string &newId) {
  if (name == "id") {
    _beforeUpdateId(oldId, newId);
  }
}
void ElementInstance::_beforeUpdateId(std::string &oldId, std::string &newId) {
  if (oldId == newId) return;

  if (!oldId.empty()) {
    document->removeElementById(oldId, this);
  }

  if (!newId.empty()) {
    document->addElementById(newId, this);
  }
}

std::string ElementInstance::tagName() {
  std::string tagName = m_tagName.string();
  std::transform(tagName.begin(), tagName.end(), tagName.begin(), ::toupper);
  return tagName;
}

void ElementInstance::internalSetTextContent(JSStringRef content, JSValueRef *exception) {
  auto node = firstChild();
  while (node != nullptr) {
    internalRemoveChild(node, exception);
    node = firstChild();
  }

  auto TextNode = JSTextNode::instance(_hostClass->context);
  auto textNode = new JSTextNode::TextNodeInstance(TextNode, content);
  internalAppendChild(textNode);
}

BoundingClientRect::BoundingClientRect(JSContext *context, NativeBoundingClientRect *boundingClientRect)
  : HostObject(context, "BoundingClientRect"), nativeBoundingClientRect(boundingClientRect) {}

JSValueRef BoundingClientRect::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPropertyMap();

  if (propertyMap.count(name) == 0) return nullptr;
  auto property = propertyMap[name];

  switch (property) {
  case kX:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->x);
  case kY:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->y);
  case kWidth:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->width);
  case kHeight:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->height);
  case kLeft:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->left);
  case kTop:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->top);
  case kRight:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->right);
  case kBottom:
    return JSValueMakeNumber(ctx, nativeBoundingClientRect->bottom);
  }

  return nullptr;
}

std::array<JSStringRef, 8> &BoundingClientRect::getBoundingClientRectPropertyNames() {
  static std::array<JSStringRef, 8> propertyNames{
    JSStringCreateWithUTF8CString("x"),      JSStringCreateWithUTF8CString("y"),
    JSStringCreateWithUTF8CString("width"),  JSStringCreateWithUTF8CString("height"),
    JSStringCreateWithUTF8CString("top"),    JSStringCreateWithUTF8CString("right"),
    JSStringCreateWithUTF8CString("bottom"), JSStringCreateWithUTF8CString("left"),
  };
  return propertyNames;
}

const std::unordered_map<std::string, BoundingClientRect::BoundingClientRectProperty> &
BoundingClientRect::getPropertyMap() {
  static const std::unordered_map<std::string, BoundingClientRectProperty> propertyMap{
    {"x", BoundingClientRectProperty::kX},         {"y", BoundingClientRectProperty::kY},
    {"width", BoundingClientRectProperty::kWidth}, {"height", BoundingClientRectProperty::kHeight},
    {"top", BoundingClientRectProperty::kTop},     {"left", BoundingClientRectProperty::kLeft},
    {"right", BoundingClientRectProperty::kRight}, {"bottom", BoundingClientRectProperty::kBottom}};
  return propertyMap;
}

void BoundingClientRect::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getBoundingClientRectPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

BoundingClientRect::~BoundingClientRect() {
  delete nativeBoundingClientRect;
}

void traverseNode(JSNode::NodeInstance *node, TraverseHandler handler) {
  bool shouldExit = handler(node);
  if (shouldExit) return;

  if (!node->childNodes.empty()) {
    for (auto &n : node->childNodes) {
      traverseNode(n, handler);
    }
  }
}

} // namespace kraken::binding::jsc
