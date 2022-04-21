import { EventTarget } from './events/event_target';
import { Document } from './document';
import {Element} from "./element";

/** Node is an interface from which a number of DOM API object types inherit. It allows those types to be treated similarly; for example, inheriting the same set of methods, or being tested in the same way. */
interface Node extends EventTarget {
  // /**
  //  * Returns the children.
  //  */
  // readonly childNodes: NodeList;
  /**
   * Returns the first child.
   */
  readonly firstChild: Node | null;
  /**
   * Returns true if node is connected and false otherwise.
   */
  readonly isConnected: boolean;
  /**
   * Returns the last child.
   */
  readonly lastChild: Node | null;
  /**
   * Returns the next sibling.
   */
  readonly nextSibling: Node | null;
  /**
   * Returns a string appropriate for the type of node.
   */
  readonly nodeName: string;
  /**
   * Returns the type of node.
   */
  readonly nodeType: number;
  nodeValue: string | null;
  /**
   * Returns the node document. Returns null for documents.
   */
  readonly ownerDocument: Document | null;
  /**
   * Returns the parent element.
   */
  // @ts-ignore
  readonly parentElement: Element | null;
  /**
   * Returns the parent.
   */
  readonly parentNode: Node | null;
  /**
   * Returns the previous sibling.
   */
  readonly previousSibling: Node | null;
  textContent: string | null;
  appendChild(newNode: Node): Node;
  /**
   * Returns a copy of node. If deep is true, the copy also includes the node's descendants.
   */
  cloneNode(deep?: boolean): Node;
  /**
   * Returns true if other is an inclusive descendant of node, and false otherwise.
   */
  contains(other: Node | null): boolean;
  insertBefore(newChild: Node, refChild: Node | null): Node;
  /**
   * Returns whether node and otherNode have the same properties.
   */
  isEqualNode(otherNode: Node | null): boolean;
  isSameNode(otherNode: Node | null): boolean;
  removeChild(oldChild: Node): Node;
  replaceChild(newChild: Node, oldChild: Node): Node;

  new(): void;
}
