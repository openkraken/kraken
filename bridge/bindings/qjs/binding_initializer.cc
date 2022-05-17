/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "binding_initializer.h"
#include "core/executing_context.h"

#include "qjs_bounding_client_rect.h"
#include "qjs_character_data.h"
#include "qjs_comment.h"
#include "qjs_console.h"
#include "qjs_css_style_declaration.h"
#include "qjs_document.h"
#include "qjs_element.h"
#include "qjs_element_attributes.h"
#include "qjs_error_event.h"
#include "qjs_event.h"
#include "qjs_event_target.h"
#include "qjs_html_body_element.h"
#include "qjs_html_div_element.h"
#include "qjs_html_element.h"
#include "qjs_html_head_element.h"
#include "qjs_html_html_element.h"
#include "qjs_html_template_element.h"
#include "qjs_html_unknown_element.h"
#include "qjs_message_event.h"
#include "qjs_module_manager.h"
#include "qjs_node.h"
#include "qjs_node_list.h"
#include "qjs_text.h"
#include "qjs_window.h"
#include "qjs_window_or_worker_global_scope.h"
#include "qjs_location.h"

namespace kraken {

void InstallBindings(ExecutingContext* context) {
  // Must follow the inheritance order when install.
  // Exp: Node extends EventTarget, EventTarget must be install first.
  QJSWindowOrWorkerGlobalScope::Install(context);
  QJSLocation::Install(context);
  QJSModuleManager::Install(context);
  QJSConsole::Install(context);
  QJSEventTarget::Install(context);
  QJSWindow::Install(context);
  context->InstallGlobal();
  QJSEvent::Install(context);
  QJSErrorEvent::Install(context);
  QJSMessageEvent::Install(context);
  QJSNode::Install(context);
  QJSNodeList::Install(context);
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
  QJSHTMLUnknownElement::Install(context);
  QJSHTMLTemplateElement::Install(context);
  QJSCSSStyleDeclaration::Install(context);
  QJSBoundingClientRect::Install(context);

  // Legacy bindings, not standard.
  QJSElementAttributes::Install(context);
}

}  // namespace kraken
