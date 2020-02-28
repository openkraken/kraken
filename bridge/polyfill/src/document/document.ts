import { Node, NodeType, NodeId } from './node';
import { Element } from './element';
import { Comment } from './comment';
import { Text } from './text';
import { Video } from './tags/video';

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
    let element;
    switch(tagName) {
      case 'video':
        element = new Video(tagName);
        break;
      default:
        element = new Element(tagName);
        break;
    }
    return element;
  }

  createTextNode(text: string) {
    return new Text(text);
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
