import { Node, NodeType, NodeId, traverseNode } from './node';
import { Element } from './element';
import { Comment } from './comment';
import { TextNode } from './text';
import { ElementRegistry } from './element-registry';

export class Document extends Node {
  public body: Element = new Element('BODY', NodeId.BODY);
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

export function getNodeByNodeId(nodeId: number) : Node|null|Window {
  if (nodeId === NodeId.WINDOW) {
    return window;
  }

  let _node = null;
  traverseNode(document.body, (node: Node) : any => {
    if (node.nodeId === nodeId) {
      _node = node;
      return true; // Return true to stop traversing
    }
  });
  return _node;
}
