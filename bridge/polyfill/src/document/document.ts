import { Node, NodeType, NodeId, traverseNode } from './node';
import { Element } from './element';
import { Comment } from './comment';
import { TextNode } from './text';
import { ElementRegistry } from './element-registry';

export class Document extends Node {
  private bodyElement = new Element('BODY', NodeId.BODY);
  public body: Element = this.bodyElement;
  // @TODO Need to implement complete document tree model, equal to body temporary
  public documentElement: Element = this.bodyElement;
  public nodeName: string = '#document';
  public nodeType = NodeType.DOCUMENT_NODE;

  constructor() {
    // Use the same nodeId with body, only used in event targets,
    // document events are triggered and received by body element.
    super(NodeType.DOCUMENT_NODE, NodeId.BODY);
  }

  createElement(tagName: string) : Element {
    const ElementConstructor = ElementRegistry.get(tagName) || Element;
    return new ElementConstructor(tagName);
  }

  createTextNode(text: string) {
    return new TextNode(text);
  }

  /**
   * createComment() creates a new comment node, and returns it.
   * @param data {string} A string containing the data to be added to the Comment.
   */
  createComment(data: string) {
    return new Comment(data);
  }
}

export const document = new Document();

export function getNodeByNodeId(nodeId: number) : Node|null {
  let _node = null;
  traverseNode(document.body, (node: Node) : any => {
    if (node.nodeId === nodeId) {
      _node = node;
      return true; // Return true to stop traversing
    }
  });
  return _node;
}
