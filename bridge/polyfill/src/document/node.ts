import { EventTarget, BODY } from './events/event-target';
import { insertAdjacentNode, removeNode } from './ui-manager';
// import { document } from './document';
import { Document } from './document';
import { Element } from './element';

export type NodeList = Array<Node>;

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

  public nodeValue: string | null;
  public textContent: string | null;
  public parentNode: Node | null;

  constructor(type: NodeType, id?: number, builtInEvents?: Array<string>) {
    super(id || nodesCount++, builtInEvents || []);
    this.nodeType = type;
  }

  protected document() :Document| null {
    if (this instanceof Document) {
      return this;
    }

    if (this.isConnected) {
      let currentNode = this.parentNode;
      if (!currentNode) {
        return this instanceof Document ? this : null;
      }
      if (!currentNode.parentNode && currentNode instanceof Document) {
        return currentNode;
      }
      while (currentNode.parentNode) {
        currentNode = currentNode.parentNode;
      }
      return currentNode instanceof Document ? currentNode : null;
    }
    return null;
  }

  public get isConnected() {
    let _isConnected: boolean = this.targetId === BODY;
    let parentNode = this.parentNode;
    while (parentNode) {
      _isConnected = parentNode.targetId === BODY;
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

  private _ensureDetached(child: Node) {
    if (child.parentNode) {
      const idx = child.parentNode!.childNodes.indexOf(child);
      if (idx !== -1) {
        // this.RemovedFromNotify(child.parentNode, child);
        child.parentNode!.childNodes.splice(idx, 1);
        child.parentNode = null;
      }
    }
  }

  public appendChild(child: Node) {
    // @TODO add logic to tell whether child to append contains the parent
    if (child.targetId === BODY || child === this) {
      throw new Error(`Failed to execute 'appendChild' on 'Node': The new child element contains the parent.`);
    }

    this._ensureDetached(child);

    this.childNodes.push(child);
    child.parentNode = this;
    insertAdjacentNode(this.targetId, 'beforeend', child.targetId);
    // this.InsertIntoNotify(this, child);
  }

  /**
   * The ChildNode.remove() method removes the object
   * from the tree it belongs to.
   * reference: https://dom.spec.whatwg.org/#dom-childnode-remove
   */
  public remove() {
    if (this.parentNode == null) return;
    if (this.childNodes.length > 0) {
      while (this.firstChild) {
        this.firstChild.remove();
      }
    }

    this.parentNode.removeChild(this);
  }

  /**
   * The Node.removeChild() method remove a child node within the given (parent) node.
   * @param node {Node} The child node to remove.
   * @return The returned value is the rmoved node.
   */
  public removeChild(child: Node) {
    const idx = this.childNodes.indexOf(child);
    if (idx !== -1) {
      this.childNodes.splice(idx, 1);
      child.parentNode = null;
      removeNode(child.targetId);
      // this.RemovedFromNotify(this, child);
    } else {
      throw new Error(`Failed to execute 'removeChild' on 'Node': The node to be removed is not a child of this node.`);
    }
    return child;
  }

  public insertBefore(newChild: Node, referenceNode: Node | null) {
    if (referenceNode === null) {
      this.appendChild(newChild);
    } else {
      this._ensureDetached(newChild);
      const parentNode = referenceNode.parentNode;
      if (parentNode != null) {
        const parentChildNodes = parentNode.childNodes;
        const nextIndex = parentChildNodes.indexOf(referenceNode);
        parentChildNodes.splice(nextIndex - 1, 0, newChild);
        newChild.parentNode = parentNode;
        insertAdjacentNode(referenceNode.targetId, 'beforebegin', newChild.targetId);
        // this.InsertIntoNotify(parentNode, newChild);
      }
    }
  }

  // public RemovedFromNotify(parentNode: Node, removedNode: Node) :void{
  //   if (parentNode.isConnected && removedNode instanceof Element) {
  //     const elementid = removedNode.getAttribute('id');
  //     if (elementid !== '' && elementid !== undefined && elementid !== null) {
  //       // this.document()?.removeElementById(elementid,)
  //       const my_document = this.document();
  //       if (my_document) {
  //         my_document.removeElementById(elementid, removedNode);
  //       }
  //     }
  //   }
  // }

  public InsertIntoNotify(parentNode: Node, insertionNode:Node) {
    if (parentNode.isConnected && insertionNode instanceof Element) {
      const elementid = insertionNode.getAttribute('id');
      if (elementid !== '' && elementid !== undefined && elementid !== null) {
        const my_document = this.document();
        if (my_document) {
          my_document.addElementById(elementid, insertionNode);
        }
      }
    }
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

    this._ensureDetached(newChild);

    const parentNode = oldChild.parentNode;
    oldChild.parentNode = null;
    const childIndex = parentNode.childNodes.indexOf(oldChild);
    // this.RemovedFromNotify(parentNode, oldChild);
    // this.InsertIntoNotify(parentNode, newChild);
    newChild.parentNode = parentNode;
    parentNode.childNodes.splice(childIndex, 1, newChild);

    insertAdjacentNode(oldChild.targetId, 'afterend', newChild.targetId);
    removeNode(oldChild.targetId);

    return oldChild;
  }
}

export function traverseNode(node: Node, handle: Function) {
  const shouldExit = handle(node);
  if (shouldExit) return shouldExit;

  if (node.childNodes.length > 0) {
    for (let i = 0, l = node.childNodes.length; i < l; i++) {
      traverseNode(node.childNodes[i], handle);
    }
  }
}
