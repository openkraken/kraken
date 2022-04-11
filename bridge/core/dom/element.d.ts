import {Node} from "./node";
import {Document} from "./document";

interface Element extends Node {
  readonly attributes: NamedNodeMap;

  readonly clientHeight: number;
  readonly clientLeft: number;
  readonly clientTop: number;
  readonly clientWidth: number;
  /**
   * Returns the value of element's id content attribute. Can be set to change it.
   */
  id: string;
  outerHTML: string;
  innerHTML: string;
  readonly ownerDocument: Document;
  readonly scrollHeight: number;
  scrollLeft: number;
  scrollTop: number;
  readonly scrollWidth: number;
  /**
   * Returns the HTML-uppercased qualified name.
   */
  readonly tagName: string;
  /**
   * Returns element's first attribute whose qualified name is qualifiedName, and null if there is no such attribute otherwise.
   */
  getAttribute(qualifiedName: string): string | null;
  getBoundingClientRect(): BoundingClientRect;
  /**
   * Returns a HTMLCollection of the elements in the object on which the method was invoked (a document or an element) that have all the classes given by classNames. The classNames argument is interpreted as a space-separated list of classes.
   */
  getElementsByClassName(classNames: string): HTMLCollectionOf<Element>;
  getElementsByTagName<K extends keyof HTMLElementTagNameMap>(qualifiedName: K): HTMLCollectionOf<HTMLElementTagNameMap[K]>;
  getElementsByTagName<K extends keyof SVGElementTagNameMap>(qualifiedName: K): HTMLCollectionOf<SVGElementTagNameMap[K]>;
  getElementsByTagName(qualifiedName: string): HTMLCollectionOf<Element>;
  /**
   * Returns true if element has an attribute whose qualified name is qualifiedName, and false otherwise.
   */
  hasAttribute(qualifiedName: string): boolean;
  insertAdjacentElement(where: InsertPosition, element: Element): Element | null;
  insertAdjacentHTML(position: InsertPosition, text: string): void;
  insertAdjacentText(where: InsertPosition, data: string): void;
  /**
   * Removes element's first attribute whose qualified name is qualifiedName.
   */
  removeAttribute(qualifiedName: string): void;
  scroll(options?: ScrollToOptions): void;
  scroll(x: number, y: number): void;
  scrollBy(options?: ScrollToOptions): void;
  scrollBy(x: number, y: number): void;
  scrollIntoView(arg?: boolean | ScrollIntoViewOptions): void;
  scrollTo(options?: ScrollToOptions): void;
  scrollTo(x: number, y: number): void;
  /**
   * Sets the value of element's first attribute whose qualified name is qualifiedName to value.
   */
  setAttribute(qualifiedName: string, value: string): void;
  /**
   * Sets the value of element's attribute whose namespace is namespace and local name is localName to value.
   */
  setAttributeNS(namespace: string | null, qualifiedName: string, value: string): void;
  setAttributeNode(attr: Attr): Attr | null;
}
