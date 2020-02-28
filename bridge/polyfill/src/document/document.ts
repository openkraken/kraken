import { NodeType, NodeId } from './node';
import { ElementImpl } from './element';
import { CommentImpl } from './comment';
import { TextImpl } from './text';
import { VideoImpl } from './tags/video';
import { AudioImpl } from './tags/audio';

export class DocumentImpl {
  public body: ElementImpl = new ElementImpl('BODY', NodeId.BODY);
  public nodeName: string = '#document';
  public nodeType = NodeType.DOCUMENT_NODE;

  createElement(tagName: string) {
    let element;
    switch(tagName) {
      case 'video':
        element = new VideoImpl(tagName);
        break;
      case 'audio':
        element = new AudioImpl(tagName);
        break;
      default:
        element = new ElementImpl(tagName);
        break;
    }
    return element;
  }

  createTextNode(text: string) {
    return new TextImpl(text);
  }

  /**
   * createComment() creates a new comment node, and returns it.
   * @param data {string} A string containing the data to be added to the Comment.
   */
  createComment(data: string) {
    return new CommentImpl(data);
  }
}

export const document = new DocumentImpl();
