/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
// Generated from template:
//   code_generator/src/json/templates/element_factory.cc.tmp
// and input files:
//   /Users/andycall/work/kraken_main/bridge/core/html/html_tags.json
#include "html_element_factory.h"
#include <unordered_map>
#include "bindings/qjs/garbage_collected.h"
#include "core/html/canvas/html_canvas_element.h"
#include "core/html/forms/html_button_element.h"
#include "core/html/forms/html_form_element.h"
#include "core/html/forms/html_input_element.h"
#include "core/html/forms/html_select_element.h"
#include "core/html/forms/html_textarea_element.h"
#include "core/html/html_a_element.h"
#include "core/html/html_area_element.h"
#include "core/html/html_b_element.h"
#include "core/html/html_base_element.h"
#include "core/html/html_body_element.h"
#include "core/html/html_br_element.h"
#include "core/html/html_code_element.h"
#include "core/html/html_dd_element.h"
#include "core/html/html_details_element.h"
#include "core/html/html_dialog_element.h"
#include "core/html/html_div_element.h"
#include "core/html/html_em_element.h"
#include "core/html/html_font_element.h"
#include "core/html/html_frame_element.h"
#include "core/html/html_h1_element.h"
#include "core/html/html_h2_element.h"
#include "core/html/html_h3_element.h"
#include "core/html/html_h4_element.h"
#include "core/html/html_h5_element.h"
#include "core/html/html_h6_element.h"
#include "core/html/html_head_element.h"
#include "core/html/html_header_element.h"
#include "core/html/html_hgroup_element.h"
#include "core/html/html_hr_element.h"
#include "core/html/html_html_element.h"
#include "core/html/html_i_element.h"
#include "core/html/html_iframe_element.h"
#include "core/html/html_image_element.h"
#include "core/html/html_img_element.h"
#include "core/html/html_li_element.h"
#include "core/html/html_link_element.h"
#include "core/html/html_map_element.h"
#include "core/html/html_menu_element.h"
#include "core/html/html_p_element.h"
#include "core/html/html_param_element.h"
#include "core/html/html_popup_element.h"
#include "core/html/html_pre_element.h"
#include "core/html/html_script_element.h"
#include "core/html/html_section_element.h"
#include "core/html/html_span_element.h"
#include "core/html/html_strong_element.h"
#include "core/html/html_style_element.h"
#include "core/html/html_template_element.h"
#include "core/html/html_title_element.h"
#include "core/html/media/html_audio_element.h"
#include "core/html/media/html_video_element.h"
#include "html_names.h"
namespace kraken {
using HTMLConstructorFunction = HTMLElement* (*)(Document&);
using HTMLFunctionMap = std::unordered_map<AtomicString, HTMLConstructorFunction, AtomicString::KeyHasher>;
static HTMLFunctionMap* g_html_constructors = nullptr;
struct CreateHTMLFunctionMapData {
  const AtomicString& tag;
  HTMLConstructorFunction func;
};

static void CreateHTMLFunctionMap() {
  assert(!g_html_constructors);
  g_html_constructors = new HTMLFunctionMap();
  // Empty array initializer lists are illegal [dcl.init.aggr] and will not
  // compile in MSVC. If tags list is empty, add check to skip this.
  static const CreateHTMLFunctionMapData data[] = {
      {html_names::a, HTMLAnchorElementConstructor},
      {html_names::karea, HTMLAreaConstructor} {html_names::b, HTMLElementConstructor} {
          html_names::kbase, HTMLBaseConstructor} {html_names::audio, HTMLAudioConstructor} {
          html_names::kbody, HTMLBodyConstructor} {html_names::br, HTMLBRElementConstructor} {
          html_names::button, HTMLButtonConstructor} {html_names::canvas, HTMLCanvasConstructor} {
          html_names::code, HTMLElementConstructor} {html_names::dd, HTMLElementConstructor} {
          html_names::kdetails, HTMLDetailsConstructor} {html_names::kdialog, HTMLDialogConstructor} {
          html_names::kdiv, HTMLDivConstructor} {html_names::em, HTMLElementConstructor} {
          html_names::kfont, HTMLFontConstructor} {html_names::form, HTMLFormConstructor} {
          html_names::kframe, HTMLFrameConstructor} {html_names::h1, HTMLHeadingElementConstructor} {
          html_names::h2, HTMLHeadingElementConstructor} {html_names::h3, HTMLHeadingElementConstructor} {
          html_names::h4, HTMLHeadingElementConstructor} {html_names::h5, HTMLHeadingElementConstructor} {
          html_names::h6, HTMLHeadingElementConstructor} {html_names::khead, HTMLHeadConstructor} {
          html_names::header, HTMLElementConstructor} {html_names::hgroup, HTMLElementConstructor} {
          html_names::hr, HTMLHRElementConstructor} {html_names::khtml, HTMLHtmlConstructor} {
          html_names::i, HTMLElementConstructor} {html_names::iframe, HTMLIFrameElementConstructor} {
          html_names::image, HTMLUnknownElementConstructor} {html_names::img, HTMLImageElementConstructor} {
          html_names::input, HTMLInputConstructor} {html_names::li, HTMLLIElementConstructor} {
          html_names::klink, HTMLLinkConstructor} {html_names::kmap, HTMLMapConstructor} {
          html_names::kmenu, HTMLMenuConstructor} {html_names::p, HTMLParagraphElementConstructor} {
          html_names::kparam, HTMLParamConstructor} {html_names::popup, HTMLPopupElementConstructor} {
          html_names::kpre, HTMLPreConstructor} {html_names::kscript, HTMLScriptConstructor} {
          html_names::section, HTMLElementConstructor} {html_names::select, HTMLSelectConstructor} {
          html_names::kspan, HTMLSpanConstructor} {html_names::strong, HTMLElementConstructor} {
          html_names::style, HTMLStyleConstructor} {html_names::ktemplate, HTMLTemplateConstructor} {
          html_names::textarea, HTMLTextAreaElementConstructor} {html_names::ktitle, HTMLTitleConstructor} {
          html_names::video, HTMLVideoConstructor}};
  for (size_t i = 0; i < std::size(data); i++)
    g_html_constructors->insert(std::make_pair(data[i].tag, data[i].func));
}
HTMLElement* HTMLElementFactory::Create(const AtomicString& name, Document& document) {
  if (!g_html_constructors)
    CreateHTMLFunctionMap();
  auto it = g_html_constructors->find(name);
  if (it == g_html_constructors->end())
    return nullptr;
  HTMLConstructorFunction function = it->second;
  return function(document);
}
}  // namespace kraken
