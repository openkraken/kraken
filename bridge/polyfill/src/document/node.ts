import { EventTarget } from 'event-target-shim';
import { insertAdjacentNode, removeNode } from "./UIManager";

type NodeList = Array<NodeImpl>;

export enum NodeType {
  ELEMENT_NODE = 1,
  TEXT_NODE = 3,
  COMMENT_NODE = 8,
  DOCUMENT_NODE = 9,
  DOCUMENT_TYPE_NODE = 10,
  DOCUMENT_FRAGMENT_NODE = 11
}

export class NodeImpl extends EventTarget {
  public readonly childNodes: NodeList = [];

  public get firstChild() {
    return this.childNodes[0];
  }
  public get lastChild() {
    return this.childNodes[this.childNodes.length - 1];
  }
  public get nextSibling() {
    if (!this.parentNode) {
      return null;
    }
    return this.parentNode.childNodes[this.parentChildIndex + 1];
  }
  public get nodeName(): string {
    throw new Error('node nodeName property need to be override')
  }

  public readonly nodeType: NodeType;
  public parentNode: NodeImpl | null;
  public id: number;
  private parentChildIndex: number;

  constructor(type: NodeType, id: number) {
    super();
    this.nodeType = type;
    this.id = id;
  }

  public appendChild(node: NodeImpl) {
    if (node.id < 0) {
      throw new Error(`${node.nodeName} can not be append to ${this.nodeName}`);
    }

    this.childNodes.push(node);
    node.parentChildIndex = this.childNodes.length - 1;
    node.parentNode = this;
    insertAdjacentNode(this.id, 'beforeend', node.id);
  }

  public removeChild(node: NodeImpl) {
    if (node.id < 0) {
      throw new Error(`${node.nodeName} can not be remove from ${this.nodeName}`);
    }

    this.childNodes.some((child, idx) => {
      if (child.id === node.id) {
        this.childNodes.splice(idx, 1);
        removeNode(node.id);
        return true;
      }
      return false;
    });
  }

  public insertBefore(newChild: NodeImpl, referenceNode: NodeImpl) {
    if (!referenceNode.parentNode) return;
    const parentNode = referenceNode.parentNode;
    const nextIndex = parentNode.childNodes.indexOf(referenceNode);
    parentNode.childNodes.splice(nextIndex - 1, 0, newChild);
    newChild.parentNode = parentNode;
    insertAdjacentNode(referenceNode.id, 'beforebegin', newChild.id);
  }

  public remove() {
    removeNode(this.id);
  }

  /**
   * The Node.replaceChild() method replaces a child node within the given (parent) node.
   * @param newChild {NodeImpl} The new node to replace oldChild. If it already exists in the DOM, it is first removed.
   * @param oldChild {NodeImpl} The child to be replaced.
   * @return The returned value is the replaced node. This is the same node as oldChild.
   */
  public replaceChild(newChild: NodeImpl, oldChild: NodeImpl) {
    const argLength = arguments.length;
    if (argLength < 2) throw new Error(`Uncaught TypeError: Failed to execute 'replaceChild' on 'Node': 2 arguments required, but only ${argLength} present.`);
    if (!oldChild.parentNode) throw new Error(`Failed to execute 'replaceChild' on 'Node': The node to be replaced is not a child of this node.`);

    const parentNode = oldChild.parentNode;
    oldChild.parentNode = null;
    const childIndex = oldChild.parentChildIndex;

    newChild.parentNode = parentNode;
    parentNode.childNodes.splice(childIndex, 1, newChild);

    insertAdjacentNode(oldChild.id, 'afterend', newChild.id);
    removeNode(oldChild.id);
    return oldChild;
  }
}
