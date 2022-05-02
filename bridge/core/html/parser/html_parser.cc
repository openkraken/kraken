/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include <utility>

#include "core/dom/element.h"
#include "core/dom/document.h"
#include "foundation/logging.h"
#include "html_parser.h"

namespace kraken {

inline std::string trim(const std::string& str) {
  std::string tmp = str;
  tmp.erase(0, tmp.find_first_not_of(' '));  // prefixing spaces
  tmp.erase(tmp.find_last_not_of(' ') + 1);  // surfixing spaces
  return tmp;
}

// Parse html,isHTMLFragment should be false if need to automatically complete html, head, and body when they are
// missing.
GumboOutput* parse(const std::string& html, bool isHTMLFragment = false) {
  // Gumbo-parser parse HTML.
  GumboOutput* htmlTree = gumbo_parse_with_options(&kGumboDefaultOptions, html.c_str(), html.length());

  if (isHTMLFragment) {
    // Find body.
    const GumboVector* children = &htmlTree->root->v.element.children;
    for (int i = 0; i < children->length; ++i) {
      auto* child = (GumboNode*)children->data[i];
      if (child->type == GUMBO_NODE_ELEMENT) {
        std::string tagName;
        if (child->v.element.tag != GUMBO_TAG_UNKNOWN) {
          tagName = gumbo_normalized_tagname(child->v.element.tag);
        } else {
          GumboStringPiece piece = child->v.element.original_tag;
          gumbo_tag_from_original_text(&piece);
          tagName = std::string(piece.data, piece.length);
        }

        if (tagName.compare("body") == 0) {
          htmlTree->root = child;
          break;
        }
      }
    }
  }

  return htmlTree;
}

void HTMLParser::traverseHTML(Node* root_node, GumboNode* node) {
  auto* context = root_node->GetExecutingContext();
  JSContext* ctx = root_node->GetExecutingContext()->ctx();

  const GumboVector* children = &node->v.element.children;
  for (int i = 0; i < children->length; ++i) {
    auto* child = (GumboNode*)children->data[i];

    if (auto* root_container = DynamicTo<ContainerNode>(root_node)) {
      if (child->type == GUMBO_NODE_ELEMENT) {
        std::string tagName;
        if (child->v.element.tag != GUMBO_TAG_UNKNOWN) {
          tagName = gumbo_normalized_tagname(child->v.element.tag);
        } else {
          GumboStringPiece piece = child->v.element.original_tag;
          gumbo_tag_from_original_text(&piece);
          tagName = std::string(piece.data, piece.length);
        }

        auto* element = context->document()->createElement(AtomicString(ctx, tagName), ASSERT_NO_EXCEPTION());
        root_container->AppendChild(element);
        parseProperty(element, &child->v.element);

        // eval javascript when <script>//code...</script>.
        if (child->v.element.children.length > 0) {
          if (child->v.element.tag == GUMBO_TAG_SCRIPT) {
            const char* code = ((GumboNode*)child->v.element.children.data[0])->v.text.text;
            context->EvaluateJavaScript(code, strlen(code), "vm://", 0);
          } else {
            traverseHTML(element, child);
          }
        }
      } else if (child->type == GUMBO_NODE_TEXT) {
        auto* text = context->document()->createTextNode(AtomicString(ctx, child->v.text.text), ASSERT_NO_EXCEPTION());
        root_container->AppendChild(text);
      }
    }
  }
}

bool HTMLParser::parseHTML(const std::string& html, Node* root_node, bool isHTMLFragment) {
  if (root_node != nullptr) {
    if (auto* root_container_node = DynamicTo<ContainerNode>(root_node)) {
      root_container_node->RemoveChildren();

      if (!trim(html).empty()) {
        GumboOutput* htmlTree = parse(html, isHTMLFragment);
        traverseHTML(root_container_node, htmlTree->root);
        // Free gumbo parse nodes.
        gumbo_destroy_output(&kGumboDefaultOptions, htmlTree);
      }
    }
  } else {
    KRAKEN_LOG(ERROR) << "Root node is null.";
  }

  return true;
}

bool HTMLParser::parseHTML(const std::string& html, Node* root_node) {
  return parseHTML(html, root_node, false);
}

bool HTMLParser::parseHTML(const char* code, size_t codeLength, Node* root_node) {
  std::string html = std::string(code, codeLength);
  return parseHTML(html, root_node, false);
}

bool HTMLParser::parseHTMLFragment(const char* code, size_t codeLength, Node* rootNode) {
  std::string html = std::string(code, codeLength);
  return parseHTML(html, rootNode, true);
}

void HTMLParser::parseProperty(Element* element, GumboElement* gumboElement) {
  auto* context = element->GetExecutingContext();
  JSContext* ctx = context->ctx();

  GumboVector* attributes = &gumboElement->attributes;
  for (int j = 0; j < attributes->length; ++j) {
    auto* attribute = (GumboAttribute*)attributes->data[j];

    if (strcmp(attribute->name, "style") == 0) {
      std::vector<std::string> arrStyles;
      std::string::size_type prev_pos = 0, pos = 0;
      std::string strStyles = attribute->value;

      while ((pos = strStyles.find(';', pos)) != std::string::npos) {
        arrStyles.push_back(strStyles.substr(prev_pos, pos - prev_pos));
        prev_pos = ++pos;
      }
      arrStyles.push_back(strStyles.substr(prev_pos, pos - prev_pos));

      auto* style = element->style();

      for (auto& s : arrStyles) {
        std::string::size_type position = s.find(':');
        if (position != std::basic_string<char>::npos) {
          std::string styleKey = s.substr(0, position);
          trim(styleKey);
          std::string styleValue = s.substr(position + 1, s.length());
          trim(styleValue);
          style->setProperty(AtomicString(ctx, styleKey), AtomicString(ctx, styleValue), ASSERT_NO_EXCEPTION());
        }
      }

    } else {
      std::string strName = attribute->name;
      std::string strValue = attribute->value;
      element->setAttribute(AtomicString(ctx, strName), AtomicString(ctx, strValue), ASSERT_NO_EXCEPTION());
    }
  }
}

}  // namespace kraken
