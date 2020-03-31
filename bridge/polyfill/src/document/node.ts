import { EventTarget } from 'event-target-shim';
import { insertAdjacentNode, removeNode } from './UIManager';

export type NodeList = Array<Node>;
export enum NodeId {
  BODY = -1,
  // Window is not inherit node but EventTarget, so we assume window is a node.
  WINDOW = -2,
}
export enum NodeType {
  ELEMENT_NODE = 1,
  TEXT_NODE = 3,
  COMMENT_NODE = 8,
  DOCUMENT_NODE = 9,
  DOCUMENT_TYPE_NODE = 10,
  DOCUMENT_FRAGMENT_NODE = 11
}

let nodesCount = 1;

export class Node extends EventTarget {
  public readonly nodeType: NodeType;
  public readonly childNodes: NodeList = [];
  public readonly nodeId: number;
  public nodeValue: string | null;
  public textContent: string | null;
  public parentNode: Node | null;

  constructor(type: NodeType, id?: number) {
    super();
    this.nodeId = id || nodesCount++;
    this.nodeType = type;
  }

  public get isConnected() {
    let _isConnected = this.nodeId === NodeId.BODY;
    let parentNode = this.parentNode;
    while (parentNode) {
      _isConnected = parentNode.nodeId === NodeId.BODY
      parentNode = parentNode.parentNode;
    }
    return _isConnected;
  }

  public get firstChild() {
    return this.childNodes[0];
  }

  public get lastChild() {
    return this.childNodes[this.childNodes.length - 1];
  }

  public get previousSibling() {
    if (!this.parentNode) {
      return null;
    }
    const parentChildNodes = this.parentNode.childNodes;
    return parentChildNodes[parentChildNodes.indexOf(this) - 1];
  }

  public get nextSibling() {
    if (!this.parentNode) {
      return null;
    }
    const parentChildNodes = this.parentNode.childNodes;
    return parentChildNodes[parentChildNodes.indexOf(this) + 1];
  }

  public appendChild(child: Node) {
    // @TODO add logic to tell whether child to append contains the parent
    if (child.nodeId === NodeId.BODY || child === this) {
      throw new Error(`Failed to execute 'appendChild' on 'Node': The new child element contains the parent.`);
    }

    this.childNodes.push(child);
    child.parentNode = this;
    insertAdjacentNode(this.nodeId, 'beforeend', child.nodeId);
  }

  /**
   * The Node.removeChild() method rmoves a child node within the given (parent) node.
   * @param node {Node} The child node to remove.
   * @return The returned value is the rmoved node.
   */
  public removeChild(child: Node) {
    const idx = this.childNodes.indexOf(child);
    if (idx !== -1) {
      this.childNodes.splice(idx, 1);
      child.parentNode = null;
      removeNode(child.nodeId);
    } else {
      throw new Error(`Failed to execute 'removeChild' on 'Node': The node to be removed is not a child of this node.`);
    }
    return child;
  }

  public insertBefore(newChild: Node, referenceNode: Node) {
    if (!referenceNode.parentNode) return;
    const parentNode = referenceNode.parentNode;
    const parentChildNodes = parentNode.childNodes;
    const nextIndex = parentChildNodes.indexOf(referenceNode);
    parentChildNodes.splice(nextIndex - 1, 0, newChild);
    newChild.parentNode = parentNode;
    insertAdjacentNode(referenceNode.nodeId, 'beforebegin', newChild.nodeId);
  }

  /**
   * The Node.replaceChild() method replaces a child node within the given (parent) node.
   * @param newChild {Node} The new node to replace oldChild. If it already exists in the DOM, it is first removed.
   * @param oldChild {Node} The child to be replaced.
   * @return The returned value is the replaced node. This is the same node as oldChild.
   */
  public replaceChild(newChild: Node, oldChild: Node) {
    const argLength = arguments.length;
    if (argLength < 2) throw new Error(`Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments required, but only ${argLength} present.`);
    if (!oldChild.parentNode) throw new Error(`Failed to execute 'replaceChild' on 'Node': The node to be replaced is not a child of this node.`);

    const parentNode = oldChild.parentNode;
    oldChild.parentNode = null;
    const childIndex = parentNode.childNodes.indexOf(oldChild);

    newChild.parentNode = parentNode;
    parentNode.childNodes.splice(childIndex, 1, newChild);

    insertAdjacentNode(oldChild.nodeId, 'afterend', newChild.nodeId);
    removeNode(oldChild.nodeId);

    return oldChild;
  }
}

export function traverseNode(node: Node, handle: Function) {
  const shouldExit = handle(node);
  if (shouldExit) return;

  if (node.childNodes.length > 0) {
    for (let i = 0, l = node.childNodes.length; i < l; i++) {
      traverseNode(node.childNodes[i], handle);
    }
  }
}
