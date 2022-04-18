import {Node} from "./node";
import {Element} from "./element";
import {Text} from "./text";
import {Comment} from "./comment";
import {DocumentFragment} from "./document_fragment";

interface Document extends Node {

  createElement(tagName: string): Element;
  createTextNode(value: string): Text;
  createDocumentFragment(): DocumentFragment;
  createComment(): Comment;

  new(): Document;
}
