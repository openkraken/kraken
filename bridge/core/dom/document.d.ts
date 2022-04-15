import {Node} from "./node";
import {Element} from "./element";

interface Document extends Node {

  createElement(tagName: string): Element;

  new(): Document;
}
