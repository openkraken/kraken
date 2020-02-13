import { NodeImpl, NodeType } from './node';
import { createTextNode } from "./UIManager";

export class TextImpl extends NodeImpl {
  public textContent: string = '';
  constructor(text: string, id: number) {
    super(NodeType.TEXT_NODE, id);
    createTextNode(id, NodeType.TEXT_NODE, text);
  }

  public get nodeName() {
    return '#text';
  }
}
