import {Node} from "./node";
import {Document} from "./document";
import {ScrollToOptions} from "./scroll_to_options";
import { ElementAttributes } from './legacy/element_attributes';

interface Element extends Node {
  readonly attributes: ElementAttributes;

  readonly clientHeight: number;
  readonly clientLeft: number;
  readonly clientTop: number;
  readonly clientWidth: number;
  outerHTML: string;
  innerHTML: string;
  readonly ownerDocument: Document;
  scrollLeft: number;
  scrollTop: number;
  /**
   * Returns the HTML-uppercased qualified name.
   */
  readonly tagName: string;
  /**
   * Returns element's first attribute whose qualified name is qualifiedName, and null if there is no such attribute otherwise.
   */
  getAttribute(qualifiedName: string): string | null;
  /**
   * Sets the value of element's first attribute whose qualified name is qualifiedName to value.
   */
  setAttribute(qualifiedName: string, value: string): void;
  /**
   * Removes element's first attribute whose qualified name is qualifiedName.
   */
  removeAttribute(qualifiedName: string): void;
  getBoundingClientRect(): BoundingClientRect;

  scroll(options?: ScrollToOptions): void;
  scroll(x: number, y: number): void;
  scrollBy(options?: ScrollToOptions): void;
  scrollBy(x: number, y: number): void;
  scrollTo(options?: ScrollToOptions): void;
  scrollTo(x: number, y: number): void;

  // Kraken special API.
  toBlob(devicePixelRatioValue?: double): Promise<ArrayBuffer>;

  new(): void;
}
