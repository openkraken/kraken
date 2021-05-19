/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "svg_element.h"

namespace kraken::binding::jsc {


void bindSVGElement(std::unique_ptr<JSContext> &context) {
  auto SVGElement = JSSVGElement::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "SVGElement", SVGElement->classObject);
}


std::unordered_map<JSContext *, JSSVGElement *> JSSVGElement::instanceMap{};

JSSVGElement::~JSSVGElement() {
  instanceMap.erase(context);
}

JSSVGElement::JSSVGElement(JSContext *context) : JSElement(context) {}
JSObjectRef JSSVGElement::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                 const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = new SVGElementInstance(this);
  return instance->object;
}

JSSVGElement::SVGElementInstance::SVGElementInstance(JSSVGElement *jsAnchorElement)
  : ElementInstance(jsAnchorElement, "svg", false), nativeSVGElement(new NativeSVGElement(nativeElement)) {
  std::string tagName = "svg";
  NativeString args_01{};
  buildUICommandArgs(tagName, args_01);

  foundation::UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(eventTargetId, UICommand::createElement, args_01, nativeSVGElement);
}

JSSVGElement::SVGElementInstance::~SVGElementInstance() {
  ::foundation::UICommandCallbackQueue::instance()->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeSVGElement *>(ptr);
  }, nativeSVGElement);
}

} // namespace kraken::binding::jsc
