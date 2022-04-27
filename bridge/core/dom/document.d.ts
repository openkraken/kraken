import {Node} from "./node";
import {Text} from "./text";
import {Comment} from "./comment";
import {DocumentFragment} from "./document_fragment";
import {HTMLHeadElement} from "../html/html_head_element";
import {HTMLBodyElement} from "../html/html_body_element";
import {HTMLHtmlElement} from "../html/html_html_element";
import {Element} from "./element";

interface Document extends Node {
  body: HTMLBodyElement | null;
  readonly head: HTMLHeadElement | null;
  readonly documentElement: HTMLHtmlElement;

  createElement(tagName: string): NewObject<Element>;
  createTextNode(value: string): NewObject<Text>;
  createDocumentFragment(): NewObject<DocumentFragment>;
  createComment(): NewObject<Comment>;

  new(): Document;
}
