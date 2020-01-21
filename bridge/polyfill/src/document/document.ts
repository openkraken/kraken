import { NodeImpl, NodeType } from './node';
import { ElementImpl } from "./element";
import { TextImpl } from "./text";

let id = 1;

export class DocumentImpl extends NodeImpl {
  public body: ElementImpl = new ElementImpl('BODY', -1);

  constructor() {
    super(NodeType.DOCUMENT_NODE, -2);
  }

  createElement(tagName: string) {
    return new ElementImpl(tagName, id++);
  }

  createTextNode(text: string) {
    return new TextImpl(text, id++);
  }
}
