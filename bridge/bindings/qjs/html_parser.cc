/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_parser.h"
#include "dom/document.h"
#include "dom/text_node.h"
#include "js_context.h"

#include <utility>

namespace kraken::binding::qjs {

inline std::string trim(std::string &str) {
  str.erase(0, str.find_first_not_of(' ')); // prefixing spaces
  str.erase(str.find_last_not_of(' ') + 1); // surfixing spaces
  return str;
}

void HTMLParser::traverseHTML(NodeInstance *root, GumboNode *node) {
  JSContext *context = root->context();
  QjsContext *ctx = context->ctx();

  const GumboVector* children = &node->v.element.children;
  for (int i = 0; i < children->length; ++i) {
    auto* child = (GumboNode*) children->data[i];

    if (child->type == GUMBO_NODE_ELEMENT) {
      std::string tagName = gumbo_normalized_tagname(child->v.element.tag);
      JSValue constructor = Element::getConstructor(context, tagName);

      JSValue tagNameValue = JS_NewString(ctx, tagName.c_str());
      JSValue argv[] = {
        tagNameValue
      };
      JSValue newElementValue = JS_CallConstructor(ctx, constructor, 1, argv);
      JS_FreeValue(ctx, tagNameValue);
      auto *newElementInstance = static_cast<ElementInstance *>(JS_GetOpaque(newElementValue, Element::classId()));
      root->internalAppendChild(newElementInstance);
      parseProperty(newElementInstance, &child->v.element);

      // eval javascript when <script>//code...</script>.
      if (child->v.element.children.length > 0) {
        if (child->v.element.tag == GUMBO_TAG_SCRIPT) {
          const char* code = ((GumboNode*) child->v.element.children.data[0])->v.text.text;
          context->evaluateJavaScript(code, strlen(code), "vm://", 0);
        } else {
          traverseHTML(newElementInstance, child);
        }
      }

      JS_FreeValue(ctx, newElementValue);
    } else if (child->type == GUMBO_NODE_TEXT) {

      JSValue textContentValue = JS_NewString(ctx, child->v.text.text);
      JSValue argv[] = {
        textContentValue
      };
      JSValue textNodeValue = JS_CallConstructor(ctx, TextNode::instance(context)->classObject, 1, argv);
      JS_FreeValue(ctx, textContentValue);

      auto *textNodeInstance = static_cast<TextNodeInstance *>(JS_GetOpaque(textNodeValue, TextNode::classId()));
      root->internalAppendChild(textNodeInstance);
      JS_FreeValue(ctx, textNodeValue);
    }
  }
}
bool HTMLParser::parseHTML(const char *code, size_t codeLength, NodeInstance *rootNode) {
  std::string html = std::string(code, codeLength);

  if (rootNode != nullptr) {
    rootNode->internalClearChild();

    if (!trim(html).empty()) {
      // Gumbo-parser parse HTML.
      size_t html_length = html.length();
      auto *htmlTree = gumbo_parse_with_options(&kGumboDefaultOptions, html.c_str(), html_length);
      traverseHTML(rootNode, htmlTree->root);
    }
  } else {
    KRAKEN_LOG(ERROR) << "Root node is null.";
  }

  return true;
}
void HTMLParser::parseProperty(ElementInstance *element, GumboElement *gumboElement) {
  JSContext *context = element->context();
  QjsContext *ctx = context->ctx();

  GumboVector * attributes = &gumboElement->attributes;
  for (int j = 0; j < attributes->length; ++j) {
    auto* attribute = (GumboAttribute*) attributes->data[j];

    if (strcmp(attribute->name, "style") == 0) {
      std::vector<std::string> arrStyles;
      std::string::size_type prev_pos = 0, pos = 0;
      std::string strStyles = attribute->value;

      while ((pos = strStyles.find(';', pos)) != std::string::npos) {
        arrStyles.push_back(strStyles.substr(prev_pos, pos - prev_pos));
        prev_pos = ++pos;
      }
      arrStyles.push_back(strStyles.substr(prev_pos, pos - prev_pos));

      auto *style = element->style();

      for (auto &s : arrStyles) {
        std::string::size_type position = s.find(':');
        if (position != std::basic_string<char>::npos) {
          std::string styleKey = s.substr(0, position);
          std::transform(styleKey.begin(), styleKey.end(), styleKey.begin(), ::tolower);
          trim(styleKey);

          std::string styleValue = s.substr(position + 1, s.length());
          std::transform(styleValue.begin(), styleValue.end(), styleValue.begin(), ::tolower);
          trim(styleValue);

          JSValue newStyleValue = JS_NewString(ctx, styleValue.c_str());
          style->internalSetProperty(styleKey, newStyleValue);
          JS_FreeValue(ctx, newStyleValue);
        }
      }

    } else {
      std::string strName = attribute->name;
      std::transform(strName.begin(), strName.end(), strName.begin(), ::tolower);
      std::string strValue = attribute->value;
      std::transform(strValue.begin(), strValue.end(), strValue.begin(), ::tolower);

      JSAtom key = JS_NewAtom(ctx, strName.c_str());
      JSValue value = JS_NewString(ctx, strValue.c_str());

      JS_SetProperty(ctx, element->instanceObject, key, value);
      JS_FreeAtom(ctx, key);
    }
  }

}

} // namespace kraken::binding::qjs
