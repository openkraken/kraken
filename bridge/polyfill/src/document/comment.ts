import { NodeImpl, NodeType } from './node';
import { createComment } from './UIManager';

export class CommentImpl extends NodeImpl {
  public nodeName: string = '#comment';
  public data: string = '';

  constructor(data: string) {
    super(NodeType.COMMENT_NODE);
    this.textContent = this.nodeValue = this.data = data;
    createComment(this.nodeId, data);
  }
}
