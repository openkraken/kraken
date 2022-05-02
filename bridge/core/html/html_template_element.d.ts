import {HTMLElement} from "./html_element";
import {DocumentFragment} from "../dom/document_fragment";

export interface HTMLTemplateElement extends HTMLElement {
  readonly content: DocumentFragment;
  new(): void;
}
