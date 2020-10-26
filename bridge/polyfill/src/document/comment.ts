import { Node, NodeType } from './node';
import { createComment } from './ui-manager';

export class Comment extends Node {
  public nodeName: string = '#comment';
  public data: string = '';

  constructor(data: string) {
    super(NodeType.COMMENT_NODE);
    this.textContent = this.nodeValue = this.data = data;
    createComment(this.targetId, data);
  }
}
