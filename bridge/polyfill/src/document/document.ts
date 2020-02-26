import { NodeImpl, NodeType } from './node';
import { ElementImpl } from './element';
import { TextImpl } from './text';
import { VideoImpl } from './tags/video';

let id = 1;

export class DocumentImpl extends NodeImpl {
  public body: ElementImpl = new ElementImpl('BODY', -1);

  constructor() {
    super(NodeType.DOCUMENT_NODE, -2);
  }

  createElement(tagName: string) {
    let element;
    switch(tagName) {
      case 'video':
        element = new VideoImpl(tagName, id++);
        break;
      default:
        element = new ElementImpl(tagName, id++);
        break;
    }
    return element;
  }

  createTextNode(text: string) {
    return new TextImpl(text, id++);
  }

  /**
   * createComment() creates a new comment node, and returns it.
   * @param data {string} A string containing the data to be added to the Comment.
   */
  createComment(data: string) {
    // Use an empty TextNode to impl comment.
    return new TextImpl('', id++);
  }
}

export const document = new DocumentImpl();
