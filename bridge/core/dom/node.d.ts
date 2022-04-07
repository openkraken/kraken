import { EventTarget } from './events/event_target';

/** Node is an interface from which a number of DOM API object types inherit. It allows those types to be treated similarly; for example, inheriting the same set of methods, or being tested in the same way. */
interface Node extends EventTarget {
  /**
   * Returns the children.
   */
  readonly childNodes: Node[];
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
  //  */
  // readonly ownerDocument: Document | null;
  // /**
  //  * Returns the parent element.
  //  */
  // readonly parentElement: HTMLElement | null;
  // /**
  //  * Returns the parent.
  //  */
  // readonly parentNode: Node & ParentNode | null;
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
  readonly ATTRIBUTE_NODE: number;
  /**
   * node is a CDATASection node.
   */
  readonly CDATA_SECTION_NODE: number;
  /**
   * node is a Comment node.
   */
  readonly COMMENT_NODE: number;
  /**
   * node is a DocumentFragment node.
   */
  readonly DOCUMENT_FRAGMENT_NODE: number;
  /**
   * node is a document.
   */
  readonly DOCUMENT_NODE: number;
  /**
   * Set when other is a descendant of node.
   */
  readonly DOCUMENT_POSITION_CONTAINED_BY: number;
  /**
   * Set when other is an ancestor of node.
   */
  readonly DOCUMENT_POSITION_CONTAINS: number;
  /**
   * Set when node and other are not in the same tree.
   */
  readonly DOCUMENT_POSITION_DISCONNECTED: number;
  /**
   * Set when other is following node.
   */
  readonly DOCUMENT_POSITION_FOLLOWING: number;
  readonly DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC: number;
  /**
   * Set when other is preceding node.
   */
  readonly DOCUMENT_POSITION_PRECEDING: number;
  /**
   * node is a doctype.
   */
  readonly DOCUMENT_TYPE_NODE: number;
  /**
   * node is an element.
   */
  readonly ELEMENT_NODE: number;
  readonly ENTITY_NODE: number;
  readonly ENTITY_REFERENCE_NODE: number;
  readonly NOTATION_NODE: number;
  /**
   * node is a ProcessingInstruction node.
   */
  readonly PROCESSING_INSTRUCTION_NODE: number;
  /**
   * node is a Text node.
   */
  readonly TEXT_NODE: number;

  new(): Node;
}
