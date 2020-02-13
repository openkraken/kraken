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

  public insertBefore(newNode: NodeImpl, referenceNode: NodeImpl) {
    if (!referenceNode.parentNode) return;
    const parentNode = referenceNode.parentNode;
    const nextIndex = parentNode.childNodes.indexOf(referenceNode);
    parentNode.childNodes.splice(nextIndex - 1, 0, newNode);
    newNode.parentNode = parentNode;
    insertAdjacentNode(referenceNode.id, 'beforebegin', newNode.id);
  }

  public remove() {
    removeNode(this.id);
  }

  // public replaceChild(newNode: NodeImpl, oldNode: NodeImpl) {
  //   if (!oldNode.parentNode) return;
  //   const parentNode = oldNode.parentNode;
  //   oldNode.parentNode = null;
  //   const childIndex = oldNode.parentChildIndex;
  //
  //   newNode.parentNode = parentNode;
  //   parentNode.childNodes.splice(childIndex, 1, newNode);
  //
  //   insertAdjacentNode(oldNode.id, 'afterend', newNode.id);
  //   removeNode(oldNode.id);
  // }
}
