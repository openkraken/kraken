/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "binding_initializer.h"
#include "core/executing_context.h"

#include "qjs_character_data.h"
#include "qjs_comment.h"
#include "qjs_console.h"
#include "qjs_document.h"
#include "qjs_element.h"
#include "qjs_element_attributes.h"
#include "qjs_event.h"
#include "qjs_event_target.h"
#include "qjs_html_body_element.h"
#include "qjs_html_div_element.h"
#include "qjs_html_element.h"
#include "qjs_html_head_element.h"
#include "qjs_html_html_element.h"
#include "qjs_module_manager.h"
#include "qjs_node.h"
#include "qjs_text.h"
#include "qjs_window.h"

namespace kraken {

void InstallBindings(ExecutingContext* context) {
  // Must follow the inheritance order when install.
  // Exp: Node extends EventTarget, EventTarget must be install first.
  QJSWindow::installGlobalFunctions(context);
  QJSModuleManager::Install(context);
  QJSConsole::Install(context);
  QJSEventTarget::Install(context);
  QJSEvent::Install(context);
  QJSNode::Install(context);
  QJSDocument::Install(context);
  QJSCharacterData::Install(context);
  QJSText::Install(context);
  QJSComment::Install(context);
  QJSElement::Install(context);
  QJSHTMLElement::Install(context);
  QJSHTMLDivElement::Install(context);
  QJSHTMLHeadElement::Install(context);
  QJSHTMLBodyElement::Install(context);
  QJSHTMLHtmlElement::Install(context);

  // Legacy bindings, not standard.
  QJSElementAttributes::Install(context);
}

}  // namespace kraken
